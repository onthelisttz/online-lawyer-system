import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_lawyer_appointment_system/AllWigtes/Dialog.dart';
import 'package:online_lawyer_appointment_system/sharedPages/pdfViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetails extends StatefulWidget {
  String? docId;

  UserDetails({super.key, required this.docId});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  // User? user = FirebaseAuth.instance.currentUser;
  // final Stream<QuerySnapshot> _usersStream = ;

  String UserID = "";

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
              'Details',
              style: TextStyle(
                  fontSize: 17, letterSpacing: 2, color: Colors.white),
            ),
          ),
          elevation: 0,
        ),
        body: Container(
          color: Color.fromARGB(179, 241, 241, 241),
          child: ListView(
            children: [
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where("id", isEqualTo: widget.docId)
                      .snapshots(),
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: Image.network(
                                    data['PhotoUrl'],
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
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (data["role"].toString() ==
                                              'lawyer')
                                            const Text(
                                              "Status",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          if (data["role"].toString() ==
                                              'lawyer')
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: data["isVerified"]
                                                    ? Colors.green
                                                    : Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                data["isVerified"]
                                                    ? "Approved"
                                                    : "Pending",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Full Name:      ${data["displayName"]}",
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.email,
                                              size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Email:             ${data["email"]}",
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.call,
                                              size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Phone:             ${data["phoneNo"]}",
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_rounded,
                                              size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "location:           ${data["location"]}",
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "Joined:             ${readTimestamp2(data["created_at"])}",
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (data["role"].toString() == 'lawyer')
                                        Row(
                                          children: [
                                            const Icon(Icons.star_border,
                                                size: 20, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                "Specialized:      ${data["lawyerSpecialization"]}",
                                                style: const TextStyle(
                                                    fontSize: 11),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 16),
                                      if (data["role"].toString() == 'lawyer' &&
                                          data["lawyerDocument"].toString() !=
                                              null)
                                        Row(
                                          children: [
                                            const Icon(Icons.description,
                                                size: 20, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                "Document:      ",
                                                style: const TextStyle(
                                                    fontSize: 11),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (BuildContext context) {
                                                      return PDFScreen(
                                                        pdf: data[
                                                            "lawyerDocument"],
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons
                                                  .remove_red_eye_outlined),
                                            )
                                          ],
                                        ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Future approveAppointMemnt(id, status) async {
    final document = FirebaseFirestore.instance.collection('bookings').doc(id);
    await document.update({
      "status": status,
    });

    Navigator.pop(context);
  }
}
