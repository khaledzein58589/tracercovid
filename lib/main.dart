import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() {

  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'codesundar',
      theme: ThemeData(
          appBarTheme:
          AppBarTheme(centerTitle: true, color: Colors.black, elevation: 0),
          scaffoldBackgroundColor: Colors.grey[200]),
      home: SafeArea(child: HomePage()),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  double lat;
  double lng;
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;




  _locateMe() async {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat("HH:mm:ss").format(now);
    FirebaseFirestore.instance.collection("location").doc().set({"phonenumber":'76158589',"date":'$date',"time":'$time',"latitude": '$lat', "longitude": '$lng',});
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }

    }
    Future.delayed(const Duration(milliseconds: 20000), () {

// Here you can write your code

      setState(() {
        _locateMe();
      });

    });
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {

        return;
      }
    }


    // Track user Movements
     location.onLocationChanged.listen((res) {
    setState(() {
    lat = res.latitude;
    lng = res.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geolocation"),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text("Lat: $lat, Lng: $lng"),
              ),
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                child: Text("Locate Me"),
                onPressed: () => _locateMe(),
              ),
            ),


          ],
        ),
      ),
    );
  }
}

