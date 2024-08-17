import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kmel_side_app/constants.dart';
import 'package:kmel_side_app/firestoreClient.dart';
import 'dart:math';

String generateRandomString(int len) {
  var r = Random();
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!?_-+=*&@#';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}

class AddVacation extends StatefulWidget {
  @override
  _DateForViewPageState createState() => _DateForViewPageState();
}

DateTime _dateTime;
String selectedVacationDate = '${_dateTime.day}.${_dateTime.month}.${_dateTime.year}';
int selectedVacationWeekday = _dateTime.weekday;

class _DateForViewPageState extends State<AddVacation> {

  deleteAppointmentsOnSelectedVacation() async {
    await fsc.deleteEntireDay(selectedVacationDate);
  }

  fillAllVacationAppointments() async {
    List workingHours = await fsc.getWorkingTimes(selectedVacationDate);
    await fsc.makeNewAppointment(
        'Admin vacation',
        generateRandomString(10),
        1,
        selectedVacationWeekday.toString(),
        selectedVacationDate,
        workingHours,
        isVacation: true
    );
  }

  addVacation () async {
    QuerySnapshot sameDoc = await FirebaseFirestore.instance.collection('vacations').where('date', isEqualTo: selectedVacationDate).get();
    if (sameDoc.docs.length == 0) {
      await FirebaseFirestore.instance.collection('vacations').add({
        'date': selectedVacationDate,
        'weekday': weekDays[selectedVacationWeekday]
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
          backgroundColor: Colors.black

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _dateTime == null ? 'בחר תאריך ליום חופש' : '${_dateTime.day}.${_dateTime.month}.${_dateTime.year}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25
              ),
            ),
            ElevatedButton(
              child: Text(
                'פתיחת יומן',
                style: TextStyle(
                    fontSize: 20
                ),
              ),
              onPressed: () {
                showDatePicker(
                    context: context,
                    initialDate: _dateTime == null ? DateTime.now() : _dateTime,
                    firstDate: DateTime(2001),
                    lastDate: DateTime(2041)
                ).then((date) {
                  setState(() {
                    _dateTime = date;
                    selectedVacationDate = '${_dateTime.day}.${_dateTime.month}.${_dateTime.year}';
                    selectedVacationWeekday = _dateTime.weekday;
                  });
                });
              },
            ),
            ElevatedButton(
              child: Text(
                'הוסף חופש',
                style: TextStyle(
                    fontSize: 20
                ),
              ),
              onPressed: () async {
                Navigator.pushNamed(context, '/load');
                if (_dateTime == null) return;
                // Delete all appointments on the selected day
                await deleteAppointmentsOnSelectedVacation();
                await fillAllVacationAppointments();
                await addVacation();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            )
          ],
        ),
      ),
    );
  }
}
