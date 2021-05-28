import 'dart:math' show acos, atan2, cos, sin, sqrt;
import 'package:vector_math/vector_math.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracer/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(
    home: algorithm(),

  ));
}

class algorithm extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<algorithm> {
  double earthRadius = 3960;
//Using pLat and pLng as dummy location
  double pLat = 33.863259;
  double pLat2 = 33.8632582;
  String phonenumber;
  String phone = FirebaseAuth.instance.currentUser.phoneNumber;
  double pLng = 35.4911421;
  double pLng2 = 35.4911438;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manage PCR',

      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
            title: Text('Get Number From Algorithm'),

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

        body: Center(
          child: ListView.builder(

              padding: const EdgeInsets.all(30.0),
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    Divider(height:0),
                    ListTile(
                      title: Text(phonenumber),

                        leading: Icon(Icons.phone_android)


                    ),
                  ],
                );
              }),
        ),

      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getDistance();

  }


  getDistance(){

    var a = cos(radians(pLat)) * cos(radians(pLat2)) *cos(radians(pLng)) * cos(radians(pLng2));
    var b = cos(radians(pLat)) * sin(radians(pLng)) *cos(radians(pLat2)) * sin(radians(pLng2));
    var c = sin(radians(pLat)) * sin(radians(pLat2));
    var d = acos(a+b+c) * earthRadius;
    var s =d/0.00062137;
    print(a);
    print(b);
    print(c);
    print(d);
    print(s); //d is the distance in meters

    setState(() {
      if (s<2) {
        phonenumber=phone;
      }
    });


  }


}





