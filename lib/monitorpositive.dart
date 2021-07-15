import 'package:covid_tracer/adminmainpage.dart';
import 'package:covid_tracer/service/global_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'covid_contact_cases.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(resultlist());
}

class resultlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor Positive Cases',
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.cyan),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Monitor Positive Cases'),
          centerTitle: true,
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            //onPressed:() => Navigator.pop(context, false),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => adminmainpage()));
            },
          ),
        ),
        body: PaginateFirestore(
          //item builder type is compulsory.
          itemBuilderType: PaginateBuilderType.listView,
          //Change types accordingly
          itemBuilder: (index, context, documentSnapshot) => ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            subtitle: Text(
                '${DateFormat('dd MMMM, yyyy hh:mm aaa').format(DateTime.fromMicrosecondsSinceEpoch(documentSnapshot.data()['date'].microsecondsSinceEpoch))}'),
            title: Text(documentSnapshot.data()['phonenumber']),
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CovidContactCases(
                      phoneNumber: documentSnapshot.data()['phonenumber'],
                    ))),
          ),
          // orderBy is compulsory to enable pagination
          query: FirebaseFirestore.instance
              .collection('pcrpublish')
              .where("result", isEqualTo: true)
              .where("date",
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.now().subtract(Duration(days: covidCasesPreviousDates))))
              .orderBy('date', descending: true),
          // to fetch real-time data
          isLive: true,
          itemsPerPage: 20,
          bottomLoader: Center(
            child: Container(
              width: width / 10,
              height: width / 10,
              child: CircularProgressIndicator(
                strokeWidth: 1,
              ),
            ),
          ),
        ));
  }
}
