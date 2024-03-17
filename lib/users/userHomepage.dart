import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:online_lawyer_appointment_system/lawyers/Schedules.dart';
import 'package:online_lawyer_appointment_system/planner/add_planner.dart';
import 'package:online_lawyer_appointment_system/planner/sendEmail.dart';
import 'package:online_lawyer_appointment_system/planner/sendSms.dart';
import 'package:online_lawyer_appointment_system/users/reminders.dart';
import 'package:online_lawyer_appointment_system/users/Bokings.dart';
import 'package:online_lawyer_appointment_system/users/Lawyers.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'dart:collection';
import 'dart:io';
import 'dart:math' as Math;

import '../sharedPages/Profile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);
  static const String idScreen = "userhomepage";
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final _scaffoldKeys = GlobalKey<ScaffoldState>();

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  bool _showBottom = false;

  List<NetworkImage> _listOfImages = <NetworkImage>[];
  bool autoplays = false;
  bool showLoading = false;
  bool showLoadingWidget = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  final _firestore = FirebaseFirestore.instance;
  var markerIdToMap;
  Future<QuerySnapshot> searchStuffs() async {
    CollectionReference col = _firestore.collection('house');

    Query query = col.limit(20);

    return await query.get();
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  int size = 0;
  final User? auth = FirebaseAuth.instance.currentUser;

  DateTime timeBackPressed = DateTime.now();

  TextEditingController _controller = TextEditingController();

  DocumentSnapshot? renterDetailsSecond;
  String renterName = '';

  int? _currentIndex;
  int _counter = 0;
  bool? _showAppBar;
  bool? _showAppList;
  final _inactiveColor = Colors.black.withOpacity(0.5);

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    _currentIndex = 0;
    _showAppBar = false;
    _showAppList = false;

    super.initState();
  }

  int currentIndexT = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWarning = difference >= Duration(seconds: 2);
        timeBackPressed = DateTime.now();
        if (isExitWarning) {
          const message = 'Press back again to exit';
          Fluttertoast.showToast(
              backgroundColor: Color(0xFFf2f2f2),
              textColor: Colors.black,
              msg: message,
              fontSize: 18);
          return false;
        } else {
          Fluttertoast.cancel();
          return true;
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            Lawyers(),
            Bookings(),
            // SchedulePage(),
            Reminders(),
            // SendMailer(),
            // SendSms(),
            // AddSchedule(),
            Profile(),

            // HomePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex!,
          fixedColor: Color(0xFF009999),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              backgroundColor: Color(0xFF009999),
              label: 'Lawyers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm),
              backgroundColor: Color(0xFF009999),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              // icon: Icon(MdiIcons.bookmark),
              icon: Icon(Icons.newspaper),
              backgroundColor: Color(0xFF009999),
              label: 'Reminders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              backgroundColor: Color(0xFF009999),
              label: 'Profile',
            ),

            // BottomNavigationBarItem(
            //   icon: Icon(CupertinoIcons.profile_circled),
            //   backgroundColor: Color(0xFF009999),
            //   label: 'MyList',
            // ),
          ],
          onTap: (index) {
            if (index == 1) {
              setState(() {
                _currentIndex = index;
                _showAppList = true;
              });

              print(_currentIndex);
            } else {
              setState(() {
                _currentIndex = index;
                _showAppList = false;
              });
            }
          },
        ),
      ),
    );
  }
}
