import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:online_lawyer_appointment_system/users/BookAppointments.dart';
import 'package:telephony/telephony.dart';

class Clients extends StatefulWidget {
  const Clients({Key? key}) : super(key: key);

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  final User? user = FirebaseAuth.instance.currentUser;

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
          'Clients Of Particular Lawyer',
          style: TextStyle(fontSize: 11, letterSpacing: 1, color: Colors.white),
        ),
      ),
      body: Container(
        color: Color.fromARGB(179, 241, 241, 241),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: getClientsForLawyer(user!.uid),
          builder: (BuildContext context,
              AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Something went wrong');
            } else {
              List<DocumentSnapshot> clients = snapshot.data ?? [];
              return ListView.builder(
                itemCount: clients.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> data =
                      clients[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF009999),
                          radius: 24,
                          child: ClipOval(
                            child: data['PhotoUrl'] == null
                                ? Text('Dr', style: TextStyle(fontSize: 17))
                                : Image.network(
                                    data['PhotoUrl'],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        title: Text(data["displayName"],
                            style: TextStyle(fontSize: 17)),
                        subtitle: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 10, color: Color(0xFF009999)),
                            Padding(
                              padding: const EdgeInsets.only(left: 1.0),
                              child: Text(
                                data['location'],
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Color(0xFF009999)),
                                  color: Color.fromARGB(179, 241, 241, 241),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.call,
                                      size: 9, color: Color(0xFF009999)),
                                  onPressed: () {
                                    // Add call functionality here
                                    _makePhoneCall(data["phoneNo"]);
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Color(0xFF009999)),
                                  color: Color.fromARGB(179, 241, 241, 241),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.message,
                                      size: 9, color: Color(0xFF009999)),
                                  onPressed: () {
                                    // Add SMS functionality here
                                    _sendSMS(data["phoneNo"]);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Handle onTap event
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> getClientsForLawyer(String lawyerId) async {
    Set<String> clientIds = {}; // Use Set instead of List

    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('lawyerId', isEqualTo: lawyerId)
          .get();

      // Collect unique client IDs
      for (DocumentSnapshot booking in bookingsSnapshot.docs) {
        String? clientId =
            (booking.data() as Map<String, dynamic>)['clientId'] as String?;
        if (clientId != null) {
          clientIds.add(clientId);
        }
      }

      // Fetch client details
      List<DocumentSnapshot> clients = [];
      for (String clientId in clientIds) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(clientId)
            .get();
        if (userSnapshot.exists) {
          clients.add(userSnapshot);
        }
      }

      return clients;
    } catch (error) {
      print('Error fetching clients: $error');
      return [];
    }
  }

// Call function
  void _makePhoneCall(phone) async {
    final telephony = Telephony.instance;
    var phoneNumber = phone;
    telephony.openDialer(phoneNumber);
  }

// SMS function
  void _sendSMS(phone) async {
    final telephony = Telephony.instance;

    try {
      telephony.sendSmsByDefaultApp(
          to: phone, message: "Hey How are you doing!");
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }
}
