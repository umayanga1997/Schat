import 'package:crypt_chat/model/user.dart';
// import 'package:crypt_chat/utils/helpers/shared_pref_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session/flutter_session.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserClass _userFromFirebaseUser(User firebaseUser) {
    return firebaseUser != null ? UserClass(userID: firebaseUser.uid) : null;
  }

  // ignore: non_constant_identifier_names
  Future LoginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e);
    }
  }

  // ignore: non_constant_identifier_names
  Future SignUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e);
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future signOut() async {
    try {
      // Find key after Remove all of the data from secure storage
      final storage = new FlutterSecureStorage();
      String key_value = await storage.read(key: 'key_of_session');
      storage.delete(key: "key_of_session");
      // Set null value to Session
      await FlutterSession().set(key_value, null);

      return await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
