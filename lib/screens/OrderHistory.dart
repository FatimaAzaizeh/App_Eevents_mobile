import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/models/Orders.dart';

class OrderHistoryPage extends StatelessWidget {
  static const String screenRoute = 'OrderHistory';

  Future<List<Orders>> _fetchOrders(String userId) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Orders(
        orderId: data['order_id'],
        userId: data['user_id'],
        vendors: (data['vendors'] as Map<String, dynamic>).map((key, value) {
          return MapEntry(
            key,
            value as Map<String, dynamic>,
          );
        }),
        totalPrice: data['total_price'],
        totalItems: data['total_items'],
      );
    }).toList();
  }

  Future<String> _fetchItemImage(String itemCode) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('item')
        .where('item_code', isEqualTo: itemCode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming you are interested in the first matched document
      DocumentSnapshot itemSnapshot = querySnapshot.docs.first;
      final itemData = itemSnapshot.data() as Map<String, dynamic>?;
      return itemData?['image_url'] ?? '';
    } else {
      // Handle the case where no documents matched the query
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('User not logged in'));
          }
          final userId = snapshot.data!.uid;
          return FutureBuilder<List<Orders>>(
            future: _fetchOrders(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No orders found'));
              }
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${order.orderId}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                              'Total Price: د.ك ${order.totalPrice.toStringAsFixed(2)}'),
                          SizedBox(height: 8),
                          Text('Total Items: ${order.totalItems}'),
                          SizedBox(height: 8),
                          ...order.vendors.entries.map((vendorEntry) {
                            final vendorId = vendorEntry.key;
                            final vendorData = vendorEntry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vendor: $vendorId'),
                                ...vendorData['vendor_id_items']
                                    .entries
                                    .map((itemEntry) {
                                  final itemData = itemEntry.value;
                                  final itemCode = itemData['item_code'];
                                  return FutureBuilder<String>(
                                    future: _fetchItemImage(itemCode),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      final itemImage = snapshot.data ?? '';
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: itemImage.isNotEmpty
                                                  ? Image.network(
                                                      itemImage,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Center(
                                                          child: Text(
                                                            'Image\nnot found',
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: Text('No Image')),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    itemData['item_name'],
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                      'Quantity: ${itemData['amount']}'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
