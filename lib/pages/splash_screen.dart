import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay before navigating to the next screen
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home'); // Replace with your route
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Splash background color
      body: Center(
        child: Image.asset(
          'assets/logos/costcaterlogo.jpg',
          width: 200, // Adjust the size
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
