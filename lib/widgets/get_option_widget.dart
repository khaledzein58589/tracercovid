import 'package:flutter/material.dart';

class GetOptionWidget extends StatelessWidget {
  final Function onPressed;
  final String label;

  const GetOptionWidget({Key key, this.onPressed, this.label}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40.0),
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          primary: Colors.cyan,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}