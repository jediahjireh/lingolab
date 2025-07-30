import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lingolab/screens/level_screen.dart';
import '../auth_screen/sign_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), checkAuthState);
  }

  void checkAuthState() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // if user is already signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LevelScreen()),
      );
    } else {
      // if user is not signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // import panda eating popcorn animation
            Lottie.asset(
              'assets/animation/panda-popcorn.json',
              width: 600,
              height: 600,
            ),
            // app name positioned directly below lottie animation
            const Positioned(
              bottom: 150,
              child: Text(
                "LingoLab",
                style: TextStyle(
                  color: Color(0xFFFFF9C4),
                  fontSize: 50,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
