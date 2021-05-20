import 'package:covid_tracer/main.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracer/adminmainpage.dart';
void main() {
  runApp(MaterialApp(
    home: loginpage(),
  ));
}

class loginpage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<loginpage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Admin Log In'),
            backgroundColor: Colors.cyan,
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
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Image.network(
                  "https://static.thenounproject.com/png/16970-200.png",
                  height: 200,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.cyan,
                      child: Text('Login'),
                      onPressed: () {
                    if(nameController.text=="khaled" && passwordController.text=="khaled") {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => adminmainpage()
                      ));
                    }
                    else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              // Retrieve the text the user has entered by using the
                              // TextEditingController.
                              content: Text("Username and Password incorrect")
                            );
                          },
                        );
                    }

                    }


                    )),

              ],
            )));
  }
}