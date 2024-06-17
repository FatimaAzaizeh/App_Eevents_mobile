import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';

Future<void> InfoAlert(
    BuildContext context, String title, String content) async {
  return QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      width: 440,
      customAsset: 'assets/images/info.gif', // Replace with your asset path
      title: '',
      widget: Column(
        children: [
          Text(
            title,
            style: StyleTextAdmin(25, Colors.black), // Custom style for title
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: StyleTextAdmin(14, AdminButton), // Custom style for text
          ),
          SizedBox(height: 10),
        ],
      ),
      confirmBtnText: 'حسناً',
      confirmBtnTextStyle: StyleTextAdmin(16, Colors.white),
      backgroundColor: Colors.white,
      confirmBtnColor: AdminButton.withOpacity(0.8));
}
