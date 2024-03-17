import 'dart:math';

import 'package:flutter/material.dart';
import 'package:online_lawyer_appointment_system/AllWigtes/Dialog.dart';
import 'package:time_planner/time_planner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddPlaner extends StatefulWidget {
  @override
  _AddPlanerState createState() => _AddPlanerState();
}

class _AddPlanerState extends State<AddPlaner> {
  late List<TimePlannerTask> tasks;
  late Stream<QuerySnapshot> _bookingsStream;

  @override
  void initState() {
    super.initState();
    tasks = [];
    _bookingsStream =
        FirebaseFirestore.instance.collection('bookings').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(
          "Weekly Schedule",
          style: TextStyle(
              fontSize: 17,
              letterSpacing: 2,
              color: Colors.black.withOpacity(0.6)),
        ),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _bookingsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  List<String> timeParts = timeString.split(':');
                  int hour = int.parse(timeParts[0]);
                  int minute = int.parse(timeParts[1]);
                  TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);

                  // Find the difference in days between the header date and the current date
                  DateTime headerDate = parseDate(headers[0].date!);

                  int dayIndex = (dateTime.difference(headerDate).inDays +
                          headerDate.weekday -
                          1) %
                      7;

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You clicked on time planner object'),
                          ),
                        );
                      },
                      child: Text(
                        'Meeting with ${document['clientName']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }
              });

              return TimePlanner(
                startHour: 6,
                endHour: 23,
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
      ),
    );
  }

  // Helper method to generate headers for the TimePlanner
  List<TimePlannerTitle> _generateHeaders() {
    DateTime currentDate = DateTime.now();
    DateTime firstDayOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    List<TimePlannerTitle> headers = [];
    DateFormat dateFormat = DateFormat('MM/dd/yyyy');

    for (int i = 0; i < 7; i++) {
      DateTime day = firstDayOfWeek.add(Duration(days: i));
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
