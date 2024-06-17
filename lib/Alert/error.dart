import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';

Future<void> ErrorAlert(
    BuildContext context, String title, String content) async {
  return QuickAlert.show(
      context: context,
      title: '',
      width: 400,
      customAsset: 'assets/images/error.gif',
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
      type: QuickAlertType.error,
      confirmBtnText: 'حسناً',
      confirmBtnTextStyle: StyleTextAdmin(16, Colors.white),
      backgroundColor: Colors.white,
      confirmBtnColor: AdminButton.withOpacity(0.8));
}
