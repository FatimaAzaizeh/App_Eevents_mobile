import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/screens/EditProfile.dart';
import 'package:testtapp/screens/order_history.dart';
import 'package:testtapp/screens/order_status.dart';
import 'package:testtapp/screens/login_signup.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key, required Null Function(dynamic int) onItemTapped})
      : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _auth = FirebaseAuth.instance;
  int _selectedIndex =
      -1; // Track the selected index, -1 means none is selected

  // List of avatar images
  final List<String> _avatarImages = [
    'assets/images/img_user1.png',
    'assets/images/img_user2.png',
    'assets/images/img_user3.png',
    'assets/images/img_user4.png',
    // Add more URLs as needed
  ];

  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    // Select a random image from the list
    _selectedAvatar = _avatarImages[Random().nextInt(_avatarImages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                  backgroundImage: AssetImage(_selectedAvatar),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'userName',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'userEmail',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: ListView(
              children: [
                buildListTile(
                  'عرض الطلبات السابقة',
                  Icons.history,
                  () {
                    Navigator.pushNamed(context, orderhistory.screenRoute);
                  },
                  1,
                ),
                SizedBox(height: 20), // Add SizedBox here for spacing
                buildListTile(
                  'حالة الطلب',
                  Icons.assignment_turned_in_outlined,
                  () {
                    Navigator.pushNamed(context, orderstatus.screenRoute);
                  },
                  2,
                ),
                SizedBox(height: 20), // Add SizedBox here for spacing
                buildListTile(
                  'تسجيل الخروج',
                  Icons.logout,
                  () {
                    _auth.signOut();
                    Navigator.pushReplacementNamed(
                        context, LoginSignupScreen.screenRoute);
                  },
                  3,
                ),

                buildListTile(
                  'اعدادات الملف الشخصي',
                  Icons.manage_accounts,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPage(
                            userId: _auth.currentUser!.uid.toString()),
                      ),
                    );
                  },
                  3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildListTile(
      String title, IconData icon, Function() onPress, int index) {
    return Expanded(
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Icon(
          icon,
          size: 28,
          color: Colors.black, // Color changes based on the selection
          shadows: [BoxShadow(color: Colors.black, offset: Offset(0, 2))],
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, color: Colors.black),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index; // Update the selected index
            onPress();
          });
        },
        selected: _selectedIndex == index,
        selectedTileColor: Colors.white,
        hoverColor: Colors.white,
      ),
    );
  }
}
