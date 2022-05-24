import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt_chat/constants/app_constants.dart';
import 'package:crypt_chat/utils/helpers/sessiontimeOut.dart';
// import 'package:crypt_chat/utils/helpers/shared_pref_helper.dart';
import 'package:crypt_chat/utils/services/auth.dart';
import 'package:crypt_chat/utils/services/database.dart';
import 'package:crypt_chat/views/auth/forgot_password_view.dart';
import 'package:crypt_chat/views/auth/sign_up_view.dart';
import 'package:crypt_chat/views/home_view.dart';
//import 'file:///F:/Flutter_Project/crypt_chat/lib/views/home_view.dart';
import 'package:crypt_chat/widgets/rounded_button.dart';
import 'package:crypt_chat/widgets/rounded_input_field.dart';
import 'package:crypt_chat/widgets/rounded_password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'file:///F:/Flutter_Project/crypt_chat/lib/views/auth/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:location/location.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  bool isLoading = false;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  // SharedPrefHelper sharedPrefHelper = new SharedPrefHelper();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  var lng, lat;

  Timer timer;

  Future<void> getLoca() async {
    final Location lc = Location();
    var gg = await lc.getLocation();
    lat = gg.latitude;
    lng = gg.longitude;
    // setState(() {});
    // print(gg.toString());
  }

  @override
  void initState() {
    super.initState();
    getLoca();
  }

  void loginUser() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      authMethods.LoginWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((val) async {
        if (val != null) {
          DocumentSnapshot loginSnapshot =
              await databaseMethods.getUserInfoByID(val.userID);

          // Generate session key
          String key = lng.toString() + lat.toString();

          // Make secure storage (Already have encript and decription techniques)
          // session release key add to the secure storage
          final storage = new FlutterSecureStorage();
          await storage.write(key: 'key_of_session', value: key);
          // Encript user Data
          String token;
          final jwt = JWT(loginSnapshot.data());
          token = jwt.sign(SecretKey(key));
          // Make session
          await FlutterSession().set(key, token);

          // // Email verification
          // if (!FirebaseAuth.instance.currentUser.emailVerified) {
          // await verifyEmail();
          // } else {
          // Navigate
          // Start session time out
          SessionTimerOut(context).sessionHandler();
          // Navigate
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
          // }
        } else {
          setState(() {
            isLoading = false;
          });
          SnackBar snackBar = SnackBar(
            content: Text('Email or Password incorrect!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          );
          // ignore: deprecated_member_use
          scaffoldKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  verifyEmail() async {
    User user = FirebaseAuth.instance.currentUser;
    user.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Email verification message sent. Please check your email.")));
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkVerifycation();
    });
  }

  checkVerifycation() {
    if (FirebaseAuth.instance.currentUser.emailVerified) {
      timer?.cancel();
      // Navigate
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
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
                child: Center(child: CircularProgressIndicator()),
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
                            "assets/images/login.png",
                            height: screenSize.height * 0.45,
                          ),
                          Text('LOGIN',
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
                              text: 'Login',
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              press: loginUser),
                          SizedBox(height: screenSize.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Don’t have an Account ? ',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .color)),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return SignUpScreen();
                                  }));
                                },
                                child: Text('Register',
                                    style: TextStyle(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Theme.of(context).primaryColor
                                            : Constants.kSecondaryColor,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          SizedBox(
                            height: screenSize.height * 0.01,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ForgotPassword();
                              }));
                            },
                            child: Text('Forgot Password',
                                style: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Theme.of(context).primaryColor
                                        : Constants.kSecondaryColor,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ],
                )));
  }
}
