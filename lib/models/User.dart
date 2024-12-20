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

  Future<String> saveToDatabase() async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Check if the user already exists
      QuerySnapshot querySnapshot =
          await users.where('UID', isEqualTo: UID).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'User with ID $UID already exists.';
      }

      // Add the new user to the database
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

      return 'User added to the database successfully!';
    } catch (error) {
      return 'Error adding user to the database: $error';
    }
  }

  static Future<String> editUser({
    required String UID,
    String? phone,
    String? address,
  }) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      DocumentSnapshot userDoc = await users.doc(UID).get();

      if (!userDoc.exists) {
        return 'User with ID $UID does not exist.';
      }

      Map<String, dynamic> updatedData = {};

      if (phone != null) updatedData['phone'] = phone;
      if (address != null) updatedData['address'] = address;

      await users.doc(UID).update(updatedData);

      return 'تم تحديث معلومات المستخدم بنجاح!';
    } catch (error) {
      return 'خطأ في تحديث معلومات المستخدم: $error';
    }
  }

  static Future<bool> isUserTypeReferenceValid(
      String userId, DocumentReference user_type) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('UID', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;
        return userSnapshot['user_type_id'] == user_type;
      } else {
        return false;
      }
    } catch (error) {
      print('Error checking user type reference validity: $error');
      return false;
    }
  }

  static Future<bool> isVendorActive(String vendorId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(vendorId)
        .get();
    if (userSnapshot.exists) {
      bool isActive = userSnapshot['is_active'];
      return isActive;
    }
    return false;
  }

  static Future<String> fetchBusinessName(String vendorId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('vendor')
          .doc(vendorId)
          .get();
      return snapshot.data()?['business_name'] ?? '';
    } catch (e) {
      print('Error fetching business name: $e');
      return '';
    }
  }

  static Future<bool> checkUserDataExists(String userId) async {
    var snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      var data = snapshot.data();
      return data!['address'].toString().isNotEmpty &&
          data['phone'].toString().isNotEmpty;
    }

    return false;
  }
}
