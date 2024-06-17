import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/EditProfile.dart';
import 'package:testtapp/screens/OrderHistory.dart';
import 'package:testtapp/screens/login_signup.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key, required Null Function(dynamic int) onItemTapped})
      : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _auth = FirebaseAuth.instance;
  int _selectedIndex = -1;
  final List<String> _avatarImages = [
    'assets/images/img_user1.png',
    'assets/images/img_user2.png',
    'assets/images/img_user3.png',
    'assets/images/img_user4.png',
  ];
  late String _selectedAvatar;
  String userName = 'Loading...';
  String userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _selectedAvatar = _avatarImages[Random().nextInt(_avatarImages.length)];
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    if (_auth.currentUser != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      setState(() {
        userName = userDoc['name'];
        userEmail = userDoc['email'];
      });
    }
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
                    userName,
                    style: StyleTextAdmin(
                      20,
                      Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    userEmail,
                    style: StyleTextAdmin(16, Colors.grey),
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
                    Navigator.pushNamed(context, OrderHistoryPage.screenRoute);
                  },
                  1,
                ),
                SizedBox(height: 20),
                buildListTile(
                  'اعدادات الملف الشخصي',
                  Icons.manage_accounts,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPage(),
                      ),
                    );
                  },
                  2,
                ),
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
          color: Colors.black,
          shadows: [BoxShadow(color: Colors.black, offset: Offset(0, 2))],
        ),
        title: Text(
          title,
          style: StyleTextAdmin(14, Colors.black),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
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
