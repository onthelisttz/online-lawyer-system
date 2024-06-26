// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:online_lawyer_appointment_system/administrators/admin.dart';
import 'package:online_lawyer_appointment_system/lawyers/lawyerHome.dart';
import 'package:online_lawyer_appointment_system/main.dart';
import 'package:online_lawyer_appointment_system/registration/register.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_lawyer_appointment_system/users/userHomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginClass extends StatefulWidget {
  const LoginClass({Key? key}) : super(key: key);
  static const String idScreen = "login";
  @override
  _LoginClassState createState() => _LoginClassState();
}

TextEditingController emailtextEditingController = TextEditingController();
TextEditingController passwordtextEditingController = TextEditingController();

bool isPasswordVisibleOne = true;
bool isPasswordVisible = true;

class _LoginClassState extends State<LoginClass> {
  final GlobalKey<FormState> loginUserKey = GlobalKey<FormState>();
  String role = 'user';
  bool emaild = false;
  bool passwordoned = false;
  String emailtext = 'email required';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF009999),
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text('Login', style: TextStyle(color: Colors.white)),
        ),
        elevation: 0,
      ),
      body: Form(
        key: loginUserKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.9, bottom: 8.0),
          child: ListView(
            children: [
              // Image(image: AssetImage('assets/heavy.jpg')),
              const Image(image: AssetImage('images/law.png')),
              const Padding(
                padding: EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Find your best lawyer here',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 18, right: 18),
                child: Text(
                  'Name.',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
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
                    prefixIcon: const Icon(
                      Icons.email,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),

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
                    // prefixIconConstraints: BoxConstraints(
                    //   maxHeight: 10,
                    //   maxWidth: 20,
                    // ),
                    // prefixIcon: Icon(
                    //   Icons.email,
                    //   size: 16,
                    //   color: Color.fromARGB(255, 177, 237, 237),
                    // ),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                    hintText: "E.g johnDoe@gmail.com",
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'email is reqired';
                    }

                    if (!RegExp(
                            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  },
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 19, left: 18, right: 18),
                child: Text(
                  'Enter a Password.',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: passwordtextEditingController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: isPasswordVisibleOne,
                  // keyboardType: TextInputType.visiblePassword,
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

                    // prefixIcon: Icon(
                    //   Icons.lock,
                    //   size: 16,
                    //   color: Color.fromARGB(255, 177, 237, 237),
                    // ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      size: 16,
                      color: Color.fromARGB(255, 177, 237, 237),
                    ),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                    hintText: "****",
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'password is required';
                    }
                  },
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0xFF009999),
                        ),
                        side: MaterialStateProperty.all(const BorderSide(
                          color: Color(0xFF009999),
                        )),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),
                    onPressed: _loading
                        ? null
                        : () {
                            if (loginUserKey.currentState!.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              LoginAndAutheniticateUser(context);
                            }
                          },
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ))
                        : const Text(
                            ' login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          )),
              ),

              Align(
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return const RegisterClass();
                        }));
                      },
                      child: const Text(
                        "You dont Have Account Register",
                        style: TextStyle(
                          color: Color(0xFF383840),
                        ),
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void LoginAndAutheniticateUser(BuildContext context) async {
    try {
      final User? firebaseUser = (await firebaseAuth.signInWithEmailAndPassword(
              email: emailtextEditingController.text,
              password: passwordtextEditingController.text))
          .user;

      if (firebaseUser != null) {
        // Navigator.pushNamedAndRemoveUntil(
        //     context, MyHomePage.idScreen, (route) => false);

        _chekRole();
      }

      // Navigator.pushNamedAndRemoveUntil(
      //     context, MyHomePage.idScreen, (route) => false);
    } on FirebaseAuthException catch (e) {
      displayToastMessage("Wrong Email or Password", context);
      setState(() {
        _loading = false;
      });
      if (e.code == 'user-not-found') {
        displayToastMessage("User not found", context);
        // displayToastMessage("User not found", context);
      } else if (e.code == 'wrong-password') {
        displayToastMessage("Wrong password", context);
      }
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

  void _chekRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle case where user is not authenticated
        return;
      }

      final DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snap.exists) {
        // Check if the document exists
        final data = snap.data() as Map<String, dynamic>?; // Explicit cast
        if (data != null && data.containsKey('role')) {
          // Check if the 'role' field exists in the document
          String userRole = data['role'];
          // Boolean status = data['isVerified'];
          String currentUser = data['id'];
          String currentUserName = data['displayName'];
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('userId', currentUser);
          await prefs.setString('userName', currentUserName);
          setState(() {
            role = userRole;
          });

          if (role == 'user') {
            Navigator.pushNamedAndRemoveUntil(
                context, MyHomePage.idScreen, (route) => false);
          } else if (role == 'admin') {
            Navigator.pushNamedAndRemoveUntil(
                context, AdminHome.idScreen, (route) => false);
          } else if (role == 'lawyer') {
            if (!data['isVerified']) {
              await FirebaseAuth.instance.signOut();
              setState(() {
                _loading = false;
              });
              displayToastMessage(
                  "Unable to loginin, your account is not verified", context);
              return;
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, LawyerHomepage.idScreen, (route) => false);
            }
          }
        } else {
          // Handle case where 'role' field is missing
          setState(() {
            role = 'unknown_role';
          });
        }

        displayToastMessage("Login succesfull", context);
      } else {
        // Handle case where document doesn't exist
        setState(() {
          role = 'user_not_found';
        });
      }
    } catch (e) {
      // Handle errors
      print("Error checking user role: $e");
      setState(() {
        role = 'error';
      });
    }
  }
}
