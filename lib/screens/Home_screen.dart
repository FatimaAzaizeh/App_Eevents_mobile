import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Service_screen.dart';
import 'package:testtapp/screens/cart_screen.dart';
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
    Service(), // Dashboard screen
    EventScreen(), // Event screen
    cartScreen(), // Cart screen
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
      appBar: AppBar(
        backgroundColor: ColorPink_100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo2.png', // Replace this with your image path
                height: 100, // Adjust the height as needed
              ),
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: ColorPink_20,
        color: ColorPink_100,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onItemTapped,
        index: _selectedIndex, // Set the default selected index
        items: <Widget>[
          Icon(
            Icons.dashboard,
            color: Colors.white,
          ),
          Icon(
            Icons.home,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
