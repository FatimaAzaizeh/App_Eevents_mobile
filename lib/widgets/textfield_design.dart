// This import statement brings in the Flutter Material package,
// which contains widgets and utilities to build Material Design applications.
import 'package:flutter/material.dart';

// CustomTextField is a stateless widget for creating customizable text fields.
class CustomTextField extends StatelessWidget {
  // Properties of the text field widget.
  final String hintText; // Hint text displayed when the field is empty.
  final TextInputType keyboardType; // Type of keyboard to be displayed.
  final Function(String)
      onChanged; // Callback function triggered when the text changes.
  final bool
      obscureText; // Boolean flag to hide the text (e.g., for password input).

  // Constructor for initializing the properties.
  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.keyboardType,
    required this.onChanged,
    required this.obscureText,
  }) : super(key: key);

  // Build method to create the actual widget.
  @override
  Widget build(BuildContext context) {
    // TextField widget is used to create an input field.
    return TextField(
      // Set the keyboard type for the text field.
      keyboardType: keyboardType,
      // Determine whether to obscure the text (e.g., for passwords).
      obscureText: obscureText,
      // Align text to the center of the text field.
      textAlign: TextAlign.center,
      // Define the callback function to be called when text changes.
      onChanged: onChanged,
      // Define the appearance of the text field.
      decoration: InputDecoration(
        // Display hint text when the field is empty.
        hintText: hintText,
        hintTextDirection:
            TextDirection.rtl, // Align the hint text to the right,
        hintStyle: TextStyle(
            fontFamily: 'Amiri', fontSize: 18, fontStyle: FontStyle.italic),
        // Define padding for the content inside the text field.
        contentPadding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        // Define the appearance of the border around the text field.
        border: OutlineInputBorder(
          // Define the color and width of the border.
          borderSide: BorderSide(
            color: Color.fromARGB(206, 158, 158, 158),
            width: 1,
          ),
          // Define the border radius to create rounded corners.
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        // Define the appearance of the border when the text field is focused.
        focusedBorder: OutlineInputBorder(
          // Define the color and width of the focused border.
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2,
          ),
          // Define the border radius for the focused border.
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}
