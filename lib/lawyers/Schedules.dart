import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_lawyer_appointment_system/AllWigtes/Dialog.dart';
import 'package:online_lawyer_appointment_system/lawyers/addWeeklySchedule.dart';
import 'package:online_lawyer_appointment_system/sharedPages/bookingDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_planner/time_planner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late List<TimePlannerTask> tasks;
  late Stream<QuerySnapshot> _bookingsStream;
  String UserID = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('userId');
    if (userId != null) {
      setState(() {
        UserID = userId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF009999),
          iconTheme: IconThemeData(color: Colors.white),
          titleSpacing: 0,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Monthly Schedule',
              style: TextStyle(
                  fontSize: 17, letterSpacing: 2, color: Colors.white),
            ),
          ),
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.edit_calendar_outlined),
            heroTag: 'add-weely-schedule',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ScheduleForm();
              }));
            }),
        body: UserID != null
            ? Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where("lawyerId", isEqualTo: UserID)
                      .where("status", isEqualTo: 'approved')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // List to store TimePlannerTask objects
                      List<TimePlannerTask> tasks = [];

                      // Generate headers for the TimePlanner
                      List<TimePlannerTitle> headers = _generateHeaders();

                      snapshot.data!.docs.forEach((document) {
                        List<Color?> colors = [
                          Colors.purple,
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.lime[600]
                        ];

                        Timestamp? timestamp = (document.data()
                            as Map<String, dynamic>)['date'] as Timestamp?;
                        String? timeString = (document.data()
                            as Map<String, dynamic>)['time'] as String?;

                        if (timestamp != null && timeString != null) {
                          // Convert timestamp to DateTime
                          DateTime dateTime = timestamp.toDate();

                          // Parse timeString to TimeOfDay
                          // Parse timeString to TimeOfDay
                          List<String> timeParts = timeString.split(':');
                          int hour = int.parse(timeParts[0]);
                          int minute = int.parse(timeParts[1]);
                          TimeOfDay timeOfDay =
                              TimeOfDay(hour: hour, minute: minute);

// Find the difference in months between the header date and the current date
                          DateTime headerDate = parseDate(headers[0].date!);
                          int monthIndex =
                              (dateTime.month - headerDate.month) % 12;

// Calculate the day index based on the month difference
                          DateTime currentMonthDate =
                              DateTime(dateTime.year, dateTime.month, 1);
                          DateTime headerMonthDate =
                              DateTime(headerDate.year, headerDate.month, 1);
                          // int dayIndex =
                          //     currentMonthDate.difference(headerMonthDate).inDays;

                          // DateTime headerDate = parseDate(headers[0].date!);
                          int dayIndex = dateTime.difference(headerDate).inDays;

                          // Example: Add a TimePlannerTask with parsed data
                          tasks.add(
                            TimePlannerTask(
                              color: colors[Random().nextInt(colors.length)],
                              dateTime: TimePlannerDateTime(
                                day: dayIndex,
                                hour: timeOfDay.hour,
                                minutes: timeOfDay.minute,
                              ),
                              minutesDuration: 90,
                              daysDuration: 1,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return BookingDetails(
                                    docId: document["id"],
                                  );
                                }));
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text('You clicked on time planner object'),
                                //   ),
                                // );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Meeting with',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ' ${document['clientName']}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    document['time'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      });

                      return TimePlanner(
                        startHour: 8,
                        endHour: 19,
                        use24HourFormat: false,
                        setTimeOnAxis: false,
                        style: TimePlannerStyle(
                          showScrollBar: true,
                          dividerColor: Color(0xFF009999),

                          // Customize style if needed
                        ),
                        headers: _generateHeaders(),
                        tasks: tasks,
                      );
                    }
                  },
                ),
              )
            : Container());
  }

  List<TimePlannerTitle> _generateHeaders() {
    DateTime currentDate = DateTime.now();
    DateTime firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);

    List<TimePlannerTitle> headers = [];
    DateFormat dateFormat = DateFormat('MM/dd/yyyy');

    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;

    for (int i = 0; i < daysInMonth; i++) {
      DateTime day = firstDayOfMonth.add(Duration(days: i));
      String formattedDate = dateFormat.format(day);
      String dayOfWeek = DateFormat('EEEE').format(day);
      headers.add(TimePlannerTitle(date: formattedDate, title: dayOfWeek));
    }

    return headers;
  }

  DateTime parseDate(String dateString) {
    List<String> dateParts = dateString.split('/');
    int month = int.parse(dateParts[0]);
    int day = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);
    return DateTime(year, month, day);
  }
}
