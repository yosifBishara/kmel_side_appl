import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kmel_side_app/fire_s.dart';

// Map<String,bool> selectedMap = Map<String, bool>();
// List<bool> selected = [];


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FireHelper db = FireHelper();

  deletePrevApps(BuildContext context) async {
    Navigator.pushNamed(context, '/load');
    DateTime yDay = DateTime.now().subtract(Duration(days: 1));
    QuerySnapshot yesterdayDocs = await FirebaseFirestore.instance.collection('appointments').where('date',isEqualTo: '${yDay.day}/${yDay.month}/${yDay.year}').get();
    List<DocumentSnapshot> docs = yesterdayDocs.docs;
    for(int i=0 ; i < docs.length ; i++){
      await db.deleteApp(docs[i].id);
    }
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.grey[800],
        body: Container(
          width: MediaQuery.of(context).size.width * 0.98,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              children: <Widget>[

                //logo picture
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,25,10,10),
                  child: Image.asset('./assets/kmel1-06.png'),
                ),

                //appointment btn
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () async {

                          await deletePrevApps(context);


                            // int docs_num_today = await db.initSelectedNum();
                            // selected=List<bool>();
                            // for(int i=0 ; i < docs_num_today ; i++){
                            //   selected.add(false);
                            //   print(i);
                            // }



                          Navigator.pushNamed(context, '/view');
                        }, // change this to real function
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'כניסה למערכת',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),


                  ],
                ),






              ],
            ),
          ),
        ),

      ),
    );
  }
}
