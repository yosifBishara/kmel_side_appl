import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kmel_side_app/Appointment.dart';
import 'package:kmel_side_app/date_for_view_page.dart';
import 'firestoreClient.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:kmel_side_app/constants.dart';

Map<String, bool> _selectionsX = {};

class AppView extends StatefulWidget {

  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  List<Appointment> _recipients = [];
  int i = -1;
  Map<String, bool> selectMap = Map<String, bool>();
  DateTime today = DateTime.now();
  // toDay holds the dates that the of which the appointments will be displayed to the salon.
  String toDay = selectedDate;

  void _sendSMS(String message, List recipients) async {
    await FlutterSms.sendSMS(
        message: message, recipients: recipients as List<String>)
        .catchError((onError) {
      print(onError);
    });
  }

  showAlertD(BuildContext context) async {
    Widget yesButton = TextButton(
      child: Text('כן'),
      onPressed: () async {
        List<String> recipientsNums = [];
        for (Appointment r in _recipients) {
          recipientsNums.add(r.number);
        }
        _sendSMS(partialExit, recipientsNums);
        while(_recipients.length != 0) {
          await fsc.deleteAppointment(_recipients[0]);
        }
        _recipients.clear();
        Navigator.pushNamed(context, '/home');
      },
    );

    Widget noButton = TextButton(
      child: Text('לא'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    //alert dialog
    AlertDialog alert = AlertDialog(
      title: Text("!שים לב"),
      content: Text(
          'האם אתה בטוח!!'
      ),
      actions: [
        yesButton,
        noButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.black,
        // automaticallyImplyLeading: false,
        title: Center(child: Text('$toDay - ${weekDays[selectedWeekday] != ' '
            ? weekDays[selectedWeekday]
            : 'שני' }')),
        actions: [
          IconButton(
            icon: Icon(Icons.announcement),
            onPressed: () async {
              if (_recipients.isNotEmpty) {
                showAlertD(context);
              }
            },
          )
        ],
       ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(FireStoreArg.APPOINTMENTS_COLLECTION_ID)
            .doc(selectedDate)
            .collection(FireStoreArg.DAY_APPOINTMENTS_COLLECTION)
            .snapshots(),
        // ignore: missing_return
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("\nCaught an error in the firebase thingie... :| "),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text("\n..נא להמתין"),
            );
          } else {
            _recipients.clear();
            List<QueryDocumentSnapshot> myDocs = snapshot.data.docs;

            myDocs.sort((a, b) {
              int aHour = int.parse(a.id.toString().split(':')[0]),
                  aMin = int.parse(a.id.toString().split(':')[1]),
                  bHour = int.parse(b.id.toString().split(':')[0]),
                  bMin = int.parse(b.id.toString().split(':')[1]);
              return aHour - bHour == 0 ? aMin - bMin : aHour - bHour;
            });

            for (int i = 0; i < myDocs.length; i++) {
              if (_selectionsX.containsKey(myDocs[i].get(FireStoreArg.PHONE_NUM_FIELD)) == false) {
                _selectionsX[myDocs[i].get(FireStoreArg.PHONE_NUM_FIELD)] = false;
              }
              if(_selectionsX[myDocs[i].get(FireStoreArg.PHONE_NUM_FIELD)] && !_recipients.contains(myDocs[i].id)){
                // _recipients.add(myDocs[i].id);
                _recipients.add(Appointment(
                    myDocs[i].get(FireStoreArg.NAME_FIELD),
                    myDocs[i].get(FireStoreArg.PHONE_NUM_FIELD),
                    selectedDate,
                    myDocs[i].get(FireStoreArg.DAY_FIELD),
                    1,
                    [ myDocs[i].id ]
                ));
              }
            }


            return ListView(
              children: myDocs.map((document) {
                return Card(

                  shadowColor: Colors.black,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MediaQuery
                        .of(context)
                        .size
                        .width * 0.015),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Checkbox(
                        tristate: false,
                        value: _selectionsX[document.get(FireStoreArg.PHONE_NUM_FIELD)],
                        onChanged: (bool e) {
                          setState(() {
                            _selectionsX[document.get(FireStoreArg.PHONE_NUM_FIELD)] = !(_selectionsX[document.get(FireStoreArg.PHONE_NUM_FIELD)]);
                            if (e) {
                              if(_recipients.contains(document.get(FireStoreArg.PHONE_NUM_FIELD)) == false) {
                                _recipients.add(Appointment(
                                    document.get(FireStoreArg.NAME_FIELD),
                                    document.get(FireStoreArg.PHONE_NUM_FIELD),
                                    selectedDate,
                                    document.get(FireStoreArg.DAY_FIELD),
                                    1,
                                    [document.id]
                                ));
                              }
                            } else {
                              _recipients.removeWhere(
                                      (element) => (element.number == document.get(FireStoreArg.PHONE_NUM_FIELD)
                                      )
                              );
                            }
                          });
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 8, 2),
                        child: Text(
                          '${document.get(FireStoreArg.NAME_FIELD)} \n ${document.get(FireStoreArg.PHONE_NUM_FIELD)} \n ${document.id}',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 15
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
