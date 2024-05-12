import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:online_lawyer_appointment_system/administrators/approvedLawyers.dart';
import 'package:online_lawyer_appointment_system/administrators/pendingLawyers.dart';
import 'package:online_lawyer_appointment_system/lawyers/Clients.dart';
import 'package:online_lawyer_appointment_system/lawyers/LawyerReminders.dart';
import 'package:online_lawyer_appointment_system/lawyers/Schedules.dart';
import 'package:online_lawyer_appointment_system/lawyers/lawyerBookings.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'dart:collection';
import 'dart:io';
import 'dart:math' as Math;

import 'package:online_lawyer_appointment_system/sharedPages/Profile.dart';
import 'package:online_lawyer_appointment_system/users/reminders.dart';

import '../planner/add_planner.dart';
import '../users/Bokings.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({
    Key? key,
  }) : super(key: key);
  static const String idScreen = "adminhomepage";
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

final _scaffoldKeys = GlobalKey<ScaffoldState>();

class _AdminHomeState extends State<AdminHome> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  bool _showBottom = false;

  List<NetworkImage> _listOfImages = <NetworkImage>[];
  bool autoplays = false;
  bool showLoading = false;
  bool showLoadingWidget = false;

  // final User? currentUser = FirebaseAuth.instance.currentUser;

  final _firestore = FirebaseFirestore.instance;
  var markerIdToMap;
  Future<QuerySnapshot> searchStuffs() async {
    CollectionReference col = _firestore.collection('house');

    Query query = col.limit(20);

    return await query.get();
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  int size = 0;
  // final User? auth = FirebaseAuth.instance.currentUser;

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
          final message = 'Press back again to exit';
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
            PendingLawyer(),
            ApprovedLawyer(),

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
              icon: Icon(Icons.people),
              backgroundColor: Color(0xFF009999),
              label: 'Pending',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user),
              backgroundColor: Color(0xFF009999),
              label: 'Approved',
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
