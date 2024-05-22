import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  String orderId;
  String userId;
  Map<int, Map<String, dynamic>> vendors;

  Orders({
    required this.orderId,
    required this.userId,
    required this.vendors,
  });

  Future<void> uploadToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Specify the custom document ID
    String customId = this.orderId;

    // Reference to the collection where you want to add the document
    CollectionReference collectionReference = firestore.collection('orders');

    try {
      // Add the document with the custom ID
      await collectionReference.doc(customId).set({
        'order_id': orderId,
        'user_id': userId,
        'vendors': vendors.map((key, value) {
          return MapEntry(
            key.toString(),
            {
              'vendor_id': key,
              'created_at': value['created_at'],
              'deliver_at': value['deliver_at'],
              'order_status_id': value['order_status_id'],
              'price': value['price'],
              'vendor_id_items': value['vendor_id_items'].map((k, v) {
                return MapEntry(
                  k.toString(),
                  {
                    'amount': v['amount'],
                    'item_code': v['item_code'],
                    'item_name': v['item_name'],
                  },
                );
              }),
            },
          );
        }),
      });
    } catch (e) {
      print('Error uploading to Firebase: $e');
    }
  }
}
