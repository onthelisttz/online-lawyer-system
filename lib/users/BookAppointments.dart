import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointments extends StatefulWidget {
  String? lawyerName;
  String? lawyerId;
  BookAppointments({Key? key, required this.lawyerName, required this.lawyerId})
      : super(key: key);

  @override
  State<BookAppointments> createState() => _BookAppointmentsState();
}

TextEditingController titletextEditingController = TextEditingController();
TextEditingController adescriptiontextEditingController =
    TextEditingController();
TextEditingController locationtextEditingController = TextEditingController();
TextEditingController datetextEditingController = TextEditingController();
User? user = FirebaseAuth.instance.currentUser;

class _BookAppointmentsState extends State<BookAppointments> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  bool autoplays = false;
  bool showLoading = false;
  bool showLoadingWidget = false;
  String selectedCountry = 'user';
  bool _loading = false;
  DateTime date = DateTime.now();
  // TimeOfDay? time;
  String currentTime = DateFormat.Hm().format(DateTime.now());
  final User? currentUser = FirebaseAuth.instance.currentUser;

  DateTime timeBackPressed = DateTime.now();

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF009999),
        iconTheme: IconThemeData(color: Colors.white),
        titleSpacing: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child:
              Text('Book Appointment', style: TextStyle(color: Colors.white)),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
            child: Text(
              'Case Title',
              style: TextStyle(
                  fontSize: 14, letterSpacing: 1, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
            child: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: titletextEditingController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                fillColor: Color(0xFF009999),
                filled: true,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  color: Color.fromARGB(255, 177, 237, 237),
                  icon: Icon(
                    Icons.close,
                    size: 16,
                  ),
                  onPressed: () {
                    titletextEditingController.clear();
                  },
                ),
                prefixIcon: Icon(
                  Icons.person,
                  size: 16,
                  color: Color.fromARGB(255, 177, 237, 237),
                ),
                hintStyle: TextStyle(
                    fontSize: 11, letterSpacing: 1, color: Colors.white),
                hintText: "Eg: enter goal",
              ),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Title is required';
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
            child: Text(
              'Description.',
              style: TextStyle(
                  fontSize: 14, letterSpacing: 1, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
            child: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: adescriptiontextEditingController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                fillColor: Color(0xFF009999),
                filled: true,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  color: Color.fromARGB(255, 177, 237, 237),
                  icon: Icon(
                    Icons.close,
                    size: 16,
                  ),
                  onPressed: () {
                    adescriptiontextEditingController.clear();
                  },
                ),
                prefixIcon: Icon(
                  Icons.person,
                  size: 16,
                  color: Color.fromARGB(255, 177, 237, 237),
                ),
                hintStyle: TextStyle(
                    fontSize: 11, letterSpacing: 1, color: Colors.white),
                hintText: "E.g describe the purporse of appointment",
              ),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Description required';
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
            child: Text(
              'Appointment Date.',
              style: TextStyle(
                  fontSize: 14, letterSpacing: 1, color: Colors.black),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
              child: InkWell(
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    // firstDate: DateTime(2024),
                    firstDate: DateTime.now().subtract(Duration(days: 0)),
                    lastDate: DateTime(2100),
                  );
                  if (newDate == null) return;
                  setState(() {
                    date = newDate;
                  });
                },
                child: Container(
                  height: 46.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0xFF009999),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0),
                        topLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14.0, left: 8),
                    child: Text(
                      '${date.day}/ ${date.month}/ ${date.year} ',
                      style: TextStyle(
                          fontSize: 14, letterSpacing: 1, color: Colors.white),
                    ),
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
            child: Text(
              'Appointment Time.',
              style: TextStyle(
                  fontSize: 14, letterSpacing: 1, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
            child: InkWell(
              onTap: () async {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (selectedTime == null) return;
                setState(() {
                  // currentTime = selectedTime;
                  currentTime = '${selectedTime.hour}:${selectedTime.minute}';
                });
              },
              child: Container(
                height: 46.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF009999),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentTime,
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.access_time,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFF009999),
                    ),
                    side: MaterialStateProperty.all(BorderSide(
                      color: Color.fromARGB(255, 177, 237, 237),
                    )),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ))),
                onPressed: _loading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _loading = true;
                          });
                          // registerNewUser(context);
                          requestLawyerAppointment();

                          // Navigator.of(context).push(
                          //     MaterialPageRoute(builder: (BuildContext context) {
                          //   return MyHomePage();
                          // }));
                        }
                      },
                child: _loading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ))
                    : Text(
                        ' Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      )),
          ),
        ]),
      ),
    );
  }

  Future requestLawyerAppointment() async {
    print(currentTime);
// Assuming currentTime is in the format 'HH:mm'

// Convert currentTime to TimeOfDay
    List<String> timeParts = currentTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    TimeOfDay selectedTime = TimeOfDay(hour: hour, minute: minute);

// Define the start and end times for working hours
    TimeOfDay startTime = TimeOfDay(hour: 7, minute: 59);
    TimeOfDay endTime = TimeOfDay(hour: 19, minute: 0);

// Check if the selected time is within working hours
    if (selectedTime.hour < startTime.hour ||
        (selectedTime.hour == startTime.hour &&
            selectedTime.minute < startTime.minute) ||
        selectedTime.hour > endTime.hour ||
        (selectedTime.hour == endTime.hour &&
            selectedTime.minute > endTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Selected time is not within working hours (8:00 AM - 7:00 PM)'),
        ),
      );
      setState(() {
        _loading = false;
      });
      return;
    }

    // if (currentTime != '') {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('You clicked on time planner object'),
    //     ),
    //   );

    //   return;
    // }
    await document.set({
      'id': document.id,
      "date": date,
      "time": currentTime,
      "clientId": user!.uid,
      "clientName": user!.displayName,
      "lawyerName": widget.lawyerName!,
      "lawyerId": widget.lawyerId!,
      "title": titletextEditingController.text,
      "description": adescriptiontextEditingController.text,
      "status": "pending",
      "isNotificationSent": false,
      "isPayed": false,
      "controlNumber": "",
      "PostedAt": FieldValue.serverTimestamp(),
    });
    setState(() {
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booked Successfull'),
      ),
    );
    Navigator.pop(context);
  }

  final document = FirebaseFirestore.instance.collection('bookings').doc();
}
