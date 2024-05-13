import 'package:flutter/material.dart';
import 'package:testtapp/Color.dart';
import 'package:testtapp/screens/Service_screen.dart';
import 'package:testtapp/widgets/app_drawer.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedScreenIndex = 0;
  late Map<String, Widget> _screens = {
    'الخدمات': Service(),
    'الرئيسية': Placeholder()
  };

  void _selectScreen(int index) {
    print("Index selected: $index");
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Selected index: $_selectedScreenIndex");
    return Scaffold(
      appBar: AppBar(
        title: Text(_screens.keys.elementAt(_selectedScreenIndex)),
      ),
      drawer: AppDrawer(),
      body: _screens.values.elementAt(_selectedScreenIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        backgroundColor: ColorPink_100,
        selectedItemColor: ColorPink_100,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedScreenIndex,
        items: [
          BottomNavigationBarItem(
            backgroundColor: ColorPink_100,
            icon: Icon(Icons.dashboard),
            label: 'الخدمات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'الرئيسية',
          ),
        ],
      ),
    );
  }
}
