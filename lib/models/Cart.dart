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

    // Check if the item exists in the cart
    if (vendors![vendorId]!.containsKey(itemCode)) {
      // Increment the amount by 1
      vendors![vendorId]![itemCode]!['amount'] += 1;
    } else {
      // Item does not exist in the cart, add it with initial amount
      vendors![vendorId]![itemCode] = {
        'amount': amount,
        'item_code': itemCode,
        'item_name': itemName,
        'item_image': itemImage,
        'price': price,
      };
    }

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

// دالة لحذف عنصر من السلة
  void deleteItem(String vendorId, String itemCode) {
    if (vendors != null &&
        vendors!.containsKey(vendorId) &&
        vendors![vendorId]!.containsKey(itemCode)) {
      vendors![vendorId]!.remove(itemCode); // حذف العنصر

      // تحقق إذا كان البائع لا يحتوي على أي عناصر بعد حذف العنصر
      if (vendors![vendorId]!.isEmpty) {
        vendors!
            .remove(vendorId); // حذف مفتاح البائع إذا كان فارغاً بعد حذف العنصر
      }

      updateFirestore(); // تحديث Firestore بعد التعديل
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

  // Method to edit the amount of an item in the cart
  void editItemAmountSub(String vendorId, String itemCode) {
    if (itemExists(vendorId, itemCode)) {
      int amount = vendors![vendorId]![itemCode]!['amount'];
      if (amount > 1) {
        vendors![vendorId]![itemCode]!['amount'] = amount - 1;
      } else {
        deleteItem(vendorId, itemCode);
      }
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

      // Clear cart after moving records to orders
      clearCart();
    } catch (error) {
      print('Error moving records to orders: $error');
    }
  }

  Map<String, dynamic> calculateTotalValues() {
    double totalOrderPrice = 0.0;
    int totalQuantity = 0;

    if (vendors != null) {
      vendors!.forEach((vendorId, vendorData) {
        vendorData.forEach((itemCode, itemData) {
          double price = itemData['price'] ?? 0.0;
          int amount = itemData['amount'] ?? 0;
          totalOrderPrice += price * amount;
          totalQuantity += amount;
        });
      });
    }

    return {
      'totalOrderPrice': totalOrderPrice,
      'totalQuantity': totalQuantity,
    };
  }

  // Method to calculate total price asynchronously
  Future<double> calculateTotalPrice() async {
    double totalPrice = 0.0;
    if (vendors != null) {
      vendors!.forEach((vendorId, vendorData) {
        vendorData.forEach((itemCode, itemData) {
          double price = itemData['price'] ?? 0.0;
          int amount = itemData['amount'] ?? 0;
          totalPrice += price * amount;
        });
      });
    }
    return totalPrice;
  }
}
