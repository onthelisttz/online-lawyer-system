import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_lawyer_appointment_system/registration/login.dart';

import 'package:path/path.dart' as Path;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

const List<String> list = <String>[
  'user',
  'lawyer',
];

class RegisterClass extends StatefulWidget {
  const RegisterClass({Key? key}) : super(key: key);
  static const String idScreen = "register";

  @override
  _RegisterClassState createState() => _RegisterClassState();
}

TextEditingController nametextEditingController = TextEditingController();
TextEditingController emailtextEditingController = TextEditingController();
TextEditingController locationtextEditingController = TextEditingController();
TextEditingController PhoneNumbertextEditingController =
    TextEditingController();
TextEditingController passwordtextEditingController = TextEditingController();
TextEditingController _confirmPasswordController = TextEditingController();

bool isPasswordVisibleOne = true;
bool isPasswordVisible = true;

class _RegisterClassState extends State<RegisterClass> {
  final GlobalKey<FormState> reigsterUser = GlobalKey<FormState>();
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  String dropdownValue = list.first;
  bool autoplays = false;
  bool showLoading = false;
  bool showLoadingWidget = false;
  String selectedCountry = 'user';
  bool _loading = false;
  static final CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(-6.7924, 39.2083), zoom: 11.5);

  Position? currentPosition;
  var geolocator = Geolocator();

  void LocatePosition() async {
    // Request permission to access the device's location
    var permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      // Permission granted, proceed to get the current position
      Position position = await Geolocator.getCurrentPosition();

      currentPosition = position;
      LatLng latLangPosition = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition =
          new CameraPosition(target: latLangPosition, zoom: 14);

      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    } else {
      // Permission denied, handle accordingly (e.g., show a message to the user)
      print('Permission denied to access location');
    }
  }

  // void LocatePosition() async {
  //   Position position = await Geolocator.getCurrentPosition();

  //   currentPosition = position;
  //   LatLng latLangPosition = LatLng(position.latitude, position.longitude);
  //   CameraPosition cameraPosition =
  //       new CameraPosition(target: latLangPosition, zoom: 14);

  //   newGoogleMapController!
  //       .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  // }

  final User? currentUser = FirebaseAuth.instance.currentUser;

  var markerIdToMap;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  int size = 0;
  final User? auth = FirebaseAuth.instance.currentUser;
  void _toggleMapType() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal)
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Icon fab = Icon(
    Icons.map,
    color: Color.fromARGB(255, 177, 237, 237),
  );

  int fabIconNumber = 0;
  MapType _currentMapType = MapType.normal;

  DateTime timeBackPressed = DateTime.now();

  TextEditingController _controller = TextEditingController();

  double? lat;
  double? long;
  List<Marker> myMarker = [];
  _handleTap(LatLng tappedPoint) {
    print("THE POINTS IS $tappedPoint");

    lat = tappedPoint.latitude;
    long = tappedPoint.longitude;

    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: tappedPoint,
          draggable: true,
          onDragEnd: (dragEndPosition) {
            lat = dragEndPosition.latitude;
            long = dragEndPosition.longitude;
            // widget.house.lat = lat!;
            // widget.house.long = long!;
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF009999),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Registrations',
          style: TextStyle(fontSize: 11, letterSpacing: 1, color: Colors.white),
        ),
      ),
      body: Form(
        key: reigsterUser,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'profile',
                  style: TextStyle(
                      fontSize: 11, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Center(
                child: Stack(
                  children: [
                    ClipOval(
                      child: InkWell(
                          onTap: () {
                            chooseImage();
                          },
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF009999),
                            radius: 60,
                            child: ClipOval(
                              child: _image == null
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: FileImage(_image!),
                                              fit: BoxFit.cover)),
                                    ),
                            ),
                          )),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            chooseImage();
                          },
                          child: ClipOval(
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(3.0),
                              child: ClipOval(
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  color: Color.fromARGB(255, 177, 237, 237),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Color(0xFF009999),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
                child: Text(
                  'Username.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: nametextEditingController,
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
                        nametextEditingController.clear();
                      },
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    hintStyle: TextStyle(
                        fontSize: 11, letterSpacing: 1, color: Colors.white),
                    hintText: "E.g john Doe",
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'name required';
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Email Address.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: emailtextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: Color(0xFF009999),
                    filled: true,
                    suffixIcon: IconButton(
                      color: Color.fromARGB(255, 177, 237, 237),
                      icon: Icon(
                        Icons.close,
                        size: 16,
                      ),
                      onPressed: () {
                        emailtextEditingController.clear();
                      },
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        fontSize: 11, letterSpacing: 1, color: Colors.white),
                    hintText: "E.g johnDoe@gmail.com",
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "email required";
                    }

                    if (!RegExp(
                            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                        .hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 18, right: 18),
                child: Text(
                  'location.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
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
                    child: Center(
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: locationtextEditingController,
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
                              locationtextEditingController.clear();
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color.fromARGB(255, 177, 237, 237),
                          ),
                          hintStyle: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1,
                              color: Colors.white),
                          hintText: "Location",
                        ),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return "location required";
                          }
                        },
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Phone Number.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: PhoneNumbertextEditingController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
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
                        PhoneNumbertextEditingController.clear();
                      },
                    ),
                    prefixIcon: Icon(
                      Icons.call,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    hintStyle: TextStyle(
                        fontSize: 11, letterSpacing: 1, color: Colors.white),
                    hintText: "Phone number",
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Phone number is required';
                    } else if (value.length < 10) {
                      return 'Phone number must be at least 10 digits long';
                    } else if (value[0] != '0') {
                      return 'Phone number must start with 0';
                    }
                    return null; // Return null if validation passes
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Enter a Password.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: passwordtextEditingController,
                  obscureText: isPasswordVisibleOne,
                  decoration: InputDecoration(
                    fillColor: Color(0xFF009999),
                    filled: true,
                    suffixIcon: IconButton(
                      color: Color.fromARGB(255, 177, 237, 237),
                      icon: isPasswordVisibleOne
                          ? Icon(
                              Icons.visibility_off,
                              size: 16,
                            )
                          : Icon(
                              Icons.visibility,
                              size: 16,
                            ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisibleOne = !isPasswordVisibleOne;
                        });
                      },
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        fontSize: 11, letterSpacing: 1, color: Colors.white),
                    hintText: "*******",
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "password requred";
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Comfirm Password.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _confirmPasswordController,
                  obscureText: isPasswordVisible,
                  decoration: InputDecoration(
                    fillColor: Color(0xFF009999),
                    filled: true,
                    suffixIcon: IconButton(
                      color: Color.fromARGB(255, 177, 237, 237),
                      icon: isPasswordVisible
                          ? Icon(
                              Icons.visibility_off,
                              size: 16,
                            )
                          : Icon(
                              Icons.visibility,
                              size: 16,
                            ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        fontSize: 11, letterSpacing: 1, color: Colors.white),
                    hintText: "*******",
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "password requred";
                    } else if (value.length < 4 || value.length > 20) {
                      return "Password must be betweem 5 and 20 characters";
                    } else if (passwordtextEditingController.text !=
                        _confirmPasswordController.text) {
                      return "password do not match";
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Role',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: DropdownButtonFormField<String>(
                  // style: TextStyle(color: Colors.white),
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward,
                      color: Color(0xFFa0daf2)),
                  elevation: 16,
                  // style: const TextStyle(color: Colors.deepPurple),
                  decoration: InputDecoration(
                    fillColor: Color(0xFF009999),
                    filled: true,
                    border: InputBorder.none,
                  ),

                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Container(
              //   height: 300,
              //   child: Stack(
              //     children: <Widget>[
              //       GestureDetector(
              //         child: GoogleMap(
              //           mapType: _currentMapType,
              //           myLocationButtonEnabled: false,
              //           myLocationEnabled: true,
              //           zoomControlsEnabled: false,
              //           gestureRecognizers: {
              //             Factory<OneSequenceGestureRecognizer>(
              //               () => EagerGestureRecognizer(),
              //             )
              //           },
              //           zoomGesturesEnabled: true,
              //           initialCameraPosition: _cameraPosition,
              //           markers: Set.from(myMarker),
              //           onTap: _handleTap,
              //           onMapCreated: (GoogleMapController controller) {
              //             if (!_controllerGoogleMap.isCompleted) {
              //               _controllerGoogleMap.complete(controller);
              //             } else {}

              //             newGoogleMapController = controller;
              //             LocatePosition();
              //           },
              //         ),
              //       ),
              //       Positioned(
              //         bottom: 58,
              //         left: 5,
              //         child: InkWell(
              //           onTap: () {
              //             _toggleMapType();
              //             setState(() {
              //               if (fabIconNumber == 0) {
              //                 fab = Icon(
              //                   Icons.layers,
              //                   color: Color.fromARGB(255, 177, 237, 237),
              //                 );
              //                 fabIconNumber = 1;
              //               } else {
              //                 fab = Icon(
              //                   Icons.map,
              //                   color: Color.fromARGB(255, 177, 237, 237),
              //                 );
              //                 fabIconNumber = 0;
              //               }
              //             });
              //           },
              //           child: Container(
              //             decoration: BoxDecoration(
              //                 color: Color(0xFF009999),
              //                 borderRadius: BorderRadius.only(
              //                   bottomLeft: Radius.circular(7.0),
              //                   bottomRight: Radius.circular(7.0),
              //                   topLeft: Radius.circular(7.0),
              //                   topRight: Radius.circular(7.0),
              //                 )),
              //             width: 40,
              //             height: 43,
              //             child: Column(
              //               children: [
              //                 fab,
              //                 Text(
              //                   "Map",
              //                   style: TextStyle(
              //                       color: Color.fromARGB(255, 177, 237, 237),
              //                       fontSize: 12),
              //                 )
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       Positioned(
              //         bottom: 10,
              //         left: 5,
              //         child: InkWell(
              //           onTap: () {
              //             LocatePosition();
              //           },
              //           child: Container(
              //             width: 40,
              //             height: 43,
              //             child: Column(
              //               children: [
              //                 Icon(
              //                   Icons.my_location,
              //                   color: Color.fromARGB(255, 177, 237, 237),
              //                 ),
              //                 Text(
              //                   "Me",
              //                   style: TextStyle(
              //                       color: Color.fromARGB(255, 177, 237, 237),
              //                       fontSize: 12),
              //                 )
              //               ],
              //             ),
              //             decoration: BoxDecoration(
              //                 color: Color(0xFF009999),
              //                 borderRadius: BorderRadius.only(
              //                   bottomLeft: Radius.circular(5.0),
              //                   bottomRight: Radius.circular(5.0),
              //                   topLeft: Radius.circular(5.0),
              //                   topRight: Radius.circular(5.0),
              //                 )),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // InkWell(
              //     onTap: () {
              //       registerNewUserImgaf();
              //     },
              //     child: Text("Phone number")),
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
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),
                    onPressed: _loading
                        ? null
                        : () {
                            if (reigsterUser.currentState!.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              registerNewUser(context);

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
                                Color.fromARGB(255, 255, 255, 255),
                              ),
                            ))
                        : Text(
                            ' Register',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isEnabled = true;
  CollectionReference? imgRef;
  firebase_storage.Reference? ref;
  File? _image;

  final picker = ImagePicker();
  chooseImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    setState(() {
      _image = File(pickedFile!.path);
    });

    if (pickedFile!.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file!.path);
      });
    }
  }

  registerNewUserImgaf() async {
    try {
      String phoneNumber = PhoneNumbertextEditingController.text.trim();
      phoneNumber = '255' + phoneNumber.substring(1);
      print(phoneNumber);
    } catch (e) {
      // Handle errors here
      displayToastMessage("Failed to upload image , $e", context);
      print("Error uploading image: $e");
      // You can also show an error message to the user using a Snackbar or Toast
    }
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  registerNewUser(BuildContext context) async {
    try {
      String phoneNumber = PhoneNumbertextEditingController.text.trim();
      phoneNumber = '255' + phoneNumber.substring(1);

      print(phoneNumber);
      final firebaseUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailtextEditingController.text,
        password: passwordtextEditingController.text,
      );

      // Upload image to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(_image!.path)}');
      await ref.putFile(_image!);
      final String downloadUrl = await ref.getDownloadURL();

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser.user!.uid)
          .set({
        "id": firebaseUser.user!.uid,
        "isVerified": false,
        "displayName": nametextEditingController.text.trim(),
        "email": emailtextEditingController.text.trim(),
        "phoneNo": phoneNumber,
        "location": locationtextEditingController.text.trim(),
        "mapLocation": GeoPoint(-6.1659, 39.2026), // Your hardcoded coordinates
        "created_at": FieldValue.serverTimestamp(),
        "role": dropdownValue,
        "PhotoUrl": downloadUrl,
      });

      // Update user display name
      await firebaseUser.user!
          .updateDisplayName(nametextEditingController.text.trim());

      // Update user email
      await firebaseUser.user!
          .verifyBeforeUpdateEmail(emailtextEditingController.text.trim());

      _loading = false;
      // Navigator.pushReplacementNamed(
      //   context,
      //   LoginClass.idScreen,
      // );
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, LoginClass.idScreen, (route) => false);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return LoginClass();
      }));
      displayToastMessage("Your Account has been created", context);
      // User data saved successfully
      // You may want to navigate to another screen or show a success message here
    } catch (e) {
      // Handle errors here
      print("Error registering user: $e");
      // You can also show an error message to the user using a Snackbar or Toast
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

  Future updateEmail(String newEmail, BuildContext context) async {
    var message;
    User? user = FirebaseAuth.instance.currentUser;
    user!
        .updateEmail(newEmail)
        .then(
          (value) => message,
        )
        .catchError(
          (onError) => message = displayToastMessage(
              "Error on displaying email $onError", context),
        );
    return message;
  }
}
