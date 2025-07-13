import 'package:flutter/material.dart';

//SCREENS
import 'homepage.dart';
import 'loginpage.dart';

//UTILS
import '../utils/impact.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  // Widget that create the Splashpage
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () => _checkStatus(context));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 239, 221),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Image.asset('immagini/logo_StrongRoots.png', scale: 1),
        ),
      ),
    );
  }

  // Methods to navigate to different page based on token status
  // TO HOMEPAGE
  void _toHomePage(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  // TO LOGINPAGE
  void _toLoginPage(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: ((context) => LoginPage())));
  }

  // Method for checking if the user has still valid tokens
  void _checkStatus(BuildContext context) async {
    final result = await Impact().refreshTokens();
    if (result == 200) {
      _toHomePage(context);
    } else {
      _toLoginPage(context);
    }
  }
}// Splash