import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: ColorPink_20, // Adjust as needed
      color: Colors.white,
      animationDuration: Duration(milliseconds: 300),
      onTap: onItemTapped,
      index: selectedIndex, // Set the default selected index
      items: <Widget>[
        Icon(
          Icons.dashboard,
          color: ColorPink_100,
        ),
        Icon(
          Icons.home,
          color: ColorPink_100,
        ),
        Icon(
          Icons.shopping_cart,
          color: ColorPink_100,
        ),
      ],
    );
  }
}
