import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Appointment.dart';
import 'constants.dart';

class FireStoreClient {

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _appointmentsCollection = _firestore
      .collection(FireStoreArg.APPOINTMENTS_COLLECTION_ID);
  final _workTimesCollection = _firestore
      .collection(FireStoreArg.WORK_TIMES_COLLECTION_ID);
  final _usersCollection = _firestore
      .collection(FireStoreArg.USERS_COLLECTION_ID);
  final _appUpdateCollection = _firestore
      .collection(FireStoreArg.APP_UPDATE_INFO_COLLECTION_ID);

  List _workTimeList = [];
  int _timeOffsetMin = 0;

  FireStoreClient();

  int get timeOffsetMin => _timeOffsetMin;

  bool isDateInTimeSlot(String date, String slotId) {
    List slotDateSplit = (slotId.split('-')[1]).split('.');
    slotDateSplit = slotDateSplit.map((element) => element = int.parse(element)).toList();
    DateTime slotObj = DateTime(slotDateSplit[2], slotDateSplit[1], slotDateSplit[0]);
    List dateSplit = date.split('.');
    dateSplit = dateSplit.map((element) => element = int.parse(element)).toList();
    DateTime dateObj = DateTime(dateSplit[2], dateSplit[1], dateSplit[0]);
    return (slotObj == dateObj) || (slotObj.isBefore(dateObj));
  }


  Future<List<dynamic>> getWorkingTimes(String date) async {
    QuerySnapshot qs = await _workTimesCollection.get();
    if (qs.docs.length == 1) {
      _workTimeList = qs.docs[0].get(FireStoreArg.WORK_TIMES_LIST_FIELD);
      _timeOffsetMin = qs.docs[0].get(FireStoreArg.TIME_OFFSET_MIN_FIELD);
      return _workTimeList;
    }

    qs.docs.sort((s1, s2) {
      List s1Split = (s1.id.split('-')[1]).split('.');
      s1Split = s1Split.map((element) => element = int.parse(element)).toList();
      List s2Split = (s2.id.split('-')[1]).split('.');
      s2Split = s2Split.map((element) => element = int.parse(element)).toList();
      if (s1Split[2] != s2Split[2]) {
        return s1Split[2] - s2Split[2];
      }
      if (s1Split[1] != s2Split[1]) {
        return s1Split[1] - s2Split[1];
      }
      return s1Split[0] - s2Split[0];
    });

    int idx ;
    if (isDateInTimeSlot(date, qs.docs[1].id)) {
      idx = 1;
    } else {
      idx = 0;
    }
    _workTimeList = qs.docs[idx].get(FireStoreArg.WORK_TIMES_LIST_FIELD);
    _timeOffsetMin = qs.docs[idx].get(FireStoreArg.TIME_OFFSET_MIN_FIELD);
    return _workTimeList;

  }

  Future<List<dynamic>> getUnavailableTimes(String date) async {
    DocumentSnapshot ds = await _appointmentsCollection.doc(date).get();
    if (!ds.exists) {
      return [];
    }
    return ds.get(FireStoreArg.UNAVAILABLE_TIMES_FIELD);
  }

  Future<String> makeNewAppointment(String name, String number, int persons, String day, String date, List times,
      {bool isVacation = false}) async {
    return await _firestore.runTransaction((transaction) async {
      // First phase: Read all required data
      Map<String, DocumentSnapshot> timeSlots = {};
      DocumentReference dateDocRef = _appointmentsCollection.doc(date);
      DocumentSnapshot dateDocSnap = await transaction.get(dateDocRef);

      // Collect all the time slot documents
      for (String time in times) {
        DocumentReference dr = dateDocRef
            .collection(FireStoreArg.DAY_APPOINTMENTS_COLLECTION)
            .doc(time);
        DocumentSnapshot ds = await transaction.get(dr);
        timeSlots[time] = ds;
      }

      DocumentReference userDr = _usersCollection.doc(number);
      bool userExists = (await transaction.get(userDr)).exists;

      // Check if any of the time slots are already taken
      for (DocumentSnapshot ds in timeSlots.values) {
        if (ds.exists) {
          return FireStoreArg.TIME_ALREADY_TAKEN;
        }
      }

      // Second phase: Perform all writes
      for (String time in times) {
        DocumentReference dr = dateDocRef
            .collection(FireStoreArg.DAY_APPOINTMENTS_COLLECTION)
            .doc(time);

        // Create new appointment for the time slot
        transaction.set(dr, {
          FireStoreArg.PHONE_NUM_FIELD: number,
          FireStoreArg.NAME_FIELD: name,
          FireStoreArg.DAY_FIELD: day,
        });
      }

      // Ensure the date document exists, create it if it doesn't
      if (!dateDocSnap.exists) {
        transaction.set(dateDocRef, {
          FireStoreArg.UNAVAILABLE_TIMES_FIELD: FieldValue.arrayUnion(times)
        });
      } else {
        // Add the time slots to the unavailable times array
        transaction.update(dateDocRef, {
          FireStoreArg.UNAVAILABLE_TIMES_FIELD: FieldValue.arrayUnion(times)
        });
      }

      // Add to users collection
      if (!isVacation){
        if (userExists) {
          transaction.update(userDr, {
            FireStoreArg.NAME_FIELD: name,
            FireStoreArg.NEXT_APPOINTMENT_FIELD: {
              FireStoreArg.DATE_FIELD: date,
              FireStoreArg.DAY_FIELD: day,
              FireStoreArg.TIME_FIELD: times
            }
          });
        } else {
          transaction.set(userDr, {
            FireStoreArg.NAME_FIELD: name,
            FireStoreArg.NEXT_APPOINTMENT_FIELD: {
              FireStoreArg.DATE_FIELD: date,
              FireStoreArg.DAY_FIELD: day,
              FireStoreArg.TIME_FIELD: times
            }
          });
        }
      }

      return FireStoreArg.APPOINTMENT_PASSED;
    });
  }

