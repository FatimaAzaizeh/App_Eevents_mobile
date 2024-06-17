import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/Alert/error.dart'; // Import your custom error alert
import 'package:testtapp/Alert/success.dart'; // Import your custom success alert
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/User.dart'; // Assuming you have a User model defined
import 'package:testtapp/widgets/AppBarEevents.dart'; // Assuming this is your custom AppBar
import 'package:testtapp/widgets/TextField_vendor.dart'; // Assuming this is a custom text field widget

final _auth = FirebaseAuth.instance;

class EditUserPage extends StatefulWidget {
  static const String screenRoute = 'EditProfile';

  EditUserPage();

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      User? currentUser = _auth.currentUser; // Fetching current user
      if (currentUser != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        if (snapshot.exists) {
          setState(() {
            _phoneController.text = snapshot['phone'];
            _addressController.text = snapshot['address'];
          });
        } else {
          print('Document does not exist');
        }
      } else {
        print('No user is currently signed in');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarEevents(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "المعلومات الشخصية",
                style: StyleTextAdmin(20, Colors.black),
              ),
            ),
            Container(
              width: 400,
              height: 230,
              decoration: BoxDecoration(
                border: Border.all(color: ColorPink_70, width: 3),
                borderRadius: BorderRadius.circular(20),
                color: ColorPink_20,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFieldVendor(
                      controller: _phoneController,
                      text: 'رقم الهاتف',
                    ),
                    SizedBox(height: 10),
                    TextFieldVendor(
                      controller: _addressController,
                      text: 'العنوان',
                    ),
                    SizedBox(height: 10),
                    showSpinner
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Container(
                            width: 130,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.4),
                                  width: 1),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                setState(() {
                                  showSpinner = true;
                                });
                                User? currentUser = _auth.currentUser;
                                if (currentUser != null) {
                                  String result = await UserDataBase.editUser(
                                    UID: currentUser.uid,
                                    phone: _phoneController.text,
                                    address: _addressController.text,
                                  );
                                  if (result ==
                                      'تم تحديث معلومات المستخدم بنجاح!') {
                                    SuccessAlert(context, result);
                                  } else {
                                    ErrorAlert(context, 'حدث خطأ', result);
                                  }
                                } else {
                                  ErrorAlert(context, 'حدث خطأ',
                                      'لم يتم العثور على بيانات المستخدم');
                                }
                                setState(() {
                                  showSpinner = false;
                                });
                              },
                              child: Text(
                                'حفظ التغييرات',
                                style: StyleTextAdmin(
                                    14, Colors.black), // Adjust style as needed
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
