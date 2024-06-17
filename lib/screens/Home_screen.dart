import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Cart.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Service_screen.dart';
import 'package:testtapp/widgets/AppBarEevents.dart';
import 'package:testtapp/widgets/CustomBottomNavigationBar.dart';

import 'package:testtapp/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  static const String screenRoute = 'Home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Initially selected index for the home icon

  static List<Widget> _widgetOptions = <Widget>[
    ServiceScreen(), // Dashboard screen
    EventScreen(), // Event screen
    ShoppingCartPage(), // Cart screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onItemTapped: (int) {},
      ),
      appBar: AppBarEevents(),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
