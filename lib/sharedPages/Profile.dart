import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_lawyer_appointment_system/registration/login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

User? user = FirebaseAuth.instance.currentUser;
// final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
//     .collection('user')
//     .where('id', isEqualTo: user!.uid)
//     .snapshots();

class _ProfileState extends State<Profile> {
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
          "profile",
          style: TextStyle(fontSize: 17, letterSpacing: 2, color: Colors.white),
        ),
      ),
      body: Container(
        child: user == null
            ? Center(
                child:
                    Text("Login or if you have arleady login restart the app"),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('id', isEqualTo: user!.uid)
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
                      return Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(0xFF009999),
                                    radius: 62,
                                    child: ClipOval(
                                      child: data['PhotoUrl'] == null
                                          ? Text(
                                              'Dr',
                                              style: TextStyle(fontSize: 17),
                                            )
                                          : Image.network(
                                              data['PhotoUrl'],
                                              height: 120,
                                              width: 120,
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data["displayName"],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black.withOpacity(0.7)),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Email"),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  data["email"],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.4)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('phone Number'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  data["phoneNo"],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.4)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Location'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  data["location"],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.4)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Divider(),
                              ),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Color(0xFF009999),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // await FirebaseAuth.instance.signOut();
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        LoginClass.idScreen, (route) => false);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) {
                                      return LoginClass();
                                    }));
                                  },
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.white),
                                  )),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
      ),
    );
  }
}
