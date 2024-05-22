import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingCartPage extends StatefulWidget {
  static const String screenRoute = 'Cart';

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<User?>(
                future: FirebaseAuth.instance.authStateChanges().first,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text('User not logged in'));
                  }
                  final userId = snapshot.data?.uid ?? '';
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cart')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(child: Text('No items in the cart'));
                      }

                      final Map<String, dynamic>? cartData =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      if (cartData == null) {
                        return Center(child: Text('No items in the cart'));
                      }

                      final Map<String, dynamic>? vendors = cartData['vendors'];
                      if (vendors == null || vendors.isEmpty) {
                        return Center(child: Text('No items in the cart'));
                      }

                      return ListView.builder(
                        itemCount: vendors.length,
                        itemBuilder: (context, index) {
                          final vendorId = vendors.keys.elementAt(index);
                          final items =
                              vendors[vendorId] as Map<String, dynamic>;

                          return VendorContainer(
                            vendorId: vendorId,
                            items: items,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('حدد العنوان'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {},
              child: Text('متابعة التسوق'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorContainer extends StatelessWidget {
  final String vendorId;
  final Map<String, dynamic> items;

  VendorContainer({required this.vendorId, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor: $vendorId',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: items.entries.map((entry) {
                final itemData = entry.value as Map<String, dynamic>;
                return CartItem(
                  title: itemData['item_name'],
                  date: 'Description not available',
                  quantity: itemData['amount'],
                  price: itemData['price'],
                  deliveryFee: 0.0, // Delivery fee handled separately
                  imageUrl: itemData['item_image'],
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text(
              'رسوم التوصيل: د.ك 0.0', // Replace with actual delivery fee if available
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String title;
  final String date;
  final int quantity;
  final double price;
  final double deliveryFee;
  final String imageUrl;

  CartItem({
    required this.title,
    required this.date,
    required this.quantity,
    required this.price,
    required this.deliveryFee,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Image\nnot found',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  )
                : Center(child: Text('No Image')),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(date),
                SizedBox(height: 8),
                Text('كمية: $quantity'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'د.ك $price',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              // Remove the delivery fee from here
            ],
          ),
        ],
      ),
    );
  }
}
