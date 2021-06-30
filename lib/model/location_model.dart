import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String uid;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final Timestamp timestamp;

  LocationModel(
      {this.uid,
      this.phoneNumber,
      this.latitude,
      this.longitude,
      this.timestamp});
}
