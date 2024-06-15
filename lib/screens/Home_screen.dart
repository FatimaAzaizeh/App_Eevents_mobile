import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Cart.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Service_screen.dart';
import 'package:testtapp/widgets/AppBarEevents.dart';
import 'package:testtapp/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  static const String screenRoute = 'Home_screen';
  const HomeScreen({Key? key, }) : super(key: key);
 
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Initially selected index for the home icon

  // Global keys for tutorial
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _cartKey = GlobalKey();

  static List<Widget> _widgetOptions = <Widget>[
    Service(), // Dashboard screen
    EventScreen(), // Event screen
    ShoppingCartPage(), // Cart screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool hasSeenTutorial = false; // Default value

  @override
  void initState() {
    super.initState();
   
  }


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onItemTapped: (int) {},
      ),
      appBar: AppBarEevents(),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: ColorPink_20,
        color: Colors.white,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onItemTapped,
        index: _selectedIndex, // Set the default selected index
        items: <Widget>[
          Icon(
            Icons.dashboard,
            key: _dashboardKey,
            color: ColorPink_100,
          ),
          Icon(
            Icons.home,
            key: _homeKey,
            color: ColorPink_100,
          ),
          Icon(
            Icons.shopping_cart,
            key: _cartKey,
            color: ColorPink_100,
          ),
        ],
      ),
    );
  }
}



