import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleForm extends StatefulWidget {
  @override
  _ScheduleFormState createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
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

  String UserID = "";
  bool _loading = false;

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

      // Check if the user has an existing schedule
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot scheduleSnapshot = await firestore
          .collection('schedules')
          .where('lawyerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (scheduleSnapshot.docs.isNotEmpty) {
        print("SCHEDULE AVAILABLEEEEEEEEE");
        // If the user has an existing schedule, populate the _schedule map
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
          child: Text(
            'Weekly Schedule',
            style:
                TextStyle(fontSize: 17, letterSpacing: 2, color: Colors.white),
          ),
        ),
        elevation: 0,
      ),
      body: UserID != null
          ? ListView.builder(
              itemCount: _daysOfWeek.length,
              itemBuilder: (context, index) {
                String day = _daysOfWeek[index];
                return DayScheduleTile(
                  day: day,
                  timeRange: _schedule[day],
                  onTimeRangeChanged: (timeRange) {
                    setState(() {
                      _schedule[day] = timeRange;
                    });
                  },
                );
              },
            )
          : Container(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: _loading
            ? null
            : () {
                setState(() {
                  _loading = true;
                });
                _saveSchedule();
              },
      ),
    );
  }

  Future<void> _saveSchedule() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, Map<String, String>> scheduleData = {};

    _schedule.forEach((day, timeRange) {
      if (timeRange != null) {
        scheduleData[day] = {
          'openingTime': timeRange.openingTime.format(context),
          'closingTime': timeRange.closingTime.format(context),
        };
      }
    });

    // Check if the user has an existing schedule
    QuerySnapshot scheduleSnapshot = await firestore
        .collection('schedules')
        .where('lawyerId', isEqualTo: UserID)
        .limit(1)
        .get();

    if (scheduleSnapshot.docs.isNotEmpty) {
      // If the user has an existing schedule, update it
      String scheduleId = scheduleSnapshot.docs.first.id;
      await firestore.collection('schedules').doc(scheduleId).update({
        'schedule': scheduleData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // If the user does not have an existing schedule, create a new one
      await firestore.collection('schedules').add({
        'lawyerId': UserID,
        'schedule': scheduleData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Operation successfully'),
      ),
    );
    Navigator.pop(context);
  }
}

class DayScheduleTile extends StatelessWidget {
  final String day;
  final TimeRange? timeRange;
  final ValueChanged<TimeRange?> onTimeRangeChanged;

  DayScheduleTile({
    required this.day,
    required this.timeRange,
    required this.onTimeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(day),
        subtitle: timeRange == null
            ? const Text(
                'Not Set',
                style: TextStyle(fontSize: 11, color: Colors.red),
              )
            : Text(
                'Opening: ${timeRange!.openingTime.format(context)}, Closing: ${timeRange!.closingTime.format(context)}',
                style: const TextStyle(fontSize: 11),
              ),
        trailing: IconButton(
          icon: const Icon(Icons.more_time),
          onPressed: () async {
            final newTimeRange = await showDialog<TimeRange?>(
              context: context,
              builder: (context) => TimeRangePickerDialog(timeRange: timeRange),
            );
            if (newTimeRange != null || timeRange != null) {
              onTimeRangeChanged(newTimeRange);
            }
          },
        ),
      ),
    );
  }
}

class TimeRangePickerDialog extends StatefulWidget {
  final TimeRange? timeRange;

  TimeRangePickerDialog({this.timeRange});

  @override
  _TimeRangePickerDialogState createState() => _TimeRangePickerDialogState();
}

class _TimeRangePickerDialogState extends State<TimeRangePickerDialog> {
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;

  @override
  void initState() {
    super.initState();
    _openingTime =
        widget.timeRange?.openingTime ?? const TimeOfDay(hour: 9, minute: 0);
    _closingTime =
        widget.timeRange?.closingTime ?? const TimeOfDay(hour: 17, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Times'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Opening Time'),
            trailing: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _openingTime,
                );
                if (picked != null) {
                  setState(() {
                    _openingTime = picked;
                  });
                }
              },
            ),
            subtitle: Text(_openingTime.format(context)),
          ),
          ListTile(
            title: const Text('Closing Time'),
            trailing: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _closingTime,
                );
                if (picked != null) {
                  setState(() {
                    _closingTime = picked;
                  });
                }
              },
            ),
            subtitle: Text(_closingTime.format(context)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null); // Return null to indicate clearing
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              TimeRange(openingTime: _openingTime, closingTime: _closingTime),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class TimeRange {
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;

  TimeRange({required this.openingTime, required this.closingTime});
}
