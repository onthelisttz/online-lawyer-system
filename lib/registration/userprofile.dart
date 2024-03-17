// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';

// import 'package:google_maps_webservice/places.dart';

// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// import 'package:path/path.dart' as Path;
// import 'package:uuid/uuid.dart';

// import 'package:google_api_headers/google_api_headers.dart';

// class UserProfileEdit extends StatefulWidget {
//   const UserProfileEdit({Key? key}) : super(key: key);

//   @override
//   _UserProfileEditState createState() => _UserProfileEditState();
// }

// TextEditingController nameController = TextEditingController();
// TextEditingController emailController = TextEditingController();
// TextEditingController phoneNoController = TextEditingController();
// final GlobalKey<FormState> _formKeysz = GlobalKey<FormState>();

// class _UserProfileEditState extends State<UserProfileEdit> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               Icons.arrow_back_ios_new,
//               size: 18,
//               color: Color(0xFFe26f39),
//             )),
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(
//           color: Color(0xFFe26f39),
//         ),
//         titleSpacing: 0,
//         centerTitle: true,
//         title: Text(
//           'Profile Editing',
//           style: TextStyle(
//               fontSize: 13,
//               letterSpacing: 1,
//               color: Colors.black.withOpacity(0.7)),
//         ),
//         elevation: 0,
//       ),
//       body: Theme(
//         data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//           primary: Color(0xFFe26f39),
//         )),
//         child: getSubscriptionResources(),
//       ),
//     );
//   }

//   final User? auth = FirebaseAuth.instance.currentUser;

//   getSubscriptionResources() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('user')
//           .where('id', isEqualTo: auth!.uid)
//           .snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Text('Something went wrong');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         return new ListView(
//           children: snapshot.data!.docs.map((DocumentSnapshot document) {
//             nameController.text = document["displayName"];
//             emailController.text = document["email"];
//             phoneNoController.text = document["phoneNo"].toString();

//             return Form(
//               key: _formKeysz,
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     top: 12.0, bottom: 20.0, left: 10.0, right: 30.0),
//                 child: Column(
//                   children: [
//                     Center(
//                       child: Stack(
//                         children: [
//                           ClipOval(
//                             child: InkWell(
//                               onTap: () {
//                                 chooseImage();
//                               },
//                               child: _image != null
//                                   ? CircleAvatar(
//                                       radius: 60,
//                                       child: ClipOval(
//                                         child: Container(
//                                           margin: EdgeInsets.all(3),
//                                           decoration: BoxDecoration(
//                                               image: DecorationImage(
//                                                   image: FileImage(_image!),
//                                                   fit: BoxFit.cover)),
//                                         ),
//                                       ),
//                                     )
//                                   : Container(
//                                       child: auth!.photoURL != null
//                                           ? CachedNetworkImage(
//                                               imageUrl: auth!.photoURL!,
//                                               placeholder: (context, url) =>
//                                                   Center(
//                                                 child:
//                                                     CircularProgressIndicator(),
//                                               ),
//                                               errorWidget:
//                                                   (context, url, error) =>
//                                                       Icon(Icons.error),
//                                               fit: BoxFit.cover,
//                                               width: 120,
//                                               height: 120,
//                                               fadeInCurve: Curves.easeIn,
//                                               fadeInDuration:
//                                                   Duration(seconds: 2),
//                                               fadeOutCurve: Curves.easeOut,
//                                               fadeOutDuration:
//                                                   Duration(seconds: 2),
//                                             )
//                                           : Container(
//                                               width: 120,
//                                               height: 120,
//                                               child: Icon(
//                                                 CupertinoIcons.profile_circled,
//                                                 color: Color(0xFFe26f39),
//                                                 size: 100,
//                                               ),
//                                             )),
//                             ),
//                           ),
//                           Positioned(
//                               bottom: 0,
//                               right: 4,
//                               child: InkWell(
//                                 onTap: () {
//                                   chooseImage();
//                                 },
//                                 child: ClipOval(
//                                   child: Container(
//                                     color: Colors.white,
//                                     padding: EdgeInsets.all(3.0),
//                                     child: ClipOval(
//                                       child: Container(
//                                         padding: EdgeInsets.all(8.0),
//                                         color: Color(0xFFe26f39),
//                                         child: Icon(
//                                           Icons.add_a_photo,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ))
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(
//                           right: 8.0, left: 8, bottom: 0, top: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             document['displayName'].toString(),
//                             style: TextStyle(
//                               fontSize: 18,
//                               letterSpacing: 4.0,
//                               color: Color(0xFFe26f39),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Card(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   top: 19, left: 18, right: 18),
//                               child: Text(
//                                 'Name',
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     letterSpacing: 1,
//                                     color: Color(0xFF3D3D3D)),
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 18, right: 18),
//                               child: Container(
//                                   height: 46.0,
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                       color: Color(0xFFf2dfce),
//                                       borderRadius: BorderRadius.only(
//                                         bottomLeft: Radius.circular(5.0),
//                                         bottomRight: Radius.circular(5.0),
//                                         topLeft: Radius.circular(5.0),
//                                         topRight: Radius.circular(5.0),
//                                       )),
//                                   child: Center(
//                                     child: TextFormField(
//                                       controller: nameController,
//                                       keyboardType: TextInputType.emailAddress,
//                                       decoration: InputDecoration(
//                                         contentPadding: EdgeInsets.only(
//                                             top: 13.0, left: 15.0),
//                                         prefixIcon: Icon(
//                                           CupertinoIcons.profile_circled,
//                                           size: 16,
//                                           color: Color(0xFFe26f39),
//                                         ),
//                                         border: InputBorder.none,
//                                         hintStyle: TextStyle(
//                                             fontSize: 11,
//                                             letterSpacing: 1,
//                                             color: Color(0xFF3D3D3D)),
//                                       ),
//                                       validator: (String? value) {
//                                         if (value!.isEmpty) {
//                                           return 'Name is required';
//                                         }
//                                       },
//                                     ),
//                                   )),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   top: 19, left: 18, right: 18),
//                               child: Text(
//                                 'Email Address.',
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     letterSpacing: 1,
//                                     color: Color(0xFF3D3D3D)),
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 18, right: 18),
//                               child: Container(
//                                   height: 46.0,
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                       color: Color(0xFFf2dfce),
//                                       borderRadius: BorderRadius.only(
//                                         bottomLeft: Radius.circular(5.0),
//                                         bottomRight: Radius.circular(5.0),
//                                         topLeft: Radius.circular(5.0),
//                                         topRight: Radius.circular(5.0),
//                                       )),
//                                   child: Center(
//                                     child: TextFormField(
//                                       controller: emailController,
//                                       keyboardType: TextInputType.emailAddress,
//                                       decoration: InputDecoration(
//                                         contentPadding: EdgeInsets.only(
//                                             top: 13.0, left: 15.0),
//                                         prefixIcon: Icon(
//                                           Icons.email,
//                                           size: 16,
//                                           color: Color(0xFFe26f39),
//                                         ),
//                                         border: InputBorder.none,
//                                         hintStyle: TextStyle(
//                                             fontSize: 11,
//                                             letterSpacing: 1,
//                                             color: Color(0xFF3D3D3D)),
//                                         hintText: "E.g johnDoe@gmail.com",
//                                       ),
//                                       validator: (String? value) {
//                                         if (value!.isEmpty) {
//                                           return 'Email is required';
//                                         }

