import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookAppointments extends StatefulWidget {
  String? lawyerName;
  String? lawyerId;
  BookAppointments({Key? key, required this.lawyerName, required this.lawyerId})
      : super(key: key);

  @override
  State<BookAppointments> createState() => _BookAppointmentsState();
}

TextEditingController titletextEditingController = TextEditingController();
TextEditingController descriptiontextEditingController =
    TextEditingController();
TextEditingController locationtextEditingController = TextEditingController();
TextEditingController datetextEditingController = TextEditingController();
// User? user = FirebaseAuth.instance.currentUser;

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
  String currentTime = DateFormat.Hm().format(DateTime.now());
  DateTime timeBackPressed = DateTime.now();

  TextEditingController _controller = TextEditingController();
  String userName = "";
  String UserID = "";
  final Map<String, TimeRange?> _schedule = {};
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  TimeRange? selectedDayWorkingHours;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchScheduleData();
    clearFormData();
  }

  clearFormData() {
    titletextEditingController.clear();
    descriptiontextEditingController.clear();
    locationtextEditingController.clear();
    datetextEditingController.clear();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('userId');
    if (userId != null) {
      setState(() {
        UserID = userId;
      });
    }

    String? userNames = prefs.getString('userName');

    if (userNames != null) {
      setState(() {
        userName = userNames;
      });
    }
  }

  bool isDateSelectable(DateTime day) {
    // Disable previous dates
    if (day.isBefore(DateTime.now())) {
      return false;
    }

    String dayName = DateFormat('EEEE').format(day);
    if (_schedule.isNotEmpty && !_schedule.containsKey(dayName)) {
      return false;
    }

    TimeRange? workingHours = _schedule[dayName];
    if (_schedule.isNotEmpty && workingHours == null) {
      return false;
    }

    return true;
  }

  Future<void> _fetchScheduleData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot scheduleSnapshot = await firestore
        .collection('schedules')
        .where('lawyerId', isEqualTo: widget.lawyerId)
        .limit(1)
        .get();

    if (scheduleSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> scheduleData = (scheduleSnapshot.docs.first.data()
          as Map<String, dynamic>)['schedule'];

      setState(() {
        scheduleData.forEach((key, value) {
          _schedule[key] = TimeRange(
            openingTime: TimeOfDay(
              hour: int.parse(value['openingTime'].split(':')[0]),
              minute: int.parse(value['openingTime'].split(':')[1]),
            ),
            closingTime: TimeOfDay(
              hour: int.parse(value['closingTime'].split(':')[0]),
              minute: int.parse(value['closingTime'].split(':')[1]),
            ),
          );
        });
      });
      print(scheduleData);
    }
  }

  Future<DateTime> getValidInitialDate(DateTime initialDate) async {
    while (!isDateSelectable(initialDate)) {
      initialDate = initialDate.add(const Duration(days: 1));
    }
    return initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF009999),
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          centerTitle: true,
          title: const Padding(
            padding: EdgeInsets.only(left: 8),
            child:
                Text('Book Appointment', style: TextStyle(color: Colors.white)),
          ),
          elevation: 0,
        ),
        body: UserID != null
            ? Form(
                key: _formKey,
                child: ListView(children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 18, left: 18, right: 18),
                    child: Text(
                      'Case Title',
                      style: TextStyle(
                          fontSize: 14, letterSpacing: 1, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: titletextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFF009999),
                        filled: true,
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          color: const Color.fromARGB(255, 177, 237, 237),
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                          ),
                          onPressed: () {
                            titletextEditingController.clear();
                          },
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          size: 16,
                          color: Color.fromARGB(255, 177, 237, 237),
                        ),
                        hintStyle: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            color: Colors.white),
                        hintText: "Eg: enter goal",
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Title is required';
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 18, left: 18, right: 18),
                    child: Text(
                      'Description.',
                      style: TextStyle(
                          fontSize: 14, letterSpacing: 1, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: descriptiontextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFF009999),
                        filled: true,
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          color: const Color.fromARGB(255, 177, 237, 237),
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                          ),
                          onPressed: () {
                            descriptiontextEditingController.clear();
                          },
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          size: 16,
                          color: Color.fromARGB(255, 177, 237, 237),
                        ),
                        hintStyle: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            color: Colors.white),
                        hintText: "E.g describe the purporse of appointment",
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Description required';
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 18, left: 18, right: 18),
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
                        DateTime initialDate = await getValidInitialDate(date);
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 0)),
                          lastDate: DateTime(2100),
                          selectableDayPredicate: isDateSelectable,
                        );
                        if (newDate == null) return;

                        setState(() {
                          date = newDate;
                          String dayName = DateFormat('EEEE').format(newDate);
                          selectedDayWorkingHours = _schedule[dayName];
                        });
                      },
                      child: Container(
                        height: 46.0,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF009999),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14.0, left: 8),
                          child: Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (selectedDayWorkingHours != null) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 18, left: 18, right: 18),
                      child: Text(
                        'Working Hours: ${selectedDayWorkingHours!.openingTime.format(context)} - ${selectedDayWorkingHours!.closingTime.format(context)}',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.only(top: 18, left: 18, right: 18),
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
                          currentTime =
                              '${selectedTime.hour}:${selectedTime.minute}';
                        });
                      },
                      child: Container(
                        height: 46.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF009999),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentTime,
                                style: const TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF009999),
                            ),
                            side: MaterialStateProperty.all(const BorderSide(
                              color: Color.fromARGB(255, 177, 237, 237),
                            )),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),
                        onPressed: _loading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  requestLawyerAppointment();
                                }
                              },
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ))
                            : const Text(
                                ' Request',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              )),
                  ),
                ]),
              )
            : Container());
  }

  Future requestLawyerAppointment() async {
    List<String> timeParts = currentTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    TimeOfDay selectedTime = TimeOfDay(hour: hour, minute: minute);

    // Check if the schedule is not empty and get the working hours for the selected day
    if (selectedDayWorkingHours != null) {
      TimeOfDay openingTime = selectedDayWorkingHours!.openingTime;
      TimeOfDay closingTime = selectedDayWorkingHours!.closingTime;

      // Check if the selected time is within the working hours
      if ((selectedTime.hour < openingTime.hour ||
              (selectedTime.hour == openingTime.hour &&
                  selectedTime.minute < openingTime.minute)) ||
          (selectedTime.hour > closingTime.hour ||
              (selectedTime.hour == closingTime.hour &&
                  selectedTime.minute > closingTime.minute))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Selected time is not within working hours (${openingTime.format(context)} - ${closingTime.format(context)})'),
          ),
        );
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    // else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('No working hours available for the selected day'),
    //     ),
    //   );
    //   setState(() {
    //     _loading = false;
    //   });
    //   return;
    // }

    await document.set({
      'id': document.id,
      "date": date,
      "time": currentTime,
      "clientId": UserID,
      "clientName": userName,
      "lawyerName": widget.lawyerName!,
      "lawyerId": widget.lawyerId!,
      "title": titletextEditingController.text,
      "description": descriptiontextEditingController.text,
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
        content: Text('Booked Successfully'),
      ),
    );

    Navigator.pop(context);
  }

  final document = FirebaseFirestore.instance.collection('bookings').doc();
}

class TimeRange {
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;

  TimeRange({required this.openingTime, required this.closingTime});
}
