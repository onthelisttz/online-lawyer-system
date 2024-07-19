import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_lawyer_appointment_system/registration/login.dart';

import 'package:path/path.dart' as Path;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:permission_handler/permission_handler.dart';

const List<String> list = <String>[
  'user',
  'lawyer',
];

const tanzaniaData = {
  'Dar es Salaam': {
    'Ilala': ['Buguruni', 'Kariakoo', 'Kivukoni', 'Upanga West', 'Upanga East'],
    'Kinondoni': ['Kawe', 'Msasani', 'Oysterbay', 'Sinza', 'Mikocheni'],
    'Temeke': ['Chang\'ombe', 'Keko', 'Kurasini', 'Sandali', 'Mbagala'],
    'Ubungo': ['Kimara', 'Saranga', 'Sinza', 'Goba', 'Mbezi'],
    'Kigamboni': ['Kigamboni', 'Kibada', 'Mji Mwema', 'Somangila', 'Kigamboni'],
  },
  'Arusha': {
    'Arusha City': ['Baraa', 'Kaloleni', 'Levolosi', 'Ngarenaro', 'Sokon I'],
    'Arusha Rural': ['Bangata', 'Moshono', 'Nduruma', 'Oltrumet', 'Usa River'],
    'Karatu': ['Baray', 'Endabash', 'Mangola', 'Mbulumbulu', 'Qangdend'],
    'Longido': [
      'Engarenaibor',
      'Kitumbeine',
      'Longido',
      'Olmolog',
      'Mundarara'
    ],
    'Monduli': ['Engaruka', 'Esilalei', 'Lolkisale', 'Mto wa Mbu', 'Selela'],
  },
  'Dodoma': {
    'Dodoma Urban': [
      'Chang\'ombe',
      'Hazina',
      'Kikuyu North',
      'Kikuyu South',
      'Makole'
    ],
    'Bahi': ['Bahi', 'Chifutuka', 'Chitemo', 'Ibugule', 'Ilindi'],
    'Chamwino': ['Buigiri', 'Fufu', 'Haneti', 'Manda', 'Manchali'],
    'Chemba': ['Chemba', 'Churuku', 'Farkwa', 'Goima', 'Kwamtoro'],
    'Kondoa': ['Bereko', 'Bumbuta', 'Hondomairo', 'Kikore', 'Kinyasi'],
  },
  'Mwanza': {
    'Nyamagana': ['Mbugani', 'Mirongo', 'Mkuyuni', 'Nyakato', 'Igoma'],
    'Ilemela': ['Bugogwa', 'Buswelu', 'Kirumba', 'Nyamanoro', 'Pasiansi'],
    'Sengerema': ['Buchosa', 'Kagunga', 'Katwe', 'Nyamazugo', 'Sima'],
    'Kwimba': ['Bupamwa', 'Fukalo', 'Hungumalwa', 'Kikubiji', 'Lyoma'],
    'Magu': ['Bujashi', 'Jinjimili', 'Kahangara', 'Kisesa', 'Ndagalu'],
  },
  // Add more regions, districts, and wards as needed
};

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
TextEditingController specializationtextEditingController =
    TextEditingController();

bool isPasswordVisibleOne = true;
bool isPasswordVisible = true;

class _RegisterClassState extends State<RegisterClass> {
  String? selectedRegion;
  String? selectedDistrict;
  String? selectedWard;
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
      const CameraPosition(target: LatLng(-6.7924, 39.2083), zoom: 11.5);

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

