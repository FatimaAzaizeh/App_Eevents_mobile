import 'package:flutter/material.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          alignment: Alignment.topCenter,
          child: CircleAvatar(
              //  maxRadius: 70, backgroundImage: NetworkImage(_imageUrl)

              // Show loading indicator when loading
              ),
        ),
      ),
    );
  }
}
