import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/models/Cart.dart'; // Import the Cart class

String Vendor_id = '';
Cart cartItem = Cart(userId: ''); // Initialize Cart instance

class VendorItemsPage extends StatefulWidget {
  final DocumentReference vendorId;

  VendorItemsPage({required this.vendorId});

  @override
  _VendorItemsPageState createState() => _VendorItemsPageState();
}

class _VendorItemsPageState extends State<VendorItemsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize Cart instance
    getDataFromFirestore(); // Fetch vendor ID
  }

  void getDataFromFirestore() async {
    // Get the document snapshot from Firestore
    DocumentSnapshot documentSnapshot = await widget.vendorId.get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Access the data inside the document directly
      Vendor_id = documentSnapshot.get('UID');
      setState(() {}); // Update the UI after getting the data
    } else {
      print('Document does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items from Vendor ${widget.vendorId.id}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Upload cart data to Firebase
              cartItem.uploadToFirebase().then((result) {
                print(result);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('item')
                    .where('vendor_id',
                        isEqualTo: widget.vendorId) // Use vendorId.id
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.requireData;

                  if (data.size == 0) {
                    return Center(
                        child: Text('No items found for this vendor.'));
                  }

                  return ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      var item = data.docs[index];

                      return ServiceCard(
                        title: item['description'],
                        price: (item['price'] is int)
                            ? item['price'].toDouble()
                            : item['price'],
                        imageUrl: item['image_url'],
                        addToCart: cartItem
                            .addItemByVendorId, // Use addItemByVendorId method
                        vendorId: Vendor_id, // Pass the vendor ID
                        itemId: item.id, // Pass the item id
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;
  final Function(String, String, String, String, double, int)
      addToCart; // Change function signature
  final String vendorId; // Vendor ID
  final String itemId; // Item ID

  ServiceCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.addToCart,
    required this.vendorId, // Receive the vendor id
    required this.itemId, // Receive the item id
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'د.ك $price',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            cartItem.addItem(
                              Vendor_id, // Vendor ID
                              itemId, // Pass item id
                              title, // Item name
                              imageUrl, // Item image
                              price, // Item price
                              1,
                            );
                            cartItem.editItemAmount(Vendor_id, itemId);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
