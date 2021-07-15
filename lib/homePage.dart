import 'package:covid_tracer/algorithm.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:covid_tracer/registration.dart';
import 'package:covid_tracer/uploadpcr.dart';
import 'package:covid_tracer/geopoint.dart';
import 'package:covid_tracer/loginpage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show acos, atan2, cos, sin, sqrt;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_tracer/widgets/get_option_widget.dart';
import 'dart:async';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(hpage());
}

class hpage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Page',
      theme: ThemeData(

      ),
      home: MyHomePage(title: 'Main Page '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  Position _currentPosition;
  String phone = FirebaseAuth.instance.currentUser.phoneNumber;
  double lat;
  double lng;
  Timer timer;

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

  }
  _getCurrentLocation() {
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true)
        .then((Position position) {
      Future.delayed(const Duration(milliseconds: 10000), () {
        setState(() {
          _getCurrentLocation();
          _currentPosition = position;
          lat = _currentPosition.latitude;
          lng = _currentPosition.longitude;

        });
      });
      savedata() async {
        DateTime now = DateTime.now();

        String phone = FirebaseAuth.instance.currentUser.phoneNumber;
        String uid = FirebaseAuth.instance.currentUser.uid;
        FirebaseFirestore.instance.collection("location").doc().set({"phonenumber":'$phone',"date":'$now',"latitude": '$lat', "longitude": '$lng',"uid":uid});

      }
      Future.delayed(const Duration(milliseconds: 15000), () {
        setState(() {

        });
      });
    }).catchError((e) {
      print(e);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Welcome ${FirebaseAuth.instance.currentUser?.phoneNumber ?? 'User'}"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
        // backgroundColor: Colors.cyan,
      ),
      body: FutureBuilder(
        future: Future.value(FirebaseAuth.instance.currentUser),
        builder: (context, snapshot) {
          User firebaseUser = snapshot.data;
          return snapshot.hasData
              ? Center(
                  child: GridView.count(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    children: [
                      GetOptionWidget(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => loginpage()));
                          },
                          label: 'Administration'),
                      GetOptionWidget(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => registration()));
                          },
                          label: 'Registration'),
                      GetOptionWidget(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UploadingImageToFirebaseStorage()));
                          },
                          label: 'Upload Pcr Test'),

                      GetOptionWidget(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        geopoint()));
                          },
                          label: 'geo point location'),
                      GetOptionWidget(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GenerateScreen()));
                          },
                          label: 'Qr Code'),
                    ],
                  ),
                )
              : CircularProgressIndicator();
        },
      ),
    );
  }
}
