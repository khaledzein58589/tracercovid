import 'package:flutter/material.dart';
import 'package:covid_tracer/model/note.dart';
import 'package:covid_tracer/service/firebase_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
class NoteScreen extends StatefulWidget {
  final Note note;
  NoteScreen(this.note);

  @override
  State<StatefulWidget> createState() => new _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  FirebaseFirestoreService db = new FirebaseFirestoreService();


  TextEditingController _phonenumber;
  TextEditingController _result;
  TextEditingController _date;
  TextEditingController _status;
  DateTime _selectedDate;
  @override
  void initState() {
    super.initState();

    _phonenumber = new TextEditingController(text: widget.note.phonenumber);
    _result = new TextEditingController(text: widget.note.result);
    _result.text = 'Positive';
    _date = new TextEditingController(text: widget.note.date);

  }
  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                surface: Colors.blueGrey,
                onSurface: Colors.yellow,
              ),
              dialogBackgroundColor: Colors.blue[500],
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _date
        ..text =DateFormat('yyyy-MM-dd').format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _date.text.length,
            affinity: TextAffinity.upstream));
    }
  }
  @override
  Widget build(BuildContext context) {
    final listOfstatus = ["Active","Inactive"];
    String dropdownValuestatus = 'Active';
    return Scaffold(
      appBar: AppBar(title: Text('Add/Update results')),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[

            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _phonenumber,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _result,
              decoration: InputDecoration(labelText: 'result'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _date,
              decoration: InputDecoration(labelText: 'date'),
              
              onTap: () {
                _selectDate(context);
              },
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: DropdownButtonFormField(
                value: dropdownValuestatus,
                icon: Icon(Icons.arrow_downward),

                items: listOfstatus.map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValuestatus = newValue;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Select Status';
                  }
                  return null;
                },
              ),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: (widget.note.id != null) ? Text('Update') : Text('Add'),
              onPressed: () {
                if (widget.note.id != null) {
                  db
                      .updateNote(
                          Note(widget.note.id, _phonenumber.text, _result.text, _date.text, dropdownValuestatus))
                      .then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  db.createNote(_phonenumber.text, _result.text, _date.text, dropdownValuestatus).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}



