import 'package:cloud_firestore/cloud_firestore.dart';

class ContactUserModel {
  final String uid;
  final String phoneNumber;
  List<String> formattedDates;
  int contactTimes = 0;

  ContactUserModel(
      {this.uid,
      this.phoneNumber,
      this.formattedDates, this.contactTimes = 0});

  get editContactTimes {
    contactTimes++;
  }

  void editFormattedDatesList(String date) {
    formattedDates.add(date);
  }
}
