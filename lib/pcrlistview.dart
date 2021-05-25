import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_tracer/service/global_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:covid_tracer/main.dart';
import 'package:path/path.dart' as Path;

import 'model/pcr_model.dart';

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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController _datefrom;
  TextEditingController _dateto;
  DateTime _selectedDate;
  List<PcrModel> files = [];
  bool isLoading = false;
  DateTime fromDate;
  DateTime toDate;
  bool isShowFullImage = false;
  String fullImageUrl;

  void _loadImages() async {
    files = [];
    setState(() {
      isLoading = true;
    });

    if (fromDate != null && toDate != null) {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('pcrsend')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(toDate))
          .get();
      data.docs.forEach((element) {
        setState(() {
          isLoading = false;
          files.add(PcrModel(
            id: element.id,
            date: element.data()['date'],
            imageName: element.data()['imagename'],
            imageUrl: element.data()['imageUrl'],
            phoneNumber: element.data()['phonenumber'],
            uid: element.data()['uid'],
          ));
        });
      });
    } else {
      QuerySnapshot data =
          await FirebaseFirestore.instance.collection('pcrsend').get();
      data.docs.forEach((element) {
        setState(() {
          isLoading = false;
          files.add(PcrModel(
            id: element.id,
            date: element.data()['date'],
            imageName: element.data()['imagename'],
            imageUrl: element.data()['imageUrl'],
            phoneNumber: element.data()['phonenumber'],
            uid: element.data()['uid'],
          ));
        });
      });
    }
  }

  void initState() {
    super.initState();
    _datefrom = new TextEditingController();
    _dateto = new TextEditingController();
    _loadImages();
  }

  _selectDate(BuildContext context, {bool isFromDate = true}) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.cyan.withOpacity(.5),
                onPrimary: Colors.black,
                surface: Colors.cyan,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child,
          );
        });
    _selectedDate = newSelectedDate;
    if (newSelectedDate != null && isFromDate) {
      fromDate = _selectedDate;
      _datefrom
        ..text = DateFormat('yyyy-MM-dd').format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _datefrom.text.length, affinity: TextAffinity.upstream));
    } else if (newSelectedDate != null) {
      toDate = _selectedDate;
      _dateto
        ..text = DateFormat('yyyy-MM-dd').format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _dateto.text.length, affinity: TextAffinity.upstream));
    }
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref, PcrModel pcrModelId) async {
    try {
      setState(() {
        isLoading = true;
      });

      var fileUrl = Uri.decodeFull(Path.basename(pcrModelId.imageUrl))
          .replaceAll(new RegExp(r'(\?alt).*'), '');
      final firebaseStorageRef = FirebaseStorage.instance.ref().child(fileUrl);
      await firebaseStorageRef.delete();

      /// delete pcr from firstore collection
      await FirebaseFirestore.instance
          .collection('pcrsend')
          .doc(pcrModelId.id)
          .delete();

      files.remove(pcrModelId);

      // Rebuild the UI
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('eeee $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Check Pcr report'),
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            //onPressed:() => Navigator.pop(context, false),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MyApp()));
            },
          )),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(padding: new EdgeInsets.all(5.0)),
                TextField(
                  controller: _datefrom,
                  decoration: InputDecoration(labelText: 'From Date'),
                  onTap: () {
                    _selectDate(context, isFromDate: true);
                  },
                ),
                TextField(
                  controller: _dateto,
                  decoration: InputDecoration(labelText: 'To Date'),
                  onTap: () {
                    _selectDate(context, isFromDate: false);
                  },
                ),
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () => _loadImages(),
                          child: Text(
                            'Search',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )),
                !isLoading ? showPcrLists() : CircularProgressIndicator(),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: Duration(milliseconds: 600),
            curve: Curves.bounceInOut,
            left: isShowFullImage ? 0 : -width,
            child: Container(
              color: Colors.black,
              height: height,
              width: width,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isShowFullImage = false;
                            });
                          }),
                    ],
                  ),
                  CachedNetworkImage(
                    imageUrl: fullImageUrl,
                    width: width,
                    height: height/1.5,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget showPcrLists() {
    return Expanded(
      child: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final pcrModel = files[index];
          return Card(
            shadowColor: Colors.cyan,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: Container(
                child: CachedNetworkImage(
                  imageUrl: pcrModel.imageUrl,
                  width: width / 6,
                  height: width / 6,
                  imageBuilder: (context, imageProvider) => GestureDetector(
                    onTap: () {
                      setState(() {
                        fullImageUrl = pcrModel.imageUrl;
                        isShowFullImage = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              title: Text(
                pcrModel.phoneNumber ?? 'No phone available',
                style: TextStyle(
                    fontSize: width / 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                getDateTime(pcrModel.date) ?? 'No date available',
                style: TextStyle(fontSize: width / 30),
              ),
              trailing: IconButton(
                onPressed: () => _delete(pcrModel.imageUrl, pcrModel),
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String getDateTime(Timestamp date) {
    DateTime dateTime = date?.toDate();

    return dateTime != null
        ? '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}-${dateTime.minute}'
        : null;
  }
}
