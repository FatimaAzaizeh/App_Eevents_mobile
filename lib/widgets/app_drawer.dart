import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _auth = FirebaseAuth.instance;

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
                  // backgroundImage: NetworkImage(userImage),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ' userName',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
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
          buildListTile(
            'أضافة مسؤول جديد',
            Icons.person_add_alt,
            () {
              //  widget.changeMainSection(AddAdmin());
            },
            1,
          ),
          SizedBox(height: 20), // Add SizedBox here for spacing
          buildListTile(
            'طلبات إنشاء حسابات الشركاء ',
            Icons.add_business_outlined,
            () {
              //  widget.changeMainSection(ListReq());
            },
            2,
          ),
          SizedBox(height: 20), // Add SizedBox here for spacing
          buildListTile(
            'تسجيل حدث أو مناسبة جديدة',
            Icons.post_add,
            () {
              //widget.changeMainSection(AddEvent());
            },
            3,
          ),
          SizedBox(height: 20), // Add SizedBox here for spacing
          buildListTile(
            'الخدمات الخاصة بالمناسبات',
            Icons.room_service_outlined,
            () {
              // widget.changeMainSection(AddService());
            },
            4,
          ),
          SizedBox(height: 20), // Add SizedBox here for spacing
          buildListTile(
            'إدارة حسابات الشركاء',
            Icons.account_circle_outlined,
            () {
              setState(() {
                //widget.changeMainSection(VendorList());
              });
              // widget.changeMainSection(VendorList());
            },
            5,
          ),
          SizedBox(height: 20), // Add SizedBox here for spacing
          buildListTile(
            'إدارة الأصناف والخدمات ',
            Icons.add_task,
            () {
              //     widget.changeMainSection(AllAdmin());
            },
            6,
          ),
          SizedBox(height: 20), // Add SizedBox here for spacing
          buildListTile(
            'تسجيل الخروج',
            Icons.logout,
            () {
              _auth.signOut();
              Navigator.pop(context);
              //   widget.changeMainSection(VendorList());
            },
            7,
          ),
        ],
      ),
    );
  }

  int _selectedIndex = -1;
  // Track the selected index, -1 means none is selected
  Expanded buildListTile(
      String title, IconData icon, Function() onPress, int index) {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
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
          // Add more ListTiles if needed
        ],
      ),
    );
  }
}
