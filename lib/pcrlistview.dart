import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:covid_tracer/main.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(pcrview());

}

class pcrview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Kindacode.com',
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController _datefrom;
  TextEditingController _dateto;
  DateTime _selectedDate;

  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();

      files.add({
        "imageUrl": fileUrl,


      });
    });

    return files;
  }
  void initState() {
    super.initState();
    _datefrom = new TextEditingController();
    _dateto = new TextEditingController();

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
      _datefrom
        ..text =DateFormat('yyyy-MM-dd').format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _datefrom.text.length,
            affinity: TextAffinity.upstream));
    }
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _dateto
        ..text =DateFormat('yyyy-MM-dd').format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _dateto.text.length,
            affinity: TextAffinity.upstream));
    }
  }
  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Pcr report'),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _datefrom,
              decoration: InputDecoration(labelText: 'From Date'),
              onTap: () {
                _selectDate(context);
              },
            ),
            TextField(
              controller: _dateto,
              decoration: InputDecoration(labelText: 'To Date'),
              onTap: () {
                _selectDate(context);
              },
            ),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {

                      },
                      child: Text('Search'),
                    ),

                  ],
                )),
            Expanded(
              child: FutureBuilder(
                future: _loadImages(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        final image = snapshot.data[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                                height: 50,
                                child: Image.network(image['imageUrl'],
                                    )
                            ),
                            title: Text("Phone"),
                            subtitle: Text("Date"),
                            trailing: IconButton(
                              onPressed: () => _delete(image['path']),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}