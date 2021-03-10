import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kmel_side_app/fire_s.dart';
import 'package:flutter_sms/flutter_sms.dart';


// Map<String, dynamic> _selections = {};
Map<String, bool> _selectionsX = {};

class AppView extends StatefulWidget {

  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  // List<bool> mySelect = selected ;
  List<String> _recipients = [];
  int i = -1;
  static bool firstTime = true;
  Map<String, bool> selectMap = Map<String, bool>();
  FireHelper db = FireHelper();
  DateTime today = DateTime.now();
  String toDay = '${DateTime
      .now()
      .day}/${DateTime
      .now()
      .month}/${DateTime
      .now()
      .year}';
  List<String> weekDays = [
    'ראשון',
    ' ',
    'שלישי',
    'רביעי',
    'חמישי',
    'שישי',
    'שבת',
    'ראשון',
    ' ',
    'שלישי',
    'רביעי',
    'חמישי',
    'שישי',
    'שבת'
  ];
  String emergencyExitMessage = "קמיל בשארה - הודעה חשובה!" + "\n"
      + "الزبون الكريم, سيتم اغلاق الصالون حتى نهاية اليوم لاسباب ضرورية." +
      "\n"
      + "للاسف, تم الغاء دورك ويجب عليك حجز دور جديد." + "\n"
      + "اذا وصلك تذكير للدور الملغي الرجاء تجاهلا." + "\n"
      + "المعذرة." + "\n" + "   ----------    " + "\n"
      + "לקוח יקר, הסלון ייסגר לסיבות דחופות היום מהשעה הנוכחית עד סוף היום." +
      "\n"
      + "לצערנו, התור שלך מבוטל והינך דרוש לקבוע תור מחדש." + "\n"
      + "נא להתעלם מכל תזכורת ששייכת לתור שבוטל." + "\n"
      "עמכם הסליחה.";
  String partialExit = "קמיל בשארה - הודעה חשובה!" + "\n"
      + "الزبون الكريم, سيتم اغلاق الصالون خلال ساعة حجزك لاسباب ضرورية." + "\n"
      + "للاسف, تم الغاء دورك ويجب عليك حجز دور جديد." + "\n"
      + "اذا وصلك تذكير للدور الملغي الرجاء تجاهله." + "\n"
      + "المعذرة." + "\n" + "   ----------    " + "\n"
      + "לקוח יקר, הסלון ייסגר לסיבות דחופות היום בשעה שקבעת לתורך." + "\n"
      + "לצערנו, התור שלך מבוטל והינך דרוש לקבוע תור מחדש." + "\n"
      + "נא להתעלם מכל תזכורת ששייכת לתור שבוטל." + "\n"
      "עמכם הסליחה.";


  // Future<List<bool>> mmmmFunction() async{
  //   mySelect=[];
  //   int docs_num_today = await db.initSelectedNum();
  //
  //   for(int i=0 ; i < docs_num_today ; i++){
  //     mySelect.add(false);
  //     print(i);
  //   }
  //   return mySelect;
  // }


  void _sendSMS(String message, List<String> recipents) async {
    String _result = await FlutterSms.sendSMS(
        message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
  }

  showAlertDialog(BuildContext context) async {
    //2 buttons
    Widget yesButton = FlatButton(
      child: Text('כן'),
      onPressed: () async {
        Navigator.pushNamed(context, '/load');
        _recipients.clear();
        QuerySnapshot res = await FirebaseFirestore.instance.collection(
            'appointments').where('date', isEqualTo: toDay).get();
        List<DocumentSnapshot> docs = res.docs;
        for (int i = 0; i < docs.length; i++) {
          DateTime currTime = DateTime(today.year, today.month, today.day,
              int.parse(docs[i].get('time')[0].toString().split(':')[0]),
              int.parse(docs[i].get('time')[0].toString().split(':')[1]));
          if (currTime.isAfter(today)) {
            _recipients.add(docs[i].id);
          }
          // await db.deleteApp(docs[i].id);
        }
        Navigator.of(context).pop();
        _sendSMS(emergencyExitMessage, _recipients);
        Navigator.pushNamed(context, '/home');
        for (int i = 0; i < docs.length; i++) {
          await db.deleteApp(docs[i].id);
        }
      },
    );

    Widget noButton = FlatButton(
      child: Text('לא'),
      onPressed: () {
        Navigator.pushNamed(context, '/view');
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

  showAlertD(BuildContext context) async {
    Widget yesButton = FlatButton(
      child: Text('כן'),
      onPressed: () async {
        _sendSMS(partialExit, _recipients);
        print(_recipients);
        while(_recipients.length != 0) {
          await db.deleteApp(_recipients[0]);
          // print(i);
          print(_recipients);
        }
        _recipients.clear();
        Navigator.pushNamed(context, '/home');
      },
    );

    Widget noButton = FlatButton(
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
    // print(mySelect);


    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.black,
        // automaticallyImplyLeading: false,
        title: Center(child: Text('$toDay - ${weekDays[today.weekday] != ' '
            ? weekDays[today.weekday]
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
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //send messages to all appointments left today,
          //go to home page
          showAlertDialog(context);
          //_sendSMS(emergencyExitMessage, recipients);
        },
        backgroundColor: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Center(child: Text('סיים \n יום')),
        ),


      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('appointments').where(
            "date", isEqualTo: toDay).snapshots(),
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
              int a_hour = int.parse(a.get('time')[0].toString().split(':')[0]),
                  a_min = int.parse(a.get('time')[0].toString().split(':')[1]),
                  b_hour = int.parse(b.get('time')[0].toString().split(':')[0]),
                  b_min = int.parse(b.get('time')[0].toString().split(':')[1]);
              print(myDocs.length);
              return a_hour - b_hour == 0 ? a_min - b_min : a_hour - b_hour;
            });

            for (int i = 0; i < myDocs.length; i++) {
              if (_selectionsX.containsKey(myDocs[i].id) == false) {
                // _selections[myDocs[i].id] =
                //     StreamCard(docc: myDocs[i], recc: recipients,);
                _selectionsX[myDocs[i].id] = false;
              }
              if(_selectionsX[myDocs[i].id] && !_recipients.contains(myDocs[i].id)){
                _recipients.add(myDocs[i].id);
              }
            }
            // print(_selectionsX);


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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        tristate: false,
                        value: _selectionsX[document.id] ,
                        onChanged: (bool e) {
                          setState(() {
                            _selectionsX[document.id] = !(_selectionsX[document.id]);
                            if (e) {
                              if(_recipients.contains(document.id) == false) {
                                _recipients.add(document.id);
                              }
                            } else {
                              _recipients.remove(document.id);
                            }
                            print(_recipients);
                          });
                        },
                      ),
                      SizedBox(width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.55,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 8, 2),
                        child: Text(
                          '${document.get('name')} \n ${document
                              .id} \n ${document.get('time')[0]} \n ${document
                              .get('persons')} אנשים  ',
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
