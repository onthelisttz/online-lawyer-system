import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_lawyer_appointment_system/administrators/admin.dart';
import 'package:online_lawyer_appointment_system/lawyers/lawyerHome.dart';

import 'package:online_lawyer_appointment_system/planner/add_planner.dart';
import 'package:online_lawyer_appointment_system/registration/login.dart';
import 'package:online_lawyer_appointment_system/registration/register.dart';
import 'package:online_lawyer_appointment_system/users/userHomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyAb609uolKW3Sp36GlX63o7hx-G798_LDs',
        appId: '1:534276148824:android:052abe1b706387cbcd442d',
        messagingSenderId: '534276148824',
        projectId: 'online-lawyer-system',
        databaseURL: 'https://online-lawyer-system-default-rtdb.firebaseio.com',
        storageBucket: 'online-lawyer-system.appspot.com',
        measurementId: "G-J8C136M5EG"),
  );

  runApp(const MyApp());
}

// DatabaseReference userRef = FirebaseDatabase.instance.reference().child("user");

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget example1 = SplashScreenView(
      navigateRoute: FirebaseAuth.instance.currentUser != null
          ? const RoleChecker()
          : const LoginClass(),
      duration: 5000,
      // imageSize: 130,
      // imageSrc: "logo.jpg",
      text: "Online lawyer apointment",
      textType: TextType.ColorizeAnimationText,
      textStyle: TextStyle(
        fontSize: 40.0,
      ),
      colors: [
        Colors.purple,
        Colors.blue,
        Colors.yellow,
        Colors.red,
      ],
      backgroundColor: Colors.white,
    );
    return MaterialApp(
      title: 'Online lawyer apointment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: example1,
      home: FirebaseAuth.instance.currentUser != null
          ? const RoleChecker()
          : const LoginClass(),
      routes: {
        MyHomePage.idScreen: (context) => MyHomePage(),
        LawyerHomepage.idScreen: (context) => const LawyerHomepage(),
        RegisterClass.idScreen: (context) => RegisterClass(),
        AdminHome.idScreen: (context) => AdminHome(),
        LoginClass.idScreen: (context) => LoginClass(),
      },
    );
  }
}

// flutter pub run splash_screen_view:create
// flutter build appbundle
// flutter clean

// rename setAppName --targets ios,android --value "E-lawyer"
// adb connect 10.25.202.202:5555

class RoleChecker extends StatefulWidget {
  const RoleChecker({Key? key}) : super(key: key);

  @override
  _RoleCheckerState createState() => _RoleCheckerState();
}

class _RoleCheckerState extends State<RoleChecker> {
  String role = '';

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? userId = prefs.getString('userId');
      if (userId == null) {
        // Handle case where user is not authenticated
        return;
      }
      final DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snap.exists) {
        // Check if the document exists
        final data = snap.data() as Map<String, dynamic>?; // Explicit cast
        if (data != null && data.containsKey('role')) {
          // Check if the 'role' field exists in the document
          String userRole = data['role'];

          setState(() {
            role = userRole;
          });

          // Navigation logic...
          if (role == 'user') {
            Navigator.pushNamedAndRemoveUntil(
                context, MyHomePage.idScreen, (route) => false);
          } else if (role == 'lawyer') {
            // Replace 'LawyerHomePage' with the actual name of your lawyer home page
            Navigator.pushNamedAndRemoveUntil(
                context, LawyerHomepage.idScreen, (route) => false);
          } else if (role == 'admin') {
            // Replace 'AdminHomePage' with the actual name of your admin home page
            Navigator.pushNamedAndRemoveUntil(
                context, AdminHome.idScreen, (route) => false);
          }
        } else {
          // Handle case where 'role' field is missing
          setState(() {
            role = 'unknown_role';
          });
        }
      } else {
        // Handle case where document doesn't exist
        setState(() {
          role = 'user_not_found';
        });
      }
    } catch (e) {
      // Handle errors
      print("Error checking user role: $e");
      setState(() {
        role = 'error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: CircularProgressIndicator()),
    ); // You can return an empty container here
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:telephony/telephony.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeService();
//   runApp(MyApp());
// }

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       autoStart: true,
//       onStart: onStart,
//       isForegroundMode: false,
//       notificationChannelId: 'my_foreground',
//       // notificationChannelName: 'Foreground Service Channel',
//       // notificationChannelDescription: 'Channel for foreground service notifications',
//       // notificationChannelImportance: Importance.defaultImportance,
//       initialNotificationTitle: 'Foreground Service',
//       initialNotificationContent: 'Foreground service is running',
//       foregroundServiceNotificationId: 888,
//     ),
//     iosConfiguration: IosConfiguration(autoStart: false),
//   );
// }

// void onStart(ServiceInstance service) async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.setString("hello", "world");

//   // Debugging: Check if onStart is called
//   print("onStart called");

//   // Register event listener
//   service.on('sendSms').listen((event) async {
//     // Debugging: Check if the listener is registered
//     print("sendSms event received");

//     // Debugging: Check if sendMessage function is called
//     print("SERVICEEEEEEEEEEEEEEEEE HAS SEND MESSAGE");
//     await sendMessage();
//   });

//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });

//   // Debugging: Check if timer starts
//   Timer.periodic(const Duration(seconds: 1), (timer) async {
//     final DateTime now = DateTime.now();
//     print("TIME CALLED"); // Debugging: Check timer execution

//     // Debugging: Check if the condition is met
//     if (now.hour == 9 && now.minute == 51 && now.second == 0) {
//       print("TIME CALLED Inside Function");
//       sendMessage();
//       // service.invoke('sendSms');
//     }
//   });
// }

// Future<void> sendMessage() async {
//   print("SEND MESSAGE INSIDE FUNCTION");
//   final telephony = Telephony.instance;
//   final SmsSendStatusListener listener = (SendStatus status) {
//     print(status);
//   };

//   try {
//     telephony.sendSms(
//       to: "255743451357",
//       message: "May the force be with you!",
//       statusListener: listener,
//     );
//   } catch (e) {
//     print("Error sending SMS: $e");
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Service App'),
//         ),
//         body: ElevatedButton(
//           child: const Text('Stop Service'),
//           onPressed: () async {
//             final service = FlutterBackgroundService();
//             final isRunning = await service.isRunning();
//             if (isRunning) {
//               service.invoke('stopService');
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