  Icon fab = const Icon(
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

  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  bool _isPickingFile = false;

  Future<void> _pickPDFFile() async {
    setState(() {
      _isPickingFile = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      // Handle the error here, you might want to show a SnackBar or a Dialog
      print("Error picking file: $e");
    } finally {
      setState(() {
        _isPickingFile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009999),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Registrations',
          style: TextStyle(fontSize: 11, letterSpacing: 1, color: Colors.white),
        ),
      ),
      body: Form(
        key: reigsterUser,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
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
                            backgroundColor: const Color(0xFF009999),
                            radius: 60,
                            child: ClipOval(
                              child: _image == null
                                  ? Container()
                                  : Container(
                                      margin: const EdgeInsets.all(3),
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
                              padding: const EdgeInsets.all(3.0),
                              child: ClipOval(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color:
                                      const Color.fromARGB(255, 177, 237, 237),
                                  child: const Icon(
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

              const Padding(
                padding: EdgeInsets.only(top: 18, left: 18, right: 18),
                child: Text(
                  'Full Name.',
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1,
                      color: Color.fromARGB(255, 31, 9, 9)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: nametextEditingController,
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
                        nametextEditingController.clear();
                      },
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    hintStyle: const TextStyle(
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

              const Padding(
                padding: EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Email Address.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: emailtextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: const Color(0xFF009999),
                    filled: true,
                    suffixIcon: IconButton(
                      color: const Color.fromARGB(255, 177, 237, 237),
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                      onPressed: () {
                        emailtextEditingController.clear();
                      },
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 18, right: 18),
                child: Text(
                  'Region.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 3, left: 18, right: 18),
                child: DropdownButtonFormField<String>(
                  hint: const Text(
                    'Select Region',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  value: selectedRegion,
                  dropdownColor: Color(0xFF009999),
                  icon: const Icon(Icons.arrow_downward,
                      color: Color(0xFFa0daf2)),
                  elevation: 16,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    fillColor: Color(0xFF009999),
                    filled: true,
                    border: InputBorder.none,
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      selectedRegion = newValue;
                      selectedDistrict = null;
                      selectedWard = null;
                    });
                  },
                  items: tanzaniaData.keys.map((region) {
                    return DropdownMenuItem(
                      child: Text(region),
                      value: region,
                    );
                  }).toList(),
                ),
              ),

              if (selectedRegion != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 18, right: 18),
                  child: Text(
                    'District.',
                    style: TextStyle(
                        fontSize: 14, letterSpacing: 1, color: Colors.black),
                  ),
                ),
              if (selectedRegion != null)
                Padding(
                  padding: EdgeInsets.only(top: 3, left: 18, right: 18),
                  child: DropdownButtonFormField<String>(
                    hint: const Text(
                      'Select District',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    value: selectedDistrict,
                    dropdownColor: Color(0xFF009999),
                    icon: const Icon(Icons.arrow_downward,
                        color: Color(0xFFa0daf2)),
                    elevation: 16,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      fillColor: Color(0xFF009999),
                      filled: true,
                      border: InputBorder.none,
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDistrict = newValue;
                        selectedWard = null;
                      });
                    },
                    items: tanzaniaData[selectedRegion!]!.keys.map((district) {
                      return DropdownMenuItem(
                        child: Text(district),
                        value: district,
                      );
                    }).toList(),
                  ),
                ),

              // Ward Dropdown
              if (selectedDistrict != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 18, right: 18),
                  child: Text(
                    'Ward.',
                    style: TextStyle(
                        fontSize: 14, letterSpacing: 1, color: Colors.black),
                  ),
                ),
              if (selectedDistrict != null)
                Padding(
                  padding: EdgeInsets.only(top: 3, left: 18, right: 18),
                  child: DropdownButtonFormField<String>(
                    hint: const Text(
                      'Select Ward',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    value: selectedWard,
                    dropdownColor: Color(0xFF009999),
                    icon: const Icon(Icons.arrow_downward,
                        color: Color(0xFFa0daf2)),
                    elevation: 16,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      fillColor: Color(0xFF009999),
                      filled: true,
                      border: InputBorder.none,
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        selectedWard = newValue;
                      });
                    },
                    items: tanzaniaData[selectedRegion!]![selectedDistrict!]!
                        .map((ward) {
                      return DropdownMenuItem(
                        child: Text(ward),
                        value: ward,
                      );
                    }).toList(),
                  ),
                ),

              // Padding(
              //   padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
              //   child: Container(
              //       height: 46.0,
              //       width: double.infinity,
              //       decoration: const BoxDecoration(
              //           color: Color(0xFF009999),
              //           borderRadius: BorderRadius.only(
              //             bottomLeft: Radius.circular(5.0),
              //             bottomRight: Radius.circular(5.0),
              //             topLeft: Radius.circular(5.0),
              //             topRight: Radius.circular(5.0),
              //           )),
              //       child: Center(
              //         child: TextFormField(
              //           style: const TextStyle(color: Colors.white),
              //           controller: locationtextEditingController,
              //           keyboardType: TextInputType.text,
              //           decoration: InputDecoration(
              //             fillColor: const Color(0xFF009999),
              //             filled: true,
              //             border: InputBorder.none,
              //             suffixIcon: IconButton(
              //               color: const Color.fromARGB(255, 177, 237, 237),
              //               icon: const Icon(
              //                 Icons.close,
              //                 size: 16,
              //               ),
              //               onPressed: () {
              //                 locationtextEditingController.clear();
              //               },
              //             ),
              //             prefixIcon: const Icon(
              //               Icons.location_on,
              //               size: 16,
              //               color: Color.fromARGB(255, 177, 237, 237),
              //             ),
              //             hintStyle: const TextStyle(
              //                 fontSize: 11,
              //                 letterSpacing: 1,
              //                 color: Colors.white),
              //             hintText: "Location",
              //           ),
              //           validator: (String? value) {
              //             if (value!.isEmpty) {
              //               return "location required";
              //             }
              //           },
              //         ),
              //       )),
              // ),

              const Padding(
                padding: EdgeInsets.only(top: 8, left: 18, right: 18),
                child: Text(
                  'Phone Number.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1, left: 18, right: 18),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: PhoneNumbertextEditingController,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
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
                        PhoneNumbertextEditingController.clear();
                      },
                    ),
                    prefixIcon: const Icon(
                      Icons.call,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    hintStyle: const TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(top: 3, left: 18, right: 18),
                child: Text(
                  'Enter a Password.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: passwordtextEditingController,
                  obscureText: isPasswordVisibleOne,
                  decoration: InputDecoration(
                    fillColor: const Color(0xFF009999),
                    filled: true,
                    suffixIcon: IconButton(
                      color: const Color.fromARGB(255, 177, 237, 237),
                      icon: isPasswordVisibleOne
                          ? const Icon(
                              Icons.visibility_off,
                              size: 16,
                            )
                          : const Icon(
                              Icons.visibility,
                              size: 16,
                            ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisibleOne = !isPasswordVisibleOne;
                        });
                      },
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Comfirm Password.',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _confirmPasswordController,
                  obscureText: isPasswordVisible,
                  decoration: InputDecoration(
                    fillColor: const Color(0xFF009999),
                    filled: true,
                    suffixIcon: IconButton(
                      color: const Color.fromARGB(255, 177, 237, 237),
                      icon: isPasswordVisible
                          ? const Icon(
                              Icons.visibility_off,
                              size: 16,
                            )
                          : const Icon(
                              Icons.visibility,
                              size: 16,
                            ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Role',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.white),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 18, right: 18),
                child: Text(
                  'Role',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1, color: Colors.black),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: DropdownButtonFormField<String>(
                  // style: TextStyle(color: Colors.white),
                  value: dropdownValue,
                  dropdownColor: Color(0xFF009999),
                  icon: const Icon(Icons.arrow_downward,
                      color: Color(0xFFa0daf2)),
                  elevation: 16,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
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
              const SizedBox(
                height: 20,
              ),

              dropdownValue == 'lawyer'
                  ? const Padding(
                      padding: EdgeInsets.only(top: 18, left: 18, right: 18),
                      child: Text(
                        'Lawyer Specialization',
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            color: Colors.black),
                      ),
                    )
                  : Container(),

              dropdownValue == 'lawyer'
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 1, left: 18, right: 18),
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: specializationtextEditingController,
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
                              specializationtextEditingController.clear();
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
                          hintText: "E.g Real Estates",
                        ),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Specialization required';
                          }
                        },
                      ),
                    )
                  : Container(),

              dropdownValue == 'lawyer'
                  ? const Padding(
                      padding: EdgeInsets.only(top: 18, left: 18, right: 18),
                      child: Text(
                        'Lawyer Verfication Document',
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            color: Colors.black),
                      ),
                    )
                  : Container(),

              dropdownValue == 'lawyer'
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 1, left: 18, right: 18),
                      child: Container(
                        color: const Color(0xFF009999),
                        child: InkWell(
                          onTap: _pickPDFFile,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _selectedFile != null
                                      ? _fileName.toString()
                                      : "Select PDF File",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),

              // FloatingActionButton(
              //   child: Icon(Icons.add),
              //   onPressed: () {
              //     registerNewUserImgaf(context);
              //   },
              // ),

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
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                Color.fromARGB(255, 255, 255, 255),
                              ),
                            ))
                        : const Text(
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

  Future<void> registerNewUserImgaf(BuildContext context) async {
    try {
      print("UPLOAD START");
      final fileName = _fileName!;
      final ref = FirebaseStorage.instance.ref().child('pdfs/${fileName}');

      SettableMetadata metadata = SettableMetadata(
        cacheControl: 'max-age=3600',
        contentType: 'application/pdf',
      );
      await ref.putFile(_selectedFile!, metadata);

      final String downloadUrl = await ref.getDownloadURL();

      print("DOWNLOAD URL ISSSSSS THE FOLLOWING");
      print(downloadUrl);
    } catch (e) {
      displayToastMessage("Failed to upload image , $e", context);
      print("Error uploading image: $e");
    }
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  registerNewUser(BuildContext context) async {
    try {
      String finalLocation = "";
      if (selectedRegion == null) {
        displayToastMessage("Location Is Required", context);
        return;
      } else {
        finalLocation =
            '${selectedRegion ?? ""} ${selectedDistrict ?? ""} ${selectedWard ?? ""}';
      }
      if (_image == null) {
        displayToastMessage("Profile Picture is required", context);
        return;
      }

      if (_fileName == null && dropdownValue == 'lawyer') {
        displayToastMessage("Lawyer document is required", context);
        return;
      }
      String phoneNumber = PhoneNumbertextEditingController.text.trim();
      phoneNumber = '255' + phoneNumber.substring(1);

      String specializations = "";
      String documentUrlForSpecilization = "";
      if (dropdownValue == 'lawyer') {
        specializations = specializationtextEditingController.text.trim();
      }

      if (_fileName != null && dropdownValue == 'lawyer') {
        final fileName = _fileName!;
        final ref = FirebaseStorage.instance.ref().child('pdfs/${fileName}');

        SettableMetadata metadata = SettableMetadata(
          cacheControl: 'max-age=3600',
          contentType: 'application/pdf',
        );
        await ref.putFile(_selectedFile!, metadata);
        documentUrlForSpecilization = await ref.getDownloadURL();
      }
      // Upload image to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(_image!.path)}');
      SettableMetadata metadata = SettableMetadata(
        cacheControl: 'max-age=3600',
        contentType: 'image/jpeg',
      );

      await ref.putFile(_image!, metadata);
      final String downloadUrl = await ref.getDownloadURL();

      final firebaseUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailtextEditingController.text,
        password: passwordtextEditingController.text,
      );

      setState(() {
        _loading = false;
      });
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
        "location": finalLocation,
        "mapLocation":
            const GeoPoint(-6.1659, 39.2026), // Your hardcoded coordinates
        "created_at": FieldValue.serverTimestamp(),
        "role": dropdownValue,
        "PhotoUrl": downloadUrl,

        "lawyerSpecialization": specializations,
        "lawyerDocument": documentUrlForSpecilization,
      });
      setState(() {
        _loading = true;
      });

      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, LoginClass.idScreen, (route) => false);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return const LoginClass();
      }));
      displayToastMessage("Your Account has been created", context);
    } catch (e) {
      //  displayToastMessage(e, context);
      // Handle errors here
      print("Error registering user: $e");
      // You can also show an error message to the user using a Snackbar or Toast
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
