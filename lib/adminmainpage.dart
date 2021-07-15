import 'package:covid_tracer/ui/listview_note.dart';
import 'package:covid_tracer/widgets/get_option_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracer/publishpcr.dart';
import 'package:covid_tracer/monitorpositive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:covid_tracer/pcrlistview.dart';
import 'package:covid_tracer/pushnotification.dart';

import 'homePage.dart';
import 'mainpage.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(adminmainpage());
}

class adminmainpage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Administration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage1(title: 'Administration Page'),
    );
  }
}

class MyHomePage1 extends StatefulWidget {
  MyHomePage1({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState1 createState() => _MyHomePageState1();
}

class _MyHomePageState1 extends State<MyHomePage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: Text(widget.title),
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            //onPressed:() => Navigator.pop(context, false),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => hpage()));
            },
          )),
      body: Center(
          child: GridView.count(
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
            crossAxisCount: 2,
            childAspectRatio: 1,
            children: [
          GetOptionWidget(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => publishpcr()));
              },
              label: 'Publish Pcr Test'),

          GetOptionWidget(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => ListViewNote()));
              },
              label: 'Publish pcr result'),

          GetOptionWidget(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => resultlist()));
              },
              label: 'Monitor Positive Case'),
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
      )),
    );
  }
}