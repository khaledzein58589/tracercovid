
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(registration());
}


class registration extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage1(title: 'Registration '),
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
      ),
      body: Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Please Register Here ",
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
  final listOfprovince = ["Akkar", "Baalbak", "Beirut","Bequaa","Mount Lebanon","Nabatieh","North","South"];
  String dropdownValueprovince = 'Akkar';

  final listOfcaza = ["Akkar", "Baalbak", "Hermel","Beirut","Rashaya","Western Bequaa","Zahleh","Aley","Baabda","Byblos","Chouf","Keserwan","Matn","Bint Jbeil","Hasbaya","Marjeyoun","Nabatieh","Batroun","Bsharri","Koura","Miniyeh-Dannieh","Tripoli","Zgharta","Sidon","Jezzine","Tyre"];
  String dropdownValuecaza = 'Akkar';

  final nameController = TextEditingController();
  final phoneController = FirebaseAuth.instance.currentUser.phoneNumber;
  final villageController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Enter Full Name",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter Full Name';
                    }
                    return null;
                  },
                ),
              ),


              Padding(
                padding: EdgeInsets.all(20.0),
                child: DropdownButtonFormField(
                  value: dropdownValueprovince,
                  icon: Icon(Icons.arrow_downward),
                  decoration: InputDecoration(
                    labelText: "Select Province",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: listOfprovince.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValueprovince = newValue;
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Select Province';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: DropdownButtonFormField(
                  value: dropdownValuecaza,
                  icon: Icon(Icons.arrow_downward),
                  decoration: InputDecoration(
                    labelText: "Select Caza",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: listOfcaza.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValuecaza = newValue;
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Select Caza';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: villageController,
                  decoration: InputDecoration(
                    labelText: "Enter Village",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter Village';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc()
                                .set({
                              "fullname": nameController.text,
                              "phonenumber": phoneController,
                              "province": dropdownValueprovince,
                              "caza": dropdownValuecaza,
                              "village": villageController.text,
                            }).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Successfully Added')));

                              nameController.clear();
                              villageController.clear();
                            }).catchError((onError) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(onError)));
                            });
                          }
                        },
                        child: Text('Submit'),
                      ),

                    ],
                  )),
            ])));
  }

  @override
  void dispose() {
    super.dispose();

    nameController.dispose();
    villageController.dispose();
  }
}