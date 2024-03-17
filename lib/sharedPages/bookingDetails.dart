import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_lawyer_appointment_system/AllWigtes/Dialog.dart';

class BookingDetails extends StatefulWidget {
  String? docId;

  BookingDetails({super.key, required this.docId});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  User? user = FirebaseAuth.instance.currentUser;
  // final Stream<QuerySnapshot> _usersStream = ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF009999),
        iconTheme: IconThemeData(color: Colors.white),
        titleSpacing: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('Booking Details', style: TextStyle(color: Colors.white)),
        ),
        elevation: 0,
      ),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   elevation: 1,
      //   backgroundColor: Colors.white,
      //   title: Text(
      //     "Bookings",
      //     style: TextStyle(
      //         fontSize: 17,
      //         letterSpacing: 2,
      //         color: Colors.black.withOpacity(0.6)),
      //   ),
      // ),
      body: Container(
        color: Color.fromARGB(179, 241, 241, 241),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where("id", isEqualTo: widget.docId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                String userId = user!.uid;
                String otherUserId = userId == data['clientId']
                    ? data['lawyerId']
                    : data['clientId'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUserId)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> userDoc =
                          snapshot.data!.data() as Map<String, dynamic>;
                      String profileImageUrl = userDoc['PhotoUrl'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.network(
                                  profileImageUrl,
                                  fit: BoxFit.cover,
                                  height: 220, // Adjust height as needed
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Appointment Details",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: data["status"] == "approved"
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            data["status"] == "approved"
                                                ? "Approved"
                                                : "Pending",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            color: Colors
                                                .grey, // Background color for the container
                                            child: Center(
                                              child: Icon(
                                                Icons.person,
                                                color:
                                                    Colors.white, // Icon color
                                                size: 24, // Icon size
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Client: ${data['clientName']}",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            color: Colors
                                                .grey, // Background color for the container
                                            child: Center(
                                              child: Icon(
                                                Icons.person,
                                                color:
                                                    Colors.white, // Icon color
                                                size: 24, // Icon size
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Lawyer: ${data['lawyerName']}",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 20, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text(
                                          readTimestamp2(data["date"]),
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(Icons.access_time,
                                            size: 20, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text(
                                          data['time'],
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.description,
                                            size: 20, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            "Title: ${data["title"]}",
                                            style: TextStyle(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.notes,
                                            size: 20, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            "Description: ${data["description"]}",
                                            style: TextStyle(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    if (data["status"] == "pending") ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              approveAppointMemnt(
                                                  widget.docId, "approved");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              // primary: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: Text('Approve'),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              approveAppointMemnt(
                                                  widget.docId, "rejected");
                                            },
                                            style: ElevatedButton.styleFrom(
                                              // primary: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: Text('Reject'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return SizedBox(); // Return an empty widget while waiting for data
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future approveAppointMemnt(id, status) async {
    final document = FirebaseFirestore.instance.collection('bookings').doc(id);
    await document.update({
      "status": status,
    });

    Navigator.pop(context);
  }
}