  Future<Appointment> getUserDetails(String number) async {
    DocumentSnapshot ds =  await _usersCollection.doc(number).get();
    if (!ds.exists) {
      return null;
    }
    Map nextAppointment = await ds.get(FireStoreArg.NEXT_APPOINTMENT_FIELD);
    return Appointment(
        ds.get(FireStoreArg.NAME_FIELD),
        number,
        nextAppointment[FireStoreArg.DATE_FIELD],
        nextAppointment[FireStoreArg.DAY_FIELD],
        nextAppointment[FireStoreArg.TIME_FIELD].length,
        nextAppointment[FireStoreArg.TIME_FIELD]
    );
  }

  Future<void> deleteAppointment (Appointment appointment) async {

    for (String t in appointment.time) {
      DocumentSnapshot ds = await _appointmentsCollection
          .doc(appointment.date)
          .collection(FireStoreArg.DAY_APPOINTMENTS_COLLECTION)
          .doc(t).get();
      String appNum = await ds.get(FireStoreArg.PHONE_NUM_FIELD);
      if (appNum != appointment.number) {
        return;
      }

      await _appointmentsCollection
          .doc(appointment.date)
          .collection(FireStoreArg.DAY_APPOINTMENTS_COLLECTION)
          .doc(t)
          .delete();
      await _appointmentsCollection
          .doc(appointment.date)
          .update({
        FireStoreArg.UNAVAILABLE_TIMES_FIELD: FieldValue.arrayRemove([t])
      });
    }

    DocumentReference dr = _usersCollection.doc(appointment.number);
    if ((await dr.get()).exists) {
      await _usersCollection
          .doc(appointment.number).update({
        FireStoreArg.NEXT_APPOINTMENT_FIELD: {
          FireStoreArg.DATE_FIELD: '',
          FireStoreArg.DAY_FIELD: '',
          FireStoreArg.TIME_FIELD: []
        }
      }
      );
    }

  }

  Future<void> oldAppointmentCleanup () async {
    DateTime cleanupDay = DateTime.now().subtract(Duration(days: 1));
    for (int j=1 ; j < 100 ; j++) {
      if (cleanupDay.weekday == DateTime.monday) {
        continue;
      }
      DocumentReference dr = _appointmentsCollection.doc(
          '${cleanupDay.day}.${cleanupDay.month}.${cleanupDay.year}'
      );
      DocumentSnapshot ds = await dr.get();
      if (! ds.exists) {
        cleanupDay = cleanupDay.subtract(Duration(days: 1));
        continue;
      }
      QuerySnapshot qs = await dr.collection(FireStoreArg.DAY_APPOINTMENTS_COLLECTION).get();
      for(int i=0 ; i < qs.docs.length ; i++){
        await this.deleteAppointment(Appointment(
            qs.docs[i].get(FireStoreArg.NAME_FIELD),
            qs.docs[i].get(FireStoreArg.PHONE_NUM_FIELD),
            ds.id,
            qs.docs[i].get(FireStoreArg.DAY_FIELD),
            1,
            [ qs.docs[i].id ]
        ));
      }
      await dr.delete();
      cleanupDay = cleanupDay.subtract(Duration(days: 1));
    }
  }

  Future<Map<String, dynamic>> getAppUpdateInfo (String appVersion) async {
    Map<String, dynamic> info = {
      'title' : '',
      'content': '',
      'android': false,
      'ios': false
    };

    DocumentSnapshot ds = await _appUpdateCollection
        .doc(appVersion).get();

    if (ds.exists) {
      info['title'] = ds.get(FireStoreArg.APP_UPDATE_TITLE_FIELD);
      info['content'] = ds.get(FireStoreArg.APP_UPDATE_CONTENT_FIELD);
      info['android'] = ds.get(FireStoreArg.APP_UPDATE_ANDROID_FIELD);
      info['ios'] = ds.get(FireStoreArg.APP_UPDATE_IOS_FIELD);
    }

    return info;
  }

  Future<void> deleteEntireDay (String date) async {
    DocumentReference dr = _appointmentsCollection.doc(date);
    DocumentSnapshot ds = await dr.get();
    if (ds.exists) {
      QuerySnapshot qs = await dr.collection(FireStoreArg.DAY_APPOINTMENTS_COLLECTION).get();
      for(int i=0 ; i < qs.docs.length ; i++){
        await this.deleteAppointment(Appointment(
            qs.docs[i].get(FireStoreArg.NAME_FIELD),
            qs.docs[i].get(FireStoreArg.PHONE_NUM_FIELD),
            ds.id,
            qs.docs[i].get(FireStoreArg.DAY_FIELD),
            1,
            [ qs.docs[i].id ]
        ));
      }
      await dr.delete();
    }
  }


}

FireStoreClient fsc = FireStoreClient();
