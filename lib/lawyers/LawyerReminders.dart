import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:online_lawyer_appointment_system/sharedPages/bookingDetails.dart';

import '../AllWigtes/Dialog.dart';

class LawyersReminders extends StatefulWidget {
  const LawyersReminders({Key? key}) : super(key: key);

  @override
  State<LawyersReminders> createState() => _LawyersRemindersState();
}

User? user = FirebaseAuth.instance.currentUser;

final DateTime now = DateTime.now(); // Get current date and time
final DateTime tomorrow = DateTime(
    now.year, now.month, now.day + 1); // Get tomorrow's date without time
final DateTime dayAfterTomorrow = DateTime(now.year, now.month,
    now.day + 2); // Get the day after tomorrow's date without time

final Stream<QuerySnapshot> _bookingStreams = FirebaseFirestore.instance
    .collection('bookings')
    .where("lawyerId", isEqualTo: user!.uid)
    .where("status", isEqualTo: 'approved')
    // .where("isNotificationSent", isEqualTo: false)
    .where("date",
        isGreaterThanOrEqualTo:
            Timestamp.fromDate(tomorrow)) // Filter by tomorrow's date or later
    .where("date",
        isLessThan: Timestamp.fromDate(
            dayAfterTomorrow)) // Filter by before the day after tomorrow
    .snapshots();

String readTimestamp2(Timestamp timestamp) {
  var now = DateTime.now();
  var format = DateFormat('EEE, MMM d ');
  var date = timestamp.toDate();

  var time = '';

  time = format.format(date);

  return time;
}

class _LawyersRemindersState extends State<LawyersReminders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 1,
        backgroundColor: Color(0xFF009999),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Reminders",
          style: TextStyle(fontSize: 17, letterSpacing: 2, color: Colors.white),
        ),
      ),
      body: Container(
        color: Color.fromARGB(179, 241, 241, 241),
        child: Column(
          children: [
            // Text(Timestamp.fromDate(today).toString()),
            StreamBuilder<QuerySnapshot>(
              stream: _bookingStreams,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print("ERRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                  print(snapshot.error);
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

                    sendNotification(data);
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
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
                                              padding: const EdgeInsets.only(
                                                  left: 38.0),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: data["status"] ==
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
                                                        const EdgeInsets.only(
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.timer_sharp,
                                                size: 15,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(readTimestamp2(
                                                    data["date"])),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            height: 1,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(
                                                children: [
                                                  Text("Client " +
                                                      data['clientName']),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.title_outlined,
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
                                                            color: Colors.grey,
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
          ],
        ),
      ),
    );
  }

  sendNotification(data) {
    if (!data["isNotificationSent"]) {
      print("ONRRT");
      // sendSmsToLawyer(data);
      // sendSmsToClient(data);
      // sendEmailToLawyer(data);
      // sendEmailToClient(data);
      //   updateNotificationSent(data["id"]);
    }
  }

  void sendSmsToLawyer(data) async {
    try {
      var lawyerId = data["lawyerId"];
      var message = """
Dear ${data['lawyerName']},

This is a reminder about your upcoming appointment with ${data['clientName']} scheduled for ${readTimestamp2(data['date'])} at ${data['time']}.
""";

      DocumentSnapshot lawyerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(lawyerId)
          .get();

      if (lawyerSnapshot.exists) {
        var phone =
            (lawyerSnapshot.data() as Map<String, dynamic>?)?['phoneNo'];
        if (phone != null && phone is String && phone.isNotEmpty) {
          var messages = "Hello there"; // Your SMS message
          await sendMessage(phone, message); // Send SMS
        } else {
          print('Phone number not found or invalid');
        }
      } else {
        print('Lawyer not found');
      }
    } catch (error) {
      print('Error sending SMS: $error');
    }
  }

  void sendSmsToClient(data) async {
    try {
      var clientId = data["clientId"];
      var message = """
Dear ${data['clientName']},

This is a reminder about your upcoming appointment with ${data['lawyerName']} scheduled for ${readTimestamp2(data['date'])} at ${data['time']}.
""";

      DocumentSnapshot lawyerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(clientId)
          .get();

      if (lawyerSnapshot.exists) {
        var phone =
            (lawyerSnapshot.data() as Map<String, dynamic>?)?['phoneNo'];
        if (phone != null && phone is String && phone.isNotEmpty) {
          var messages = "Hello there"; // Your SMS message
          await sendMessage(phone, message); // Send SMS
        } else {
          print('Phone number not found or invalid');
        }
      } else {
        print('Lawyer not found');
      }
    } catch (error) {
      print('Error sending SMS: $error');
    }
  }

  void sendEmailToLawyer(data) async {
    try {
      var lawyerId = data["lawyerId"];

      var message = """
📅 Appointment Reminder 🕒

Dear ${data['lawyerName']},

This is a friendly reminder about your upcoming appointment with ${data['clientName']} scheduled for ${readTimestamp2(data['date'])} at ${data['time']}. Please ensure that you are available and prepared to provide your legal expertise.

Appointment Details:
- Date: ${readTimestamp2(data['date'])}
- Time: ${data['time']}
- Client: ${data['clientName']}
- Case Title: ${data['title']}

If you have any questions or need to reschedule, please contact us as soon as possible.

Thank you for your continued dedication to your clients.

Best regards,

""";

      DocumentSnapshot lawyerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(lawyerId)
          .get();

      if (lawyerSnapshot.exists) {
        var email = (lawyerSnapshot.data() as Map<String, dynamic>?)?['email'];
        if (email != null && email is String && email.isNotEmpty) {
          var messages = "Hello there"; // Your SMS message
          await sendEmailMessage(email, message); // Send SMS
        } else {
          print('Phone number not found or invalid');
        }
      } else {
        print('Lawyer not found');
      }
    } catch (error) {
      print('Error sending SMS: $error');
    }
  }

  void sendEmailToClient(data) async {
    try {
      var clientId = data["clientId"];

      var message = """

  <h2>📅 Appointment Reminder 🕒</h2>
  <p>Dear ${data['clientName']},</p>
  <p>This is a friendly reminder about your upcoming appointment with ${data['lawyerName']} scheduled for ${readTimestamp2(data['date'])} at ${data['time']}. Please ensure that you are available and prepared for your legal consultation.</p>
  <h3>Appointment Details:</h3>
  <ul>
    <li><strong>Date:</strong> ${readTimestamp2(data['date'])}</li>
    <li><strong>Time:</strong> ${data['time']}</li>
    <li><strong>Lawyer:</strong> ${data['lawyerName']}</li>
    <li><strong>Case Title:</strong> ${data['title']}</li>
  </ul>
  <p>If you have any questions or need to reschedule, please contact us as soon as possible.</p>
  <p>Thank you for choosing our legal services.</p>
  <p>Best regards,</p>


""";

      DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(clientId)
          .get();

      if (clientSnapshot.exists) {
        var email = (clientSnapshot.data() as Map<String, dynamic>?)?['email'];
        if (email != null && email is String && email.isNotEmpty) {
          await sendEmailMessage(email, message); // Send email
        } else {
          print('Email address not found or invalid');
        }
      } else {
        print('Client not found');
      }
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  Future<void> updateNotificationSent(DocumentSnapshot data) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(data.id)
          .update({'isNotificationSent': true});
      print('Notification status updated successfully');
    } catch (error) {
      print('Error updating notification status: $error');
    }
  }
}
