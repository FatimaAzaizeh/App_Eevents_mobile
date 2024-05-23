import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  String orderId;
  String userId;
  Map<String, Map<String, dynamic>> vendors; // Remove the '?' here
  double totalPrice;
  int totalItems;

  Orders({
    required this.orderId,
    required this.userId,
    required this.vendors, // Remove the '?' here
    required this.totalPrice,
    required this.totalItems,
  });

  Future<void> uploadToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Reference to the collection where you want to add the document
      CollectionReference collectionReference = firestore.collection('orders');

      // Add the document with the generated order ID
      await collectionReference.doc(orderId).set({
        'order_id': orderId,
        'user_id': userId,
        'total_price': totalPrice,
        'total_items': totalItems,
        'vendors': vendors,
      });

      // Optionally, you can add additional fields here if needed

      print('Orders uploaded to Firebase successfully!');
    } catch (e) {
      print('Error uploading orders to Firebase: $e');
    }
  }
}
