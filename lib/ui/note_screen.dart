import 'package:flutter/material.dart';
import 'package:covid_tracer/model/note.dart';
import 'package:covid_tracer/service/firebase_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
class NoteScreen extends StatefulWidget {
  final Note note;
  NoteScreen(this.note);

  @override
  State<StatefulWidget> createState() => new _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  final _phonenumber  = FirebaseAuth.instance.currentUser.phoneNumber;
  TextEditingController _result;
  TextEditingController _date;
  TextEditingController _status;

  @override
  void initState() {
    super.initState();


    _result = new TextEditingController(text: widget.note.result);
    _date = new TextEditingController(text: widget.note.date);
    _status = new TextEditingController(text: widget.note.status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Note')),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[

            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _result,
              decoration: InputDecoration(labelText: 'result'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _date,
              decoration: InputDecoration(labelText: 'date'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _status,
              decoration: InputDecoration(labelText: 'status'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: (widget.note.id != null) ? Text('Update') : Text('Add'),
              onPressed: () {
                if (widget.note.id != null) {
                  db
                      .updateNote(
                          Note(widget.note.id, _phonenumber, _result.text, _date.text, _status.text))
                      .then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  db.createNote(_phonenumber, _result.text, _date.text, _status.text).then((_) {
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
