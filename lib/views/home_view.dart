import 'package:crypt_chat/utils/helpers/sessiontimeOut.dart';
import 'package:crypt_chat/views/chat_rooms_view.dart';
import 'package:crypt_chat/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class HomeScreen extends StatefulWidget {
  //final String text;
  //HomeScreen({Key key, @required this.text}) : super(key: key);

  @override
  //_HomeScreenState createState() => _HomeScreenState();
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 0;
  PageController _pageController;

  List<Widget> tabPages = [
    ChatRooms(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    openLockScreen(context);
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  Future<void> localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticateWithBiometrics(
      localizedReason: 'Please authenticate',
      // biometricOnly: true,
    );
    if (didAuthenticate) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future openLockScreen(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    // final inputController = InputController();

    // Find Pin fron secure storage
    final storage = new FlutterSecureStorage();
    String pin = await storage.read(key: 'pin_key');

    if (pin != "" && pin != null)
      screenLock<void>(
        context: context,
        correctString: pin,
        digits: pin.length,
        // confirmation: true,
        // inputController: inputController,
        canCancel: false,
        didConfirmed: (matchedText) {
          // ignore: avoid_print
          Navigator.pop(context);
        },
        customizedButtonChild: const Icon(
          Icons.fingerprint,
        ),
        customizedButtonTap: () async {
          await localAuth(context);
        },
        didOpened: () async {
          await localAuth(context);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    // Define it to control the confirmation state with its own events.

    return GestureDetector(
      onTap: () {
        SessionTimerOut(context).sessionHandler();
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          type: BottomNavigationBarType.fixed,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.message_rounded), label: "Chats"),
            BottomNavigationBarItem(
                icon: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/user_avatar.png"),
                  radius: 12,
                ),
                label: "Profile"),
          ],
        ),
        body: PageView(
          children: tabPages,
          onPageChanged: onPageChanged,
          controller: _pageController,
        ),
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      this._pageIndex = page;
    });
  }

  void onTabTapped(int index) {
    this._pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
}
