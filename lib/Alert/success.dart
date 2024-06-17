import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';

Future<void> SuccessAlert(BuildContext context, String content) async {
  return QuickAlert.show(
      context: context,
      customAsset: 'assets/images/Completionanimation.gif',
      width: 300,
      title: '',
      widget: Text(
        content,
        style: StyleTextAdmin(18, Colors.black),
      ),
      type: QuickAlertType.success,
      confirmBtnText: 'إغلاق',
      confirmBtnTextStyle: StyleTextAdmin(20, Colors.white));
}
