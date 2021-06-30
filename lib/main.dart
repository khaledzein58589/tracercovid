import 'package:covid_tracer/publishpcr.dart';
import 'package:covid_tracer/service/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracer/homePage.dart';
import 'package:covid_tracer/signUpPage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'geopoint.dart';
import 'monitorpositive.dart';
import 'pcrlistview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(scaffoldBackgroundColor: const Color(0xFFEFEFEFF)),
        home: LayoutBuilder(
          builder: (context, constraints){
            width = constraints.maxWidth;
            height = constraints.maxHeight;
            print('width $width');
            print('height $height');
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.hasData) {
                  return hpage();
                } else if (userSnapshot.hasError) {
                  return CircularProgressIndicator();
                }
                return LoginPage();
              },
            );
          },
        ));
  }
}
