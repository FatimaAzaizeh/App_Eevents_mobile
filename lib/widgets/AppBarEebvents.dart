import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class AppBarEebvents extends StatelessWidget implements PreferredSizeWidget {
  static const String screenRoute = 'AppBarEebvents';
  const AppBarEebvents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
