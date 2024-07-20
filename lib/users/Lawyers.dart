import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:online_lawyer_appointment_system/sharedPages/userDetails.dart';
import 'package:online_lawyer_appointment_system/users/BookAppointments.dart';

class Lawyers extends StatefulWidget {
  const Lawyers({super.key});

  @override
  State<Lawyers> createState() => _LawyersState();
}

final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
    .collection('users')
    .where("role", isEqualTo: "lawyer")
    .where("isVerified", isEqualTo: true)
    .snapshots();
final Completer<GoogleMapController> _controller =
    Completer<GoogleMapController>();
Position? currentPosition;

class _LawyersState extends State<Lawyers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF009999),
        iconTheme: IconThemeData(color: Colors.white),
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          "Lawyers",
          style: TextStyle(fontSize: 17, letterSpacing: 2, color: Colors.white),
        ),
      ),
      body: Container(
        color: Color.fromARGB(179, 241, 241, 241),
        child: ListView(
          children: [
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: _usersStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      double kms = 2000;

                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Color.fromARGB(255, 255, 255, 255),
                            child: ListTile(
                              onTap: () async {},
                              leading: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return UserDetails(
                                      docId: data["id"],
                                    );
                                  }));
                                },
                                child: CircleAvatar(
                                  backgroundColor: Color(0xFF009999),
                                  radius: 24,
                                  child: ClipOval(
                                    child: data['PhotoUrl'] == null
                                        ? Text(
                                            'Dr',
                                            style: TextStyle(fontSize: 17),
                                          )
                                        : Image.network(
                                            data['PhotoUrl'],
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                ),
                              ),
                              title: Text(
                                data["displayName"],
                                style: TextStyle(fontSize: 17),
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 10,
                                        color: Color(0xFF009999),
                                      ),
                                      Flexible(
                                        child: Text(
                                          data['location'],
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_border_outlined,
                                        size: 13,
                                        color: Color(0xFF009999),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 1.0),
                                        child: Text(
                                          data['lawyerSpecialization']
                                              .toString(),
                                          // data['location'],
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: OutlinedButton(
                                  style: ButtonStyle(
                                      // backgroundColor: MaterialStateProperty.all(
                                      //   const Color(0xFFf2dfce),
                                      // ),
                                      side:
                                          MaterialStateProperty.all(BorderSide(
                                        color: Color(0xFF009999),
                                      )),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ))),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) {
                                      return BookAppointments(
                                        lawyerName: data["displayName"],
                                        lawyerId: data["id"],
                                      );
                                    }));
                                  },
                                  child: Text(
                                    'Book',
                                    style: TextStyle(
                                      color: Color(0xFF009999),
                                      fontSize: 14,
                                      letterSpacing: 2,
                                    ),
                                  )),
                            ),
                          ));
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
