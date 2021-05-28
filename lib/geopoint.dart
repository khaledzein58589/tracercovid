import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math' show acos, atan2, cos, sin, sqrt;
import 'package:vector_math/vector_math.dart';
import 'package:covid_tracer/main.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(geopoint());

}

class geopoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  Position _currentPosition;
  String phone = FirebaseAuth.instance.currentUser.phoneNumber;
  double lat;
  double lng;
  double earthRadius = 3960;
//Using pLat and pLng as dummy location
  double pLat = 33.863259;
  double pLng = 35.4911421;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentPosition != null) Text(
                " $lat,$lng"
            ),

          ],
        ),
      ),
    );
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

      Future.delayed(const Duration(milliseconds: 15000), () {
        setState(() {
         savedata();
         getDistance();
        });
      });
    }).catchError((e) {
      print(e);
    });
  }

  savedata() async {
    DateTime now = DateTime.now();
    String phone = FirebaseAuth.instance.currentUser.phoneNumber;
    String uid = FirebaseAuth.instance.currentUser.uid;
    FirebaseFirestore.instance.collection("location").doc().set({"phonenumber":'$phone',"date":'$now',"latitude": '$lat', "longitude": '$lng',"uid":uid});

  }
  getDistance(){
    var a = cos(radians(pLat)) * cos(radians(lat)) *cos(radians(pLng)) * cos(radians(lng));
    var b = cos(radians(pLat)) * sin(radians(pLng)) *cos(radians(lat)) * sin(radians(lng));
    var c = sin(radians(pLat)) * sin(radians(lat));
    var d = acos(a+b+c) * earthRadius;
    var s =d/0.00062137;
    print(a);
    print(b);
    print(c);
    print(d);
    print(s); //d is the distance in meters

    if(s<2){
      print(phone);
    }
    else {
      print("hello");

    }
  }
}
