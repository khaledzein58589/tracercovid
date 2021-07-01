import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_tracer/service/global_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'covid_contact_user_location_dates.dart';
import 'model/contact_user_model.dart';

class CovidContactCases extends StatefulWidget {
  final String phoneNumber;

  const CovidContactCases({Key key, this.phoneNumber}) : super(key: key);

  @override
  _CovidContactCasesState createState() => _CovidContactCasesState();
}

class _CovidContactCasesState extends State<CovidContactCases> {
  bool isLoading = true;
  List<ContactUserModel> contactUsersList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getMethods(context));

  }

  getMethods(context) async {
    contactUsersList = [];
    setState(() {});
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
    contactUsersList = [];
    positiveCaseLocations.docs.forEach((positiveCaseElement) {
      final positiveCasePhoneNumber = positiveCaseElement.data()['phonenumber'];
      final positiveCaseLatitude = positiveCaseElement.data()['latitude'];
      final positiveCaseLongitude = positiveCaseElement.data()['longitude'];
      final positiveCaseLocationDate =
          positiveCaseElement.data()['date'] as Timestamp;

      /// 4. loop on all locations to make condition on each location with this phone number location
      allLocationsFromThePreviousDates.docs.forEach((otherElement) {
        final otherCasePhoneNumber = otherElement.data()['phonenumber'];
        final otherCaseLatitude = otherElement.data()['latitude'];
        final otherCaseLongitude = otherElement.data()['longitude'];
        final otherCaseLocationDate = otherElement.data()['date'] as Timestamp;

        /// 5. make condition that the positiveCaseElement is other than the otherElement phone number
        if (positiveCasePhoneNumber != otherCasePhoneNumber &&
            positiveCaseLocationDate
                    .toDate()
                    .difference(otherCaseLocationDate.toDate())
                    .inMinutes <
                differenceInMinutesBetweenTwoUsers) {
          /// 6. get the distance between the phone number location and this other location
          if (positiveCaseLatitude != null &&
              positiveCaseLongitude != null &&
              otherCaseLatitude != null &&
              otherCaseLongitude != null) {
            double distanceInMeters = Geolocator.distanceBetween(
                positiveCaseLatitude,
                positiveCaseLongitude,
                otherCaseLatitude,
                otherCaseLongitude);
            if (distanceInMeters < differenceInMetersBetweenTwoUsers) {
              final contactedUser = contactUsersList.firstWhere(
                  (element) => element.phoneNumber == otherCasePhoneNumber,
                  orElse: () => null);
              if (contactedUser != null) {
                if (!contactedUser.formattedDates
                    .contains(getFormattedDate(otherCaseLocationDate.toDate()))) {
                  contactedUser.editContactTimes;
                  contactedUser.editFormattedDatesList(getFormattedDate(otherCaseLocationDate.toDate()));
                }
              } else {
                contactUsersList.add(ContactUserModel(
                    uid: otherElement.data()['uid'],
                    phoneNumber: otherCasePhoneNumber,
                    contactTimes: 1,
                    formattedDates: [getFormattedDate(otherCaseLocationDate.toDate())]));

                FirebaseFirestore.instance.collection("contactcases").doc().set({
                  "phonenumber": '$otherCasePhoneNumber',

                });
              }
            }
          }
        }
      });
    });

    /// sort contact users list by contact times number
    contactUsersList.sort((a, b) => a.contactTimes.compareTo(b.contactTimes));

    /// => end stop loading
    setState(() {
      isLoading = false;

    });
  }

  String getFormattedDate(DateTime date) =>
      '${DateFormat('dd MMMM, yyyy hh:mm aaa').format(date)}';

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
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          /// loading widget
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                )
              :

              /// list of contact cases result
              Row(
                  mainAxisAlignment: contactUsersList.isEmpty
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      width: width,
                      height: height,
                      child: Column(
                        mainAxisAlignment: contactUsersList.isEmpty
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: contactCasesListWidgets(),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  List<Widget> contactCasesListWidgets() {
    List<Widget> returnedList = [];

    if (contactUsersList.isEmpty)
      returnedList.add(Center(
        child: Container(
          width: width / 1.4,
          child: Column(
            children: [
              Text(
                'No contact users with this positive case',
                style: TextStyle(color: Colors.cyan, fontSize: width / 15),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.tag_faces_outlined,
                  size: width / 3,
                ),
              ),
            ],
          ),
        ),
      ));
    else {
      returnedList.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.sentiment_very_dissatisfied,
                  size: width / 5,
                ),
              ),

              GestureDetector(
                onTap: () async {
                  String message = "Hello";
                  List<String> usersPhoneNumbers = [];
                  contactUsersList.forEach((element){
                    usersPhoneNumbers.add(element.phoneNumber);
                  });
                  List<String> recipents = usersPhoneNumbers;
                  await _sendSMS(message, recipents);
                },
                child: Container(
                  width: width/2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white10
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send to All',
                          style: TextStyle(color: Colors.cyan, fontSize: width / 25),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                              Icons.message
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      contactUsersList.reversed.forEach((element) {
        int colorLevel = element.contactTimes > 10 ? 9 : element.contactTimes;
        returnedList.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: ListTile(
            tileColor: Colors.red[colorLevel * 100],
            leading: CircleAvatar(
                child: Text(
              '${element.contactTimes}',
              style: TextStyle(color: Colors.white, fontSize: width / 15),
            )),
            title: Text('${element.phoneNumber}'),
            trailing: Container(
              width: width/4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      String message = "Hello";
                      await _sendSMS(message, [element.phoneNumber]);

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                          Icons.message
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CovidContactUserDates(
                          model: element,
                        ))),
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.0, right: 4.0, bottom: 4),
                      child: Icon(
                          Icons.navigate_next_outlined
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CovidContactUserDates(
                  model: element,
                ))),
          ),
        ));
      });
    }

    return returnedList;
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
  }
}
