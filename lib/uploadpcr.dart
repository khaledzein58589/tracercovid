import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:covid_tracer/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(UploadingImageToFirebaseStorage());
}



final Color green = Colors.blueAccent;
final Color orange = Colors.blueAccent;
final phoneController  = FirebaseAuth.instance.currentUser.phoneNumber;
final uid  = FirebaseAuth.instance.currentUser.uid;
class UploadingImageToFirebaseStorage extends StatefulWidget {

  @override
  _UploadingImageToFirebaseStorageState createState() =>
      _UploadingImageToFirebaseStorageState();
}

class _UploadingImageToFirebaseStorageState
    extends State<UploadingImageToFirebaseStorage> {
  File _imageFile;
  String imageUrl;
  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_imageFile.path);
    final _firebaseStorage = FirebaseStorage.instance;
    PickedFile image;
    String uid = FirebaseAuth.instance.currentUser.uid;
    DateTime now = DateTime.now();

    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('$fileName');
    var snapshot = await _firebaseStorage.ref()
        .child('$fileName')
        .putFile(_imageFile);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadUrl;
    });
    FirebaseFirestore.instance
        .collection("pcrsend")
        .doc(uid)
        .set({
      "date": now,
      "uid":uid,
      "phonenumber":  phoneController,
      "imagename": fileName,
      "imageUrl":imageUrl,


    });

    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
          title: Text('Upload Pcr Report Signed'),
          automaticallyImplyLeading: true,
          backgroundColor: Colors.cyan,
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
      body: Stack(
        children: <Widget>[
          Container(
            height: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(250.0),
                    bottomRight: Radius.circular(10.0)),
                gradient: LinearGradient(
                    colors: [Colors.cyan, Colors.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
          ),
          Container(
            margin: const EdgeInsets.only(top: 80),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child:  Image.network(
                      "https://cdn2.iconfinder.com/data/icons/covid-19-60/256/Corona-test-sample-swab-512.png",
                      height: 200,
                    ),

                  ),

                ),

                SizedBox(height: 20.0),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: _imageFile != null
                              ? Image.file(_imageFile)
                              : FlatButton(
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.cyan,
                              size: 50,
                            ),
                            onPressed: pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                uploadImageButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadImageButton(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            padding:
            const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            margin: const EdgeInsets.only(
                top: 30, left: 20.0, right: 20.0, bottom: 20.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan, Colors.cyan],
                ),
                borderRadius: BorderRadius.circular(30.0)),
            child: FlatButton(

              onPressed: () {
                uploadImageToFirebase(context);
                toast();
              },

              child: Text(
                "Upload Pcr",
                style: TextStyle(fontSize: 20,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  toast() {
    Fluttertoast.showToast(
        msg: "Upload Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1
    );
  }
}
/*
if request.auth != null*/