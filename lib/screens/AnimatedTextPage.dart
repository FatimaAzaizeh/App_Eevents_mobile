import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/screens/login_signup.dart';

class AnimatedTextPage extends StatefulWidget {
  static const String screenRoute = 'AnimatedTextPage';
  @override
  _AnimatedTextPageState createState() => _AnimatedTextPageState();
}

class _AnimatedTextPageState extends State<AnimatedTextPage> {
  String textToShow = '';

  @override
  void initState() {
    super.initState();
    startTextAnimation();
  }

  // Function to animate the text
  void startTextAnimation() {
    const text = 'Eeventş';
    const duration = Duration(milliseconds: 700); // Adjust duration as needed
    int index = 0;

    Timer.periodic(duration, (Timer timer) {
      setState(() {
        if (index < text.length) {
          textToShow += text[index];
          index++;
        } else {
          timer.cancel();
          Navigator.popAndPushNamed(context, LoginSignupScreen.screenRoute);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/event.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Centered Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use Flexible to allow the Text widget to expand
                Flexible(
                  child: Text(
                    textToShow,
                    style: TextStyle(
                      fontSize: 90,
                      fontFamily: 'DancingScript',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center, // Center-align the text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
