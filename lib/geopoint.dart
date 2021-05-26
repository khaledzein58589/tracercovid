import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
        primarySwatch: Colors.blue,
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
  double lat;
  double lng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
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
        });
      });
    }).catchError((e) {
      print(e);
    });
  }

  savedata() async {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat("HH:mm:ss").format(now);
    String phone = FirebaseAuth.instance.currentUser.phoneNumber;
    FirebaseFirestore.instance.collection("location").doc().set({"phonenumber":'$phone',"date":'$date',"time":'$time',"latitude": '$lat', "longitude": '$lng',});

  }
}
