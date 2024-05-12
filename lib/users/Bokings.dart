import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:online_lawyer_appointment_system/sharedPages/bookingDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  State<Bookings> createState() => _BookingsState();
}

String readTimestamp2(Timestamp timestamp) {
  var now = DateTime.now();
  var format = DateFormat('EEE, MMM d ');
  var date = timestamp.toDate();

  var time = '';

  time = format.format(date);

  return time;
}

class _BookingsState extends State<Bookings> {
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
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF009999),
          iconTheme: IconThemeData(color: Colors.white),
          titleSpacing: 0,
          centerTitle: true,
          title: Text(
            "Bookings",
            style:
                TextStyle(fontSize: 17, letterSpacing: 2, color: Colors.white),
          ),
        ),
        body: UserID != null
            ? Container(
                color: Color.fromARGB(179, 241, 241, 241),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where("clientId", isEqualTo: UserID)
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
                        // return ListTile(
                        //   title: Text(data['title']),
                        //   subtitle: Text(data['des']),
                        // );
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return BookingDetails(
                                docId: data["id"],
                              );
                            }));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                // ignore: prefer_const_constructors
                                color: Colors.white,
                                // decoration: BoxDecoration(border: Border.all()),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        VerticalDivider(
                                          thickness: 2,
                                          width: 20,
                                          color: data["status"] != "pending"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Appointment date",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 38.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              data["status"] ==
                                                                      "approved"
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    4.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    4.0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    4.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    4.0),
                                                          )),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0,
                                                                right: 8.0,
                                                                top: 1,
                                                                bottom: 1.0),
                                                        child: Text(
                                                          data["status"] ==
                                                                  "approved"
                                                              ? "Approved"
                                                              : data["status"] ==
                                                                      "pending"
                                                                  ? "Pending"
                                                                  : "Rejected",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.timer_sharp,
                                                    size: 15,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(readTimestamp2(
                                                        data["date"])),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(data['time']),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Container(
                                            //   decoration: BoxDecoration(
                                            //     border: Border(
                                            //       bottom: BorderSide(
                                            //           color: Colors.lightGreen, width: 5.0),
                                            //     ),
                                            //   ),
                                            // ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    80,
                                                height: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Column(
                                                    children: [
                                                      Text("Lawyer " +
                                                          data['lawyerName']),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .title_outlined,
                                                            size: 10,
                                                            color: Colors.grey,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child: Text(
                                                              data["title"],
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            //  CircleAvatar(
                                            //   radius: 32,
                                            //   child: ClipOval(
                                            //     child: CachedNetworkImage(
                                            //       imageUrl: widget.chatData['house']
                                            //           ['imageUrlList'],
                                            //       placeholder: (context, url) => Center(
                                            //         child: CircularProgressIndicator(),
                                            //       ),
                                            //       errorWidget: (context, url, error) =>
                                            //           Icon(Icons.error),
                                            //       fit: BoxFit.cover,
                                            //       width: 60,
                                            //       height: 60,
                                            //       fadeInCurve: Curves.easeIn,
                                            //       fadeInDuration: Duration(seconds: 2),
                                            //       fadeOutCurve: Curves.easeOut,
                                            //       fadeOutDuration: Duration(seconds: 2),
                                            //     ),
                                            //   ),
                                            // ),

                                            // Row(
                                            //   crossAxisAlignment: CrossAxisAlignment.end,
                                            //   children: [
                                            //     Text("MUsas"),
                                            //   ],
                                            // )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            : Container());
  }
}
