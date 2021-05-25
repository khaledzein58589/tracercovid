import 'package:covid_tracer/pcrlistview.dart';
import 'package:covid_tracer/pushnotification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:covid_tracer/registration.dart';
import 'package:covid_tracer/uploadpcr.dart';
import 'package:covid_tracer/pcrlistview.dart';
import 'package:covid_tracer/loginpage.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_tracer/widgets/get_option_widget.dart';

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
        primarySwatch: Colors.cyan,
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
  double lat;
  double lng;
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

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
  }

  _locateMe() async {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat("HH:mm:ss").format(now);
    String phone = FirebaseAuth.instance.currentUser.phoneNumber;
    FirebaseFirestore.instance.collection("location").doc().set({
      "phonenumber": '$phone',
      "date": '$date',
      "time": '$time',
      "latitude": '$lat',
      "longitude": '$lng',
    });
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }
    }
    Future.delayed(const Duration(milliseconds: 30000), () {
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
                                    builder: (context) => sendsms()));
                          },
                          label: 'Send  SMS'),
                      GetOptionWidget(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => pcrview()));
                          },
                          label: 'View Pcr'),
                    ],
                  ),
                )
              : CircularProgressIndicator();
        },
      ),
    );
  }
}
