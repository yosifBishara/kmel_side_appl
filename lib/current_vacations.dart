import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CurrentVacations extends StatefulWidget {
  @override
  _CurrentVacationsState createState() => _CurrentVacationsState();
}

class _CurrentVacationsState extends State<CurrentVacations> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Align(
           alignment: Alignment.centerRight,
           child: Text(
                'חופשיים נוכחיים :',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.left
            )
          )
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vacations').snapshots(),
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
            List<QueryDocumentSnapshot> myDocs = snapshot.data.docs;

            myDocs.sort((a, b) {
              List<String> aSplit = a.get('date').split('/'),
                           bSplit = b.get('date').split('/');
              DateTime aTime = DateTime(int.parse(aSplit[2]), int.parse(aSplit[1]), int.parse(aSplit[0])),
                       bTime = DateTime(int.parse(bSplit[2]), int.parse(bSplit[1]), int.parse(bSplit[0]));
              return aTime.compareTo(bTime);
            });

              return Column(

                children: [
                    TextButton(
                        onPressed: () { Navigator.pushNamed(context, '/addVacation'); },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.black)
                        ),
                        child: Text(
                          'הוסף חופש',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70
                          ) ,
                        )
                    ),
                    Expanded(
                      child: ListView(
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
                            IconButton(
                                tooltip: 'delete vacation',
                                onPressed: () async {
                                    await FirebaseFirestore.instance.collection('vacations').doc(document.id).delete();
                                    QuerySnapshot documents = await FirebaseFirestore.instance.collection('appointments').where('date', isEqualTo: document.get('date')).get();
                                    for (int i=0 ; i < documents.docs.length ; i++) {
                                      await FirebaseFirestore.instance.collection('appointments').doc(documents.docs[i].id).delete();
                                    }
                                    await FirebaseFirestore.instance.collection('vacations').doc(document.id).delete();
                                },
                                icon: Icon(Icons.delete_outline_outlined)
                            ),
                            SizedBox(width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.55,),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 2, 8, 2),
                              child: Text(
                                '${document.get('date')}',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  ),
                )
              ]
            );
          }
        },
      )
    );
  }
}
