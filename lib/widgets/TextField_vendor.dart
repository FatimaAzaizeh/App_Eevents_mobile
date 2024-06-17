import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class TextFieldVendor extends StatelessWidget {
  const TextFieldVendor({
    Key? key,
    required TextEditingController controller,
    required this.text,
  })  : _controller = controller,
        super(key: key);

  final TextEditingController _controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: StyleTextAdmin(16, AdminButton), // Adjusted text style
      controller: _controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black.withOpacity(0.5),
              width: 0.5), // Assuming ColorPink_70 is defined in constants.dart
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelText: text, // Use the passed text parameter here
        labelStyle: StyleTextAdmin(
            18, Colors.black.withOpacity(0.8)), // Adjusted label text style
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
