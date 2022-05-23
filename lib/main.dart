import 'package:crypt_chat/theme.dart';
import 'package:crypt_chat/views/home_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:crypt_chat/views/welcome_view.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session/flutter_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn;
  bool isDarkModeEnabled = false;

  @override
  void initState() {
    // setState(() {
    // });
    super.initState();
    getLoggedInState();
  }

  /// Called when the state (day / night) has changed.
  void onStateChanged() {
    setState(() {
      isDarkModeEnabled = !isDarkModeEnabled;
    });
  }

  getLoggedInState() async {
    // Session Key Release
    final storage = new FlutterSecureStorage();
    String key_value = await storage.read(key: 'key_of_session');
    // Find session Data
    dynamic token = await FlutterSession().get(key_value);
    // Check auth
    if (token != null && token != '') {
      setState(() {
        isLoggedIn = true;
      });
    }
    // else {
    //   setState(() {
    //     isLoggedIn = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CryptChat',
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      themeMode: isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: isLoggedIn != null
          ? isLoggedIn
              ? Scaffold(
                  body: HomeScreen(),
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: FloatingActionButton(
                      elevation: 10,
                      backgroundColor:
                          isDarkModeEnabled ? Colors.white : Colors.grey[700],
                      onPressed: () => {onStateChanged()},
                      child: Icon(
                        isDarkModeEnabled ? Icons.light_mode : Icons.dark_mode,
                        color: isDarkModeEnabled ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.miniStartFloat,
                )
              : WelcomeScreen()
          : WelcomeScreen(),
    );
  }
}
