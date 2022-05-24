import 'dart:async';

import 'package:crypt_chat/views/welcome_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session/flutter_session.dart';

Timer sessionTimer;

class SessionTimerOut {
  final BuildContext context;

  SessionTimerOut(this.context);

  Future<void> sessionHandler() async {
    // if (!sessionTimer.isActive) {}
    try {
      if (sessionTimer != null) sessionTimer?.cancel();

      sessionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        timeOut();
      });
    } catch (e) {}
  }

  timeOut() async {
    try {
      sessionTimer?.cancel();
      // Find key after Remove all of the data from secure storage
      final storage = new FlutterSecureStorage();
      String key_value = await storage.read(key: 'key_of_session');
      // storage.deleteAll();
      // Set null value to Session
      await FlutterSession().set(key_value, '');

      await FirebaseAuth.instance.signOut();
      Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()));
      // _navigator.currentState
      //     .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } catch (e) {
      print(e);
    }
  }
}