//                                         if (!RegExp(
//                                                 r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
//                                             .hasMatch(value)) {
//                                           return 'Please enter a valid email address';
//                                         }
//                                       },
//                                     ),
//                                   )),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   top: 19, left: 18, right: 18),
//                               child: Text(
//                                 'Phone No.',
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     letterSpacing: 1,
//                                     color: Color(0xFF3D3D3D)),
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 18, right: 18),
//                               child: Container(
//                                   height: 46.0,
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                       color: Color(0xFFf2dfce),
//                                       borderRadius: BorderRadius.only(
//                                         bottomLeft: Radius.circular(5.0),
//                                         bottomRight: Radius.circular(5.0),
//                                         topLeft: Radius.circular(5.0),
//                                         topRight: Radius.circular(5.0),
//                                       )),
//                                   child: Center(
//                                     child: TextFormField(
//                                       controller: phoneNoController,
//                                       keyboardType: TextInputType.emailAddress,
//                                       decoration: InputDecoration(
//                                         contentPadding: EdgeInsets.only(
//                                             top: 13.0, left: 15.0),
//                                         prefixIcon: Icon(
//                                           Icons.phone,
//                                           size: 16,
//                                           color: Color(0xFFe26f39),
//                                         ),
//                                         border: InputBorder.none,
//                                         hintStyle: TextStyle(
//                                             fontSize: 11,
//                                             letterSpacing: 1,
//                                             color: Color(0xFF3D3D3D)),
//                                       ),
//                                       validator: (String? value) {
//                                         if (value!.isEmpty) {
//                                           return 'Size is required';
//                                         }
//                                       },
//                                     ),
//                                   )),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   right: 8.0, left: 8, bottom: 10, top: 20),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: ElevatedButton(
//                                       onPressed: isEnabled
//                                           ? () {
//                                               if (_formKeysz.currentState!
//                                                   .validate()) {
//                                                 setState(() {
//                                                   isEnabled = false;
//                                                 });

//                                                 uploadFile();
//                                                 Navigator.pop(context);
//                                               }
//                                             }
//                                           : null,
//                                       style: ElevatedButton.styleFrom(
//                                           onSurface: Colors.black,
//                                           primary: Color(0xFFe26f39)),
//                                       child: Text(
//                                         'Update Profile Info',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           letterSpacing: 3.0,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   bool isEnabled = true;
//   CollectionReference? imgRef;
//   firebase_storage.Reference? ref;
//   File? _image;

//   final picker = ImagePicker();
//   chooseImage() async {
//     final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
//     setState(() {
//       _image = File(pickedFile!.path);
//     });

//     if (pickedFile!.path == null) retrieveLostData();
//   }

//   Future<void> retrieveLostData() async {
//     final LostDataResponse response = await picker.retrieveLostData();
//     if (response.isEmpty) {
//       return;
//     }
//     if (response.file != null) {
//       setState(() {
//         _image = File(response.file!.path);
//       });
//     } else {
//       print(response.file);
//     }
//   }

//   Future uploadFile() async {
//     final document =
//         FirebaseFirestore.instance.collection("user").doc(users!.uid);
//     users!.updateDisplayName(nameController.text.trim());
//     String newImage;
//     if (_image == null) {
//       await document.update({
//         "displayName": nameController.text.trim(),
//         "email": emailController.text.trim(),
//         "phoneNo": phoneNoController.text.trim(),
//       });
//     } else {
//       ref = firebase_storage.FirebaseStorage.instance
//           .ref()
//           .child('images/${Path.basename(_image!.path)}');
//       await ref!.putFile(_image!);
//       final String downloadUrl = await ref!.getDownloadURL();
//       newImage = downloadUrl;
//       users!.updatePhotoURL(newImage);

//       await document.update({
//         'PhotoUrl': newImage,
//         "displayName": nameController.text.trim(),
//         "email": emailController.text.trim(),
//         "phoneNo": phoneNoController.text.trim(),
//       });
//     }
//   }

//   User? users = FirebaseAuth.instance.currentUser;
// }
