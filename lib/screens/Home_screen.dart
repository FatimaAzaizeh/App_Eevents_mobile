import 'package:flutter/material.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/widgets/AppBarEebvents.dart';
import 'package:testtapp/widgets/app_drawer.dart';
import 'package:testtapp/widgets/bottombar.dart';

class HomeScreen extends StatefulWidget {
  static const String screenRoute = 'Home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarEebvents(), // Correct usage of appBar
      drawer: AppDrawer(
        onItemTapped: (int) {},
      ),
      body: EventScreen(),
      bottomNavigationBar: BottomBar(),
    );
  }
}
