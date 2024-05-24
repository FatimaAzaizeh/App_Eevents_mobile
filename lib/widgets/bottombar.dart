import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Cart.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Service_screen.dart';
import 'package:testtapp/screens/cart_screen.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    Service(),
    EventScreen(),
    ShoppingCartPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: ColorPink_20,
      color: ColorPink_100,
      animationDuration: Duration(milliseconds: 300),
      onTap: _onItemTapped,
      index: _selectedIndex,
      items: <Widget>[
        Icon(Icons.dashboard, color: Colors.white),
        Icon(Icons.home, color: Colors.white),
        Icon(Icons.shopping_cart, color: Colors.white),
      ],
    );
  }
}
