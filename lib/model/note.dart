class Note {
  String _id;
  String _phonenumber;
  String _result;
  String _date;
  String _status;

  Note(this._id, this._phonenumber, this._result,this._date,this._status);

  Note.map(dynamic obj) {
    this._id = obj['id'];
    this._phonenumber = obj['phonenumber'];
    this._result = obj['result'];
    this._date = obj['date'];
    this._status = obj['status'];
  }

  String get id => _id;
  String get phonenumber => _phonenumber;
  String get result => _result;
  String get date => _date;
  String get status => _status;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['phonenumber'] = _phonenumber;
    map['result'] = _result;
    map['date'] = _date;
    map['status'] = _status;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._phonenumber = map['phonenumber'];
    this._result = map['result'];
    this._date = map['date'];
    this._status = map['status'];
  }
}
