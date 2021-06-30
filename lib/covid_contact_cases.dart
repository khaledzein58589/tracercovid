import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_tracer/service/global_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'model/location_model.dart';

class CovidContactCases extends StatefulWidget {
  final String phoneNumber;

  const CovidContactCases({Key key, this.phoneNumber}) : super(key: key);

  @override
  _CovidContactCasesState createState() => _CovidContactCasesState();
}

class _CovidContactCasesState extends State<CovidContactCases> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getMethods(context));
  }

  getMethods(context) async {
    print('phoneNumbereeee iss ${widget.phoneNumber}');

    /// 1. get all locations for this positive case by his phone number
    final positiveCaseLocations = await FirebaseFirestore.instance
        .collection('location')
        .where("phonenumber", isEqualTo: widget.phoneNumber)
        .where("date",
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()
                .subtract(Duration(days: covidContactCasesFromPreviousDates))))
        .orderBy('date', descending: true)
        .get();

    /// 2. get all locations other than this phone number
    final allLocationsFromThePreviousDates = await FirebaseFirestore.instance
        .collection('location')
        .where("date",
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()
                .subtract(Duration(days: covidContactCasesFromPreviousDates))))
        .orderBy('date', descending: true)
        .get();

    /// 3. loop for every location of the positiveCaseLocations list, to make a
    /// condition on every location if it was near any of the other locations in
    /// the allOtherLocations list
    positiveCaseLocations.docs.forEach((positiveCaseElement) {
      print('elementtt ${positiveCaseElement.data()}');

      final positiveCasePhoneNumber = positiveCaseElement.data()['phonenumber'];
      final positiveCaseLatitude = positiveCaseElement.data()['latitude'];
      final positiveCaseLongitude = positiveCaseElement.data()['longitude'];

      /// 4. loop on all locations to make condition on each location with this phone number location
      allLocationsFromThePreviousDates.docs.forEach((otherElement) {
        final otherCasePhoneNumber = otherElement.data()['phonenumber'];
        final otherCaseLatitude = otherElement.data()['latitude'];
        final otherCaseLongitude = otherElement.data()['longitude'];

        /// 5. make condition that the positiveCaseElement is other than the otherElement phone number
        if (positiveCasePhoneNumber != otherCasePhoneNumber) {
          /// 6. get the distance between the phone number location and this other location
          if(positiveCaseLatitude != null && positiveCaseLongitude != null && otherCaseLatitude != null && otherCaseLongitude != null) {
            double distanceInMeters = Geolocator.distanceBetween(
                positiveCaseLatitude, positiveCaseLongitude, otherCaseLatitude, otherCaseLongitude);

            print('distanceInMeters  $distanceInMeters');
            print('otherCasePhoneNumber  $otherCasePhoneNumber');
          }
        }
      });
    });

    /// => end stop loading
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Contact Cases'),
      ),
      body: bodyWidget(),
    );
  }

  Widget bodyWidget() {
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          /// list of contact cases result
          Column(
            children: contactCasesListWidgets(),
          ),

          /// loading widget
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  List<Widget> contactCasesListWidgets() {
    List<Widget> returnedList = [];

    return returnedList;
  }
}
