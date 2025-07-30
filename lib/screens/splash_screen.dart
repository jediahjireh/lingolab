import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // TODO: navigate to home screen after a few seconds
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
              'assets/animation/animation.json',
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
