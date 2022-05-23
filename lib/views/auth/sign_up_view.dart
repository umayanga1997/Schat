import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt_chat/constants/app_constants.dart';
import 'package:crypt_chat/utils/services/auth.dart';
import 'package:crypt_chat/utils/services/database.dart';
import 'package:crypt_chat/views/auth/login_view.dart';
import 'package:crypt_chat/views/home_view.dart';
import 'package:crypt_chat/widgets/rounded_button.dart';
import 'package:crypt_chat/widgets/rounded_input_field.dart';
import 'package:crypt_chat/widgets/rounded_password_field.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:location/location.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  //   = new ();
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();
  var lng, lat;

  bool isVeryfyImg = false;

  Timer timer;

  bool isEmailVerifying = false;

  @override
  void initState() {
    super.initState();
    getLoca();
  }

  Future<void> getLoca() async {
    final Location lc = Location();
    var gg = await lc.getLocation();
    lat = gg.latitude;
    lng = gg.longitude;
    // setState(() {});
    // print(gg.toString());
  }

  void signUpUser() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      authMethods.SignUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((val) async {
        if (val != null) {
          // Email verification
          // if (!FirebaseAuth.instance.currentUser.emailVerified) {
          setState(() {
            isEmailVerifying = true;
          });
          await verifyEmail(val);
          // } else {
          //   userManage(val);
          //   // Navigate
          //   Navigator.pushReplacement(
          //       context, MaterialPageRoute(builder: (context) => HomeScreen()));
          // }
        } else {
          setState(() {
            isLoading = false;
          });
          SnackBar snackBar = SnackBar(
            content: Text('Email already exists!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          );
          // ignore: deprecated_member_use
          scaffoldKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  verifyEmail(val) async {
    User user = FirebaseAuth.instance.currentUser;
    user.sendEmailVerification();
    setState(() {
      isVeryfyImg = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Email verification message sent. Please check your email.")));
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkVerifycation(val);
    });
  }

  checkVerifycation(val) async {
    await FirebaseAuth.instance.currentUser.reload();
    if (FirebaseAuth.instance.currentUser.emailVerified) {
      await userManage(val);
      timer?.cancel();
      // Navigate
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  userManage(val) async {
    Map<String, dynamic> userInfoMap = {
      'username': usernameEditingController.text,
      'email': emailEditingController.text,
      'name': usernameEditingController.text,
      'user_id': val.userID,
      'isScAvailable': true,
      'bio': "It's my sChat!",
      'picUrl':
          "https://firebasestorage.googleapis.com/v0/b/schat-e4822.appspot.com/o/user_avatar.png?alt=media&token=ffb2ab51-424d-41e1-bf43-6f68ba26de11"
    };

    databaseMethods.uploadUserInfo(val.userID, userInfoMap);

    DocumentSnapshot documentSnapshot =
        await databaseMethods.getUserInfoByID(val.userID);

    // Generate session key
    String key = lng.toString() + lat.toString();

    // Make secure storage (Already have encript and decription techniques)
    // session release key add to the secure storage
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'key_of_session', value: key);
    // Encript user Data
    String token;
    final jwt = JWT(documentSnapshot.data());
    token = jwt.sign(SecretKey(key));
    // Make session
    await FlutterSession().set(key, token);
  }

  tryAgain() async {
    timer?.cancel();
    await FirebaseAuth.instance.signOut();
    // await FirebaseAuth.instance.currentUser.delete();
    setState(() {
      isLoading = false;
      isEmailVerifying = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        key: scaffoldKey,
        body: isLoading
            ? Container(
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !isVeryfyImg ? CircularProgressIndicator() : Container(),
                    SizedBox(
                      height: 100,
                    ),
                    isVeryfyImg
                        ? Column(
                            children: [
                              Image.asset('assets/images/send-mail.png',
                                  height: 100, width: 100),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  "Email verification message sent. Please check your email.",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          )
                        : TextButton(
                            onPressed: tryAgain,
                            child: Text(
                              "Try again",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 20),
                            )),
                  ],
                )),
              )
            : Container(
                height: screenSize.height,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/signup.png",
                            height: screenSize.height * 0.45,
                          ),
                          Text('REGISTER',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                                      ? Theme.of(context).primaryColor
                                      : Constants.kSecondaryColor,
                                  fontSize: 20.0)),
                          SizedBox(height: screenSize.height * 0.03),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                RoundedInputField(
                                    screenSize: screenSize,
                                    validator: (value) {
                                      return RegExp(
                                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(value)
                                          ? null
                                          : "Enter correct email";
                                    },
                                    hintText: 'Email Address',
                                    icon: Icons.email,
                                    controller: emailEditingController),
                                RoundedInputField(
                                    screenSize: screenSize,
                                    validator: (value) {
                                      return value.isEmpty || value.length < 4
                                          ? "Username too small"
                                          : RegExp(r"^[a-zA-Z0-9]+$")
                                                  .hasMatch(value)
                                              ? null
                                              : "No special characters allowed";
                                    },
                                    hintText: 'Username',
                                    icon: Icons.account_circle_rounded,
                                    controller: usernameEditingController),
                                RoundedPasswordField(
                                    screenSize: screenSize,
                                    validator: (value) {
                                      return value.length < 6
                                          ? "Password too small"
                                          : null;
                                    },
                                    hintText: 'Password',
                                    icon: Icons.lock,
                                    controller: passwordEditingController),
                              ],
                            ),
                          ),
                          RoundedButton(
                              screenSize: screenSize,
                              text: 'Register',
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              press: signUpUser),
                          SizedBox(height: screenSize.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .color)),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return LoginScreen();
                                  }));
                                },
                                child: Text('Login',
                                    style: TextStyle(
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Theme.of(context).primaryColor
                                          : Constants.kSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                    )),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )));
  }
}
