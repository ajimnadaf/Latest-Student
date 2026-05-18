import 'package:flutter/material.dart';
import 'dart:async';

import 'package:student_app/LoginPage/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // _LoadAsync();
    Timer(
      Duration(seconds: 5), // Duration of the splash screen
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(), // Your login page
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color of splash screen
      body: Center(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add your splash screen content here, e.g., an image
              Image.asset(
                'assets/images/splashcreen2.gif',
                fit: BoxFit.cover, // Ensures the GIF covers the available space
              ),
              // Optional: Add more widgets if needed
            ],
          ),
        ),
      ),
    );
  }
}
