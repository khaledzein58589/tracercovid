import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(geopoint());

}

class geopoint extends StatelessWidget {
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

  @override
  void initState() {
    _locateMe();
    super.initState();
  }


  _locateMe() async {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat("HH:mm:ss").format(now);
    String phone = FirebaseAuth.instance.currentUser.phoneNumber;
    FirebaseFirestore.instance.collection("location").doc().set({"phonenumber":'$phone',"date":'$date',"time":'$time',"latitude": '$lat', "longitude": '$lng',});
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }

    }
    Future.delayed(const Duration(milliseconds: 10000), () {

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
    await location.getLocation().then((res) {

      lat = res.latitude;
      lng = res.longitude;


    });

    // Track user Movements
    // location.onLocationChanged.listen((res) {
    //   setState(() {
    //     lat = res.latitude;
    //     lng = res.longitude;
    //   });
    // });
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



          ],
        ),
      ),
    );
  }
}

