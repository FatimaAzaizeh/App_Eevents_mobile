import 'package:flutter/material.dart';

class Palette {
  static const Color iconColor = Color.fromARGB(255, 149, 164, 173);
  static const Color activeColor = Color(0xFF09126C);
  static const Color textColor1 = Color.fromARGB(255, 104, 118, 125);
  static const Color textColor2 = Color.fromARGB(255, 106, 124, 134);
  static const Color googelColor = Color(0xFFDE4B39);
}

//"The main color of the app."
//Purple
const ColorPurple_100 = Color.fromARGB(255, 189, 140, 177);
Color ColorPurple_70 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.7);
Color ColorPurple_50 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.5);
Color ColorPurple_20 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.2);

//Pink
const ColorPink_100 = Color.fromARGB(255, 214, 170, 173);
Color ColorPink_70 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.7);
Color ColorPink_50 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.5);
Color ColorPink_20 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.2);

//Cream
const ColorCream_100 = Color.fromARGB(255, 225, 189, 158);
Color ColorCream_70 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.7);
Color ColorCream_50 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.5);
Color ColorCream_20 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.2);

const AdminButton = Color.fromARGB(255, 68, 67, 67);
TextStyle StyleTextAdmin(double SizeText, Color colorText) {
  return TextStyle(
      fontFamily: 'Marhey',
      fontSize: SizeText,
      fontWeight: FontWeight.w600,
      color: colorText);
}

// Global keys for tutorial
final GlobalKey _dashboardKey = GlobalKey();
final GlobalKey _homeKey = GlobalKey();
final GlobalKey _cartKey = GlobalKey();
