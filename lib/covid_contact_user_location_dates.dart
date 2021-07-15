import 'package:covid_tracer/model/contact_user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CovidContactUserDates extends StatelessWidget {
  final ContactUserModel model;

  const CovidContactUserDates({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Contact Cases'),
        backgroundColor: Colors.cyan,
      ),
      body: bodyWidget(),
    );
  }

  Widget bodyWidget() {
    return SingleChildScrollView(
      child: Column(
        children: model.formattedDates.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: ListTile(
            tileColor: Colors.redAccent,
            title: Text(
                '$e'
            ),
          ),
        )).toList(),
      ),
    );
  }
}
