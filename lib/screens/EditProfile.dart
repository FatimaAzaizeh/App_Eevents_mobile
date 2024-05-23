import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/models/User.dart';

class EditUserPage extends StatefulWidget {
  static const String screenRoute = 'EditProfile';
  final String userId;

  EditUserPage({required this.userId});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  String? _phone;
  String? _address;

  Future<void> _editUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String result = await UserDataBase.editUser(
        UID: widget.userId,
        phone: _phone,
        address: _address,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                onSaved: (value) => _phone = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                onSaved: (value) => _address = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editUser,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
