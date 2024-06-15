import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Orders.dart';
import 'package:testtapp/widgets/AppBarEevents.dart';

class OrderHistoryPage extends StatefulWidget {
  static const String screenRoute = 'OrderHistory';

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Stream<User?> _userStream;
  int _selectedIndex = 1; // Initially selected index for the home icon

  // Global keys for tutorial
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _cartKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _userStream = FirebaseAuth.instance.authStateChanges();
  }

  Stream<List<Orders>> _fetchOrders(String userId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Orders(
                orderId: data['order_id'],
                userId: data['user_id'],
                vendors:
                    (data['vendors'] as Map<String, dynamic>).map((key, value) {
                  return MapEntry(
                    key,
                    value as Map<String, dynamic>,
                  );
                }),
                totalPrice: data['total_price'],
                totalItems: data['total_items'],
              );
            }).toList());
  }

  Future<String> _fetchItemImage(String itemCode) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('item')
        .where('item_code', isEqualTo: itemCode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot itemSnapshot = querySnapshot.docs.first;
      final itemData = itemSnapshot.data() as Map<String, dynamic>?;
      return itemData?['image_url'] ?? '';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBarEevents(),
      
      body: StreamBuilder<User?>(
        stream: _userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return Center(child: Text('User not logged in'));
          }
          final userId = userSnapshot.data!.uid;
          return StreamBuilder<List<Orders>>(
            stream: _fetchOrders(userId),
            builder: (context, ordersSnapshot) {
              if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!ordersSnapshot.hasData || ordersSnapshot.data!.isEmpty) {
                return Center(child: Text('No orders found'));
              }
              final orders = ordersSnapshot.data!;
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total Price: د.ك ${order.totalPrice.toStringAsFixed(2)}',
                          ),
                          SizedBox(height: 8),
                          Text('Total Items: ${order.totalItems}'),
                          SizedBox(height: 8),
                          ...order.vendors.entries.map((vendorEntry) {
                            final vendorId = vendorEntry.key;
                            final vendorData = vendorEntry.value;
                            final orderStatusId = vendorData['order_status_id']
                                as DocumentReference;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vendor: $vendorId'),
                                StreamBuilder<DocumentSnapshot>(
                                  stream: orderStatusId.snapshots(),
                                  builder: (context, statusSnapshot) {
                                    if (statusSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    final orderStatusData =
                                        statusSnapshot.data?.get('description');
                                    final orderStatus =
                                        orderStatusData.toString();
                                    return Text('Order Status: $orderStatus');
                                  },
                                ),
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
                                                  color: Colors.grey,
                                                ),
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
                                                      child: Text('No Image'),
                                                    ),
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
                                                          FontWeight.bold,
                                                    ),
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
