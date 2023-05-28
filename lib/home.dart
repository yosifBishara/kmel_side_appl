import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kmel_side_app/fire_s.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FireHelper db = FireHelper();

  deletePrevApps(BuildContext context) async {
    Navigator.pushNamed(context, '/load');
    DateTime today = DateTime.now();
    for (int j=1 ; j < 1000 ; j++) {
      DateTime dayToDelete = today.subtract(Duration(days: j));
      if (dayToDelete.weekday == DateTime.monday) {
        continue;
      }
      QuerySnapshot dayToDeleteDocs = await FirebaseFirestore.instance.collection('appointments').where('date',isEqualTo: '${dayToDelete.day}/${dayToDelete.month}/${dayToDelete.year}').get();
      List<DocumentSnapshot> docs = dayToDeleteDocs.docs;
      if (docs.length == 0) {
        break;
      }
      for(int i=0 ; i < docs.length ; i++){
        await db.deleteApp(docs[i].id);
      }
    }
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                          Navigator.pushNamed(context, '/preViewDate');
                        }, // change this to real function
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'כניסה למערכת תורים',
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, '/currentVacations');
                        }, // change this to real function
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'כניסה למערכת חופשים',
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
