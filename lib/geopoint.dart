import 'dart:async';

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
  String uid = FirebaseAuth.instance.currentUser.uid;
  double lat;
  double lng;
  double earthRadius = 3960;

//Using pLat and pLng as dummy location
  double pLat = 33.863249;
  double pLng = 35.4911421;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getMethods(context));
  }

  getMethods(context) async{
    /// 1. get the location position
    final position = await _determinePosition();
    print('possss $position');

    /// 2. assign variables of lat and lng to show result in this page
    setState(() {
      print('fatt 333 $position');
      _currentPosition = position;
      lat = _currentPosition.latitude;
      lng = _currentPosition.longitude;
    });

    /// 3. save the location with the phone number of the user in the firestore
    await saveData();
    // getDistance();

    /// 4. wait 10 sec to get the new current location of the my phone
    Future.delayed(const Duration(seconds: 10), () async {
      getMethods(context);
    });
  }

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
            if (_currentPosition != null) Text(" $lat,$lng"),
          ],
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> saveData() async {
    print('woselll');
    FirebaseFirestore.instance.collection("locations").doc().set({
      "phonenumber": '$phone',
      "uid": uid,
      "date": Timestamp.fromDate(DateTime.now()),
      "latitude": lat,
      "longitude": lng,
    });
  }

  double getDistance() {
    double a = cos(radians(pLat)) *
        cos(radians(lat)) *
        cos(radians(pLng)) *
        cos(radians(lng));
    double b = cos(radians(pLat)) *
        sin(radians(pLng)) *
        cos(radians(lat)) *
        sin(radians(lng));
    double c = sin(radians(pLat)) * sin(radians(lat));
    double d = acos(a + b + c) * earthRadius;
    double s = d / 0.00062137;
    print(a);
    print(b);
    print(c);
    print(d);
    print(s); //d is the distance in meters

    if (s < 2) {
      print(phone);
    } else {
      print("hello");
    }
    return s;
  }
}
