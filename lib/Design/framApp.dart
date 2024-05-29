import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Cart.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Home_screen.dart';
import 'package:testtapp/screens/Service_screen.dart';
import 'package:testtapp/screens/cart_screen.dart';
import 'package:testtapp/widgets/AppBarEevents.dart';
import 'package:testtapp/widgets/app_drawer.dart';

class FramApp extends StatefulWidget {
  final Widget pageDisplay;
  static const String screenRoute = 'framApp';
  const FramApp({Key? key, required this.pageDisplay}) : super(key: key);

  @override
  _FramAppState createState() => _FramAppState();
}

class _FramAppState extends State<FramApp> {
  int _selectedIndex = 0; // Initially selected index for the home icon

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      widget.pageDisplay,
      Service(), // Dashboard screen
      HomeScreen(), // Event screen
      ShoppingCartPage(), // Cart screen
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onItemTapped: (index) {
          // Handle drawer item tap here
        },
      ),
      appBar: AppBarEevents(),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: ColorPink_20,
        color: Colors.white,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onItemTapped,
        index: _selectedIndex.clamp(0, _widgetOptions.length - 1),
        // Ensure index is within valid range
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
      ),
    );
  }
}
