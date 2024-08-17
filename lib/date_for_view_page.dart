import 'package:flutter/material.dart';

class DateForViewPage extends StatefulWidget {
  @override
  _DateForViewPageState createState() => _DateForViewPageState();
}

DateTime _dateTime = DateTime.now();
String selectedDate = '${_dateTime.day}.${_dateTime.month}.${_dateTime.year}';
int selectedWeekday = _dateTime.weekday;

class _DateForViewPageState extends State<DateForViewPage> {

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
                _dateTime == null ? 'בחר תאריך להצגת תורים' : '${_dateTime.day}.${_dateTime.month}.${_dateTime.year}',
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
                    selectedDate = '${_dateTime.day}.${_dateTime.month}.${_dateTime.year}';
                    selectedWeekday = _dateTime.weekday;
                  });
                });
              },
            ),
            ElevatedButton(
              child: Text(
                'הצג תורים',
                style: TextStyle(
                    fontSize: 20
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/view');
              },
            )
          ],
        ),
      ),
    );
  }
}
