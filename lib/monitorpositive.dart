import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
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
      ),
      body: PaginateFirestore(
        //item builder type is compulsory.
        itemBuilderType:
        PaginateBuilderType.listView, //Change types accordingly
        itemBuilder: (index, context, documentSnapshot) => ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text(documentSnapshot.data()['result']),
          subtitle: Text(documentSnapshot.data()['phonenumber']),
        ),
        // orderBy is compulsory to enable pagination
        query: FirebaseFirestore.instance.collection('pcrpublish').where("result", isEqualTo: "Positive").where("status", isEqualTo: "Active"),
        // to fetch real-time data
        isLive: true,
      )
    );
  }
}