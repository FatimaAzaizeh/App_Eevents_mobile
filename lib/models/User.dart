import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataBase {
  final String UID;
  final String email;
  final String name;
  final DocumentReference user_type_id;
  final String phone;
  final String address;
  final bool isActive;
  final String imageUrl;

  UserDataBase({
    required this.UID,
    required this.email,
    required this.name,
    required this.user_type_id,
    required this.phone,
    required this.address,
    required this.isActive,
    required this.imageUrl,
  });

  Future<bool> saveToDatabase() async {
    try {
      // Reference to the Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Check if the user already exists
      QuerySnapshot querySnapshot =
          await users.where('UID', isEqualTo: UID).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        // User already exists
        print('User with ID $UID already exists.');
        return false;
      }

      // Set the document with custom ID (UID)
      await users.doc(UID).set({
        'UID': UID,
        'email': email,
        'name': name,
        'user_type_id': user_type_id,
        'phone': phone,
        'address': address,
        'is_active': isActive,
        'Image_url': imageUrl,
      });

      print('User added to the database successfully!');
      return true;
    } catch (error) {
      print('Error adding user to the database: $error');
      return false;
    }
  }

  // Check user_type_id

  static Future<bool> isUserTypeReferenceValid(
      String userId, DocumentReference user_type) async {
    try {
      // Get a reference to the user document
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('UID', isEqualTo: userId)
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming id is unique)
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;

        // Check if the user_type_id reference matches the expected reference
        return userSnapshot['user_type_id'] == user_type;
      } else {
        // User document does not exist
        print('User document with ID $userId does not exist.');
        return false;
      }
    } catch (error) {
      print('Error checking user type reference validity: $error');
      return false;
    }
  }
}
