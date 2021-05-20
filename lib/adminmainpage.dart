import 'package:covid_tracer/main.dart';
import 'package:covid_tracer/ui/listview_note.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracer/publishpcr.dart';
import 'package:covid_tracer/monitorpositive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: MyHomePage1(title: 'Administration '),
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
        title: Text(widget.title),
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
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Administrator Main Page ",
                      style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 30,
                          fontFamily: 'Roboto',
                          fontStyle: FontStyle.italic)),
                  RegisterPet(),
                ]),
          )),
    );
  }
}

class RegisterPet extends StatefulWidget {
  RegisterPet({Key key}) : super(key: key);

  @override
  _RegisterPetState createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  final _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(children: <Widget>[





              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => publishpcr()
                          ));

                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: Text('Publish Pcr Test'),
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
                              builder: (context) => ListViewNote()
                          ));

                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: Text('Publish pcr result'),
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
                              builder: (context) => resultlist()
                          ));

                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        child: Text('Monitor Positive Case'),
                      ),

                    ],
                  )),

            ])));
  }

  @override
  void dispose() {
    super.dispose();

  }
}