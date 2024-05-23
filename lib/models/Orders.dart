import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  String orderId;
  String userId;
  Map<String, Map<String, dynamic>> vendors;
  double totalPrice;
  int totalItems;

  Orders({
    required this.orderId,
    required this.userId,
    required this.vendors,
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
        'vendors': vendors.map((key, value) {
          return MapEntry(
            key.toString(),
            {
              'vendor_id': value['vendor_id'],
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

      print('Orders uploaded to Firebase successfully!');
    } catch (e) {
      print('Error uploading orders to Firebase: $e');
    }
  }
}
