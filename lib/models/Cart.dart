import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/models/Orders.dart';

class Cart {
  String userId;
  Map<String, Map<String, dynamic>>? vendors;

  Cart({required this.userId, this.vendors});

  // Method to add an item to the cart
  void addItem(String vendorId, String itemCode, String itemName,
      String itemImage, double price, int amount) {
    vendors ??= {};

    vendors!.putIfAbsent(vendorId, () => {});

    vendors![vendorId]![itemCode] = {
      'amount': amount,
      'item_code': itemCode,
      'item_name': itemName,
      'item_image': itemImage,
      'price': price,
    };

    updateFirestore();
  }

  // Method to update Firestore document with cart data
  Future<void> updateFirestore() async {
    try {
      CollectionReference cartCollection =
          FirebaseFirestore.instance.collection('cart');
      DocumentReference docRef =
          cartCollection.doc(FirebaseAuth.instance.currentUser!.uid);

      await docRef.set({
        'user_id': userId,
        'vendors': vendors,
      });
    } catch (error) {
      print('Error updating Firestore: $error');
    }
  }

  // Method to edit an item in the cart
  void editItem(String vendorId, String itemCode,
      {String? itemName, String? itemImage, double? price, int? amount}) {
    if (vendors != null &&
        vendors!.containsKey(vendorId) &&
        vendors![vendorId]!.containsKey(itemCode)) {
      if (itemName != null)
        vendors![vendorId]![itemCode]!['item_name'] = itemName;
      if (itemImage != null)
        vendors![vendorId]![itemCode]!['item_image'] = itemImage;
      if (price != null) vendors![vendorId]![itemCode]!['price'] = price;
      if (amount != null) vendors![vendorId]![itemCode]!['amount'] = amount;
      updateFirestore();
    }
  }

  // Method to delete an item from the cart
  void deleteItem(String vendorId, String itemCode) {
    if (vendors != null &&
        vendors!.containsKey(vendorId) &&
        vendors![vendorId]!.containsKey(itemCode)) {
      vendors![vendorId]!.remove(itemCode);
      if (vendors![vendorId]!.isEmpty) {
        vendors!.remove(vendorId);
      }
      updateFirestore();
    }
  }

  // Method to check if an item exists in the cart
  bool itemExists(String vendorId, String itemCode) {
    return vendors != null &&
        vendors!.containsKey(vendorId) &&
        vendors![vendorId]!.containsKey(itemCode);
  }

  // Method to edit the amount of an item in the cart
  void editItemAmount(String vendorId, String itemCode) {
    if (itemExists(vendorId, itemCode)) {
      int amount = vendors![vendorId]![itemCode]!['amount'];
      vendors![vendorId]![itemCode]!['amount'] = amount + 1;
      updateFirestore();
    } else {
      print('Item with vendorId: $vendorId and itemCode: $itemCode not found.');
    }
  }

  // Method to upload cart data to Firebase
  Future<String> uploadToFirebase() async {
    CollectionReference cartCollection =
        FirebaseFirestore.instance.collection('cart');
    try {
      DocumentReference docRef = cartCollection.doc(userId);
      if (vendors != null) {
        await docRef.set({
          'user_id': userId,
          'vendors': vendors,
        });
      }
      return 'DocumentSnapshot added with ID: $userId';
    } catch (error) {
      return 'Error adding document: $error';
    }
  }

  // Method to add an item to the cart based on vendorId
  void addItemByVendorId(String vendorId, String itemCode, String itemName,
      String itemImage, double price, int amount) {
    vendors ??= {};
    vendors!.putIfAbsent(vendorId, () => {});

    // Create a new map for the item data
    Map<String, dynamic> itemData = {
      'amount': amount,
      'item_code': itemCode,
      'item_name': itemName,
      'item_image': itemImage,
      'price': price,
    };

    // Add the item to the vendor's list
    vendors![vendorId]![itemCode] = itemData;

    // Update Firestore
    updateFirestore();
  }

  // Method to clear all items from the cart
  void clearCart() {
    vendors?.clear();
    updateFirestore();
  }

  // Method to move records from cart to orders
  Future<void> moveToOrders(double totalPrice, int totalItems) async {
    try {
      // Generate order ID from document ID
      String orderId = FirebaseFirestore.instance.collection('orders').doc().id;

      // Create an instance of Orders class
      Orders orders = Orders(
        orderId: orderId,
        userId: this.userId,
        vendors: vendors != null
            ? vendors!
            : {}, // Assign vendors with a default value if it's null
        totalPrice: totalPrice,
        totalItems: totalItems,
      );

      // Populate additional fields in orders
      final DateTime now = DateTime.now();
      final DateTime deliverAt =
          now.add(const Duration(days: 7)); // Example: Deliver after 7 days
      orders.vendors.values.forEach((vendorData) {
        vendorData['created_at'] = now;
        vendorData['deliver_at'] = deliverAt;
        vendorData['order_status_id'] =
            FirebaseFirestore.instance.collection('order_status').doc('1');
      });

      // Upload orders to Firebase
      await orders.uploadToFirebase();

      // Clear cart after moving records to orders
      clearCart();
    } catch (error) {
      print('Error moving records to orders: $error');
    }
  }
}
