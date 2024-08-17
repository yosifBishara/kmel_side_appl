import 'package:flutter/material.dart';
import 'firestoreClient.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  deletePrevApps(BuildContext context) async {
    Navigator.pushNamed(context, '/load');
    await fsc.oldAppointmentCleanup();
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
                      child: TextButton(
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
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(color: Colors.grey),
                              )
                          ),
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
                      child: TextButton(
                        onPressed: () async {
                          await deletePrevApps(context);
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
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(color: Colors.grey),
                              )
                          ),
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
