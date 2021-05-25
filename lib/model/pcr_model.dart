import 'package:cloud_firestore/cloud_firestore.dart';

class PcrModel {
  final String id;
  final String phoneNumber;
  final String uid;
  final Timestamp date;
  final String imageUrl;
  final String imageName;

  PcrModel(
      {this.id, this.phoneNumber, this.uid, this.date, this.imageUrl, this.imageName});
}
