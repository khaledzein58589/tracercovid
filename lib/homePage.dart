import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:covid_tracer/registration.dart';
import 'package:covid_tracer/uploadpcr.dart';
import 'package:covid_tracer/geopoint.dart';
import 'package:covid_tracer/loginpage.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        primarySwatch: Colors.blue,
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
    FirebaseFirestore.instance.collection("location").doc().set({"phonenumber":'$phone',"date":'$date',"time":'$time',"latitude": '$lat', "longitude": '$lng',});
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
    await location.getLocation().then((res) {

      lat = res.latitude;
      lng = res.longitude;


    });


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Covid_19 Tracer"),
        backgroundColor: Colors.cyan,
      ),
      body: FutureBuilder(

        future: Future.value(FirebaseAuth.instance.currentUser),
        builder: (context, snapshot) {
          User firebaseUser = snapshot.data;
          return snapshot.hasData
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Welcome  😊",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(

                          onPressed: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => loginpage()
                            ));

                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.cyan,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: Text('---Administration---'),
                        ),

                      ],
                    )),
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(

                          onPressed: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => registration()
                            ));

                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.cyan,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: Text('-----Registration-----'),
                        ),

                      ],
                    )),
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => UploadingImageToFirebaseStorage()
                            ));

                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.cyan,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: Text('---Upload Pcr Test---'),
                        ),

                      ],
                    )),




                Text(
                    "Registered Phone Number: ${firebaseUser.phoneNumber}"),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  onPressed: _logout,
                  child: Text(
                    "LogOut",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.cyan,
                )
              ],
            ),
          )
              : CircularProgressIndicator();
        },
      ),
    );
  }
}


