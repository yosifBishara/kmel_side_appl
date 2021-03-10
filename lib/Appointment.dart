class Appointment {
  String _fullName;
  String _phone_num;
  String _date;
  String _day;
  int _persons;
  List<String> _time;

  Appointment(this._fullName,this._phone_num,this._date,this._day,this._persons,this._time);

  //getter
  String get name => _fullName;
  String get number => _phone_num;
  String get date => _date;
  String get day => _day;
  int get persons => _persons;
  List<String> get time => _time;

  //get map from Appointment object
  Map<String, String> appointmentToMap() {
    var map = Map<String, dynamic>();
    map['name'] = _fullName;
    map['phonenumber'] = _phone_num;
    map['date'] = _date;
    map['day'] = _day;
    map['persons'] = _persons;
    map['time'] = _time;
    return map;
  }

  //get Appointment fro Map object
  Appointment.fromMap(Map<String, dynamic> map){
    this._fullName = map['name'];
    this._phone_num = map['phonenumber'];
    this._date = map['date'];
    this._day = map['day'];
    this._persons = map['persons'];
    this._time = map['time'];
  }

}