import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  String sharedPrefUserLoggedInKey = 'ISLOGGEDIN';
  String sharedPrefUsernameKey = 'USERNAMEKEY';
  String sharedPrefUserEmailKey = 'USEREMAILKEY';

  //Saving user shared prefs
  Future<bool> saveUserLoggedInSharedPref(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPrefUserLoggedInKey, isUserLoggedIn);
  }

  Future<bool> saveUserKeySharedPref(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('user_key', key);
  }

  Future<bool> saveUsernameSharedPref(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefUsernameKey, username);
  }

  Future<bool> saveUserProfileSharedPref(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefUsernameKey, username);
  }

  Future<bool> saveUserEmailSharedPref(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPrefUserEmailKey, userEmail);
  }

  //Getting user shared prefs
  Future<bool> getUserLoggedInSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(sharedPrefUserLoggedInKey);
  }

  Future<String> getUsernameSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPrefUsernameKey);
  }

  Future<String> getUserProfileSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPrefUsernameKey);
  }

  Future<String> getUserEmailSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPrefUserEmailKey);
  }

  Future<String> getUserKeyDataSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_key');
  }
}
