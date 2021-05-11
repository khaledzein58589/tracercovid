import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracer/service/firebase_firestore_service.dart';

import 'package:covid_tracer/model/note.dart';
import 'package:covid_tracer/main.dart';
import 'package:covid_tracer/ui/note_screen.dart';

class ListViewNote extends StatefulWidget {
  @override
  _ListViewNoteState createState() => new _ListViewNoteState();
}

class _ListViewNoteState extends State<ListViewNote> {
  List<Note> items;
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  StreamSubscription<QuerySnapshot> noteSub;

  @override
  void initState() {
    super.initState();

    items = new List();

    noteSub?.cancel();
    noteSub = db.getNoteList().listen((QuerySnapshot snapshot) async {
      final List<Note> notes = snapshot.docs
          .map((documentSnapshot) => Note.fromMap(documentSnapshot.data()))
          .toList();


      setState(() {
        this.items = notes;
      });
    });
  }

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage PCR',
      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
            title: Text('Manage PCR'),
            automaticallyImplyLeading: true,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            leading: IconButton(icon:Icon(Icons.arrow_back),
              //onPressed:() => Navigator.pop(context, false),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MyApp()
                ));

              },
            )
        ),

        body: Center(
          child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(15.0),
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    Divider(height: 40.0),
                    ListTile(
                      title: Row(
                          children: <Widget>[

                            Expanded(child: Text('${items[position].phonenumber}')),
                            Expanded(child: Text('${items[position].date}')),
                            Expanded(child: Text('${items[position].status}')),

                          ]
                      ),
                      subtitle: Text(
                        '${items[position].result}',
                style: TextStyle(
                fontSize: 22.0,
                color: Colors.deepOrangeAccent,
                ),

                      ),
                      leading: Column(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(2.0)),
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 0.0,
                            child: Text(
                              '${position + 1}',
                              style: TextStyle(
                                fontSize: 5.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(2.0)),
                          IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _deleteNote(context, items[position], position)),
                        ],
                      ),
                      onTap: () => _navigateToNote(context, items[position]),
                    ),
                  ],
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _createNewNote(context),
        ),
      ),
    );
  }

  void _deleteNote(BuildContext context, Note note, int position) async {
    db.deleteNote(note.id).then((notes) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToNote(BuildContext context, Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteScreen(note)),
    );
  }

  void _createNewNote(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteScreen(Note(null, '', '','',''))),
    );
  }
}
