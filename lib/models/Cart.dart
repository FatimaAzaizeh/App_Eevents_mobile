import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_sender/email_sender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/models/Orders.dart';

class Cart {
  String userId;
  Map<String, Map<String, dynamic>> vendors;

  Cart({required this.userId, Map<String, Map<String, dynamic>>? vendors})
      : vendors = vendors ?? {};

  // Method to add an item to the cart
  String addItem(String vendorId, String itemCode, String itemName,
      String itemImage, double price, int amount) {
    vendors.putIfAbsent(vendorId, () => {});

    if (vendors[vendorId]!.containsKey(itemCode)) {
      vendors[vendorId]![itemCode]['amount'] += amount;
    } else {
      vendors[vendorId]![itemCode] = {
        'amount': amount,
        'item_code': itemCode,
        'item_name': itemName,
        'item_image': itemImage,
        'price': price,
      };
    }

    updateFirestore();
    return 'Item added to cart.';
  }

  // Method to update Firestore document with cart data
  Future<String> updateFirestore() async {
    try {
      CollectionReference cartCollection =
          FirebaseFirestore.instance.collection('cart');
      DocumentReference docRef =
          cartCollection.doc(FirebaseAuth.instance.currentUser!.uid);

      await docRef.set({
        'user_id': userId,
        'vendors': vendors,
      });
      return 'Cart data updated successfully.';
    } catch (error) {
      return 'Error updating Firestore: $error';
    }
  }

  // Method to edit an item in the cart
  String editItem(String vendorId, String itemCode,
      {String? itemName, String? itemImage, double? price, int? amount}) {
    if (vendors.containsKey(vendorId) &&
        vendors[vendorId]!.containsKey(itemCode)) {
      if (itemName != null)
        vendors[vendorId]![itemCode]['item_name'] = itemName;
      if (itemImage != null)
        vendors[vendorId]![itemCode]['item_image'] = itemImage;
      if (price != null) vendors[vendorId]![itemCode]['price'] = price;
      if (amount != null) vendors[vendorId]![itemCode]['amount'] = amount;
      updateFirestore();
      return 'Item edited successfully.';
    } else {
      return 'Item not found in cart.';
    }
  }

  // Method to delete an item from the cart
  String deleteItem(String vendorId, String itemCode) {
    if (vendors.containsKey(vendorId) &&
        vendors[vendorId]!.containsKey(itemCode)) {
      vendors[vendorId]!.remove(itemCode);
      if (vendors[vendorId]!.isEmpty) {
        vendors.remove(vendorId);
      }
      updateFirestore();
      return 'Item deleted from cart.';
    } else {
      return 'Item not found in cart.';
    }
  }

  // Method to check if an item exists in the cart
  bool itemExists(String vendorId, String itemCode) {
    return vendors.containsKey(vendorId) &&
        vendors[vendorId]!.containsKey(itemCode);
  }

  // Method to edit the amount of an item in the cart
  String editItemAmount(String vendorId, String itemCode, int amount) {
    if (itemExists(vendorId, itemCode)) {
      vendors[vendorId]![itemCode]['amount'] += amount;
      updateFirestore();
      return 'Item amount updated successfully.';
    } else {
      return 'Item not found in cart.';
    }
  }

  // Method to upload cart data to Firebase
  Future<String> uploadToFirebase() async {
    CollectionReference cartCollection =
        FirebaseFirestore.instance.collection('cart');
    try {
      DocumentReference docRef = cartCollection.doc(userId);
      if (vendors.isNotEmpty) {
        await docRef.set({
          'user_id': userId,
          'vendors': vendors,
        });
      }
      return 'Cart data uploaded to Firebase.';
    } catch (error) {
      return 'Error uploading cart data: $error';
    }
  }

  // Method to add an item to the cart based on vendorId
  void addItemByVendorId(String vendorId, String itemCode, String itemName,
      String itemImage, double price, int amount) {
    vendors.putIfAbsent(vendorId, () => {});

    Map<String, dynamic> itemData = {
      'amount': amount,
      'item_code': itemCode,
      'item_name': itemName,
      'item_image': itemImage,
      'price': price,
    };

    vendors[vendorId]![itemCode] = itemData;

    updateFirestore();
  }

  // Method to clear all items from the cart
  String clearCart() {
    vendors.clear();
    updateFirestore();
    return 'Cart cleared successfully.';
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
        vendors: vendors!.map((vendorId, vendorData) {
          return MapEntry(
            vendorId,
            {
              'vendor_id': vendorId,
              'created_at': DateTime.now(),
              'deliver_at': DateTime.now().add(const Duration(days: 7)),
              'order_status_id': FirebaseFirestore.instance
                  .collection('order_status')
                  .doc('1'), // example order status ID
              'price': vendorData.values.fold(
                  0.0,
                  (sum, item) =>
                      sum +
                      (item['price'] as double) * (item['amount'] as int)),
              'vendor_id_items': vendorData.map((itemCode, itemData) {
                return MapEntry(
                  itemCode,
                  {
                    'amount': itemData['amount'],
                    'item_code': itemData['item_code'],
                    'item_name': itemData['item_name'],
                  },
                );
              }),
            },
          );
        }),
        totalPrice: totalPrice,
        totalItems: totalItems,
      );

      // Upload orders to Firebase
      await orders.uploadToFirebase();
      for (String vendorId in vendors.keys) {
        String vendorEmail = await getVendorEmail(vendorId);
        if (vendorEmail != null) {
          await sendEmail(vendorEmail);
        }
      }
      // Clear cart after moving records to orders
      clearCart();
    } catch (error) {
      print('Error moving records to orders: $error');
    }
  }

// Fetch vendor email from Firestore
  Future<String> getVendorEmail(String vendorId) async {
    try {
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('vendor')
          .doc(vendorId)
          .get();
      if (vendorSnapshot.exists) {
        return vendorSnapshot['email'];
      } else {
        print('Vendor with ID $vendorId not found.');
        return '';
      }
    } catch (error) {
      print('Error fetching vendor email: $error');
      return '';
    }
  }

  Future<void> sendEmail(String email) async {
    EmailSender emailsender = EmailSender();
    var response = await emailsender.sendMessage(
        "fatimaazaizeh@gmail.com", "title", "subject", "body");

    if (response["message"] == "emailSendSuccess") {
      print('SUCCESS! Email sent to $email');
    } else {
      print('ERROR! Failed to send email to $email: ${response["error"]}');
    }
  }
}
