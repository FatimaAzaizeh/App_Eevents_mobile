import 'package:cloud_firestore/cloud_firestore.dart';

class Cart {
  String userId;
  Map<String, Map<String, dynamic>>? vendors;

  Cart({required this.userId, this.vendors});

  // Method to add an item to the cart
  void addItem(String vendorId, String itemCode, String itemName,
      String itemImage, double price, int amount) {
    // Initialize vendors if null
    vendors ??= {};

    // Initialize vendor items if not present
    vendors!.putIfAbsent(vendorId, () => {});

    // Add item to the vendor's items
    vendors![vendorId]!.putIfAbsent(
      itemCode,
      () => {
        'amount': amount,
        'item_code': itemCode,
        'item_name': itemName,
        'item_image': itemImage,
        'price': price,
      },
    );

    // Update Firestore document
    updateFirestore();
  }

  // Method to update Firestore document with cart data
  Future<void> updateFirestore() async {
    try {
      // Get reference to the Firestore collection 'cart' and document with userId
      CollectionReference cartCollection =
          FirebaseFirestore.instance.collection('cart');
      DocumentReference docRef = cartCollection.doc(userId);

      // Update the document with the updated vendors map
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
      // Update Firestore document
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
  void editItemAmount(
    String vendorId,
    String itemCode,
  ) {
    if (itemExists(vendorId, itemCode)) {
      int amount = vendors![vendorId]![itemCode]!['amount'];
      vendors![vendorId]![itemCode]!['amount'] = amount + 1;
      // Update Firestore document
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
        Map<String, dynamic> vendorsData = {};
        vendors!.forEach((key, value) {
          List<Map<String, dynamic>> vendorItems = [];
          value.forEach((itemKey, itemValue) {
            vendorItems.add({
              'amount': itemValue['amount'],
              'item_code': itemValue['item_code'],
              'item_name': itemValue['item_name'],
              'item_image': itemValue['item_image'],
              'price': itemValue['price'],
            });
          });
          vendorsData[key] = {
            'vendor_id': key,
            'vendor_items': vendorItems,
          };
        });

        await docRef.set({
          'user_id': userId,
          'vendors': vendorsData,
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
    vendors![vendorId]!.putIfAbsent(
        itemCode,
        () => {
              'amount': amount,
              'item_code': itemCode,
              'item_name': itemName,
              'item_image': itemImage,
              'price': price,
            });
  }
}
