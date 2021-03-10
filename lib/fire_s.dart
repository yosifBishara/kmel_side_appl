import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Appointment.dart';


class FireHelper {

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final CollectionReference collectionReference = FirebaseFirestore.instance.collection('appointments');
  DateTime today = DateTime.now();


  FireHelper();

  Future<bool> addApp(Appointment appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.number).set({
        'name' : appointment.name,
        'date' : appointment.date,
        'day' : appointment.day,
        'persons' : appointment.persons,
        'time' : appointment.time
      });
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<Appointment> getApp(String phone_num) async {
    DocumentSnapshot documentSnapshot;
    try {
      documentSnapshot = await _firestore.collection('appointments').doc(phone_num).get();
      Appointment app = Appointment(documentSnapshot.get('name'),
          phone_num, documentSnapshot.get('date'),
          documentSnapshot.get('day'), documentSnapshot.get('persons'),
          documentSnapshot.get('time'));
      return app;

    } catch(e) {
      return null;
    }

  }

  Future<bool> updateApp(Appointment appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.number).update({
        'name' : appointment.name,
        'date' : appointment.date,
        'day' : appointment.day,
        'persons' : appointment.persons,
        'time' : appointment.time
      });
      return true;
    }catch(e) {
      return false;
    }
  }

  Future<bool> deleteApp(String phone_num) async {
    try {
      await _firestore.collection('appointments').doc(phone_num).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  //check if a given date and time are appointed - for time dropDown
  Future<bool> takenDateTime(String date, String time) async {
    QuerySnapshot res = await _firestore.collection('appointments').get();
    List<DocumentSnapshot> docs = res.docs;
    List<dynamic> timeList = List();
    for(int i=0 ; i < docs.length ; i++){
      timeList = docs[i].get('time');
      if(docs[i].get('date')==date){
        for(int j =0 ; j < timeList.length ; j++){
          if('${timeList[j]}' == time){
            return true;
          }
        }
      }
    }
    return false;
  }

  //check if a person already has an appointment
  Future<bool> personAlreadyAppointed(String personNumber) async {
    QuerySnapshot res = await _firestore.collection('appointments').get();
    List<DocumentSnapshot> docs = res.docs;
    for(int i=0 ; i < docs.length ; i++){
      if(docs[i].id == personNumber){
        return true;
      }
    }
    return false;
  }

  Future<DocumentSnapshot> returnAppointmentData(String personNumber) async {
    QuerySnapshot res = await _firestore.collection('appointments').get();
    List<DocumentSnapshot> docs = res.docs;
    for(int i = 0 ; i < docs.length ; i++){
      if(docs[i].id == personNumber)
        return docs[i];
    }
    return null;
  }

  Future<int> initSelectedNum() async{
    QuerySnapshot res = await _firestore.collection('appointments').where('date', isEqualTo: '${today.day}/${today.month}/${today.year}').get();
    List<DocumentSnapshot> docs = res.docs;
    return docs.length;
  }

}