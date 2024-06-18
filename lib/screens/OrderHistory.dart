import 'dart:ui'; // Import dart:ui for MediaQuery

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Orders.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/screens/VendorItemsPage.dart';
import 'package:testtapp/widgets/AppBarEevents.dart';

class OrderHistoryPage extends StatefulWidget {
  static const String screenRoute = 'OrderHistory';

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Stream<User?> _userStream;

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
                vendors: (data['vendors'] as Map<String, dynamic>).map(
                  (key, value) {
                    return MapEntry(
                      key,
                      value as Map<String, dynamic>,
                    );
                  },
                ),
                totalPrice: data['total_price'],
                totalItems: data['total_items'],
              );
            }).toList());
  }

  Future<String> _fetchItemImage(
      String itemCode, DocumentReference vendorId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('item')
        .where('item_code', isEqualTo: itemCode)
        .where('vendor_id', isEqualTo: vendorId)
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
    // Fetch screen size
    var screenSize = MediaQuery.of(context).size;

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
                return Center(
                  child: Text(
                    "لا توجد طلبات موجودة",
                    style: StyleTextAdmin(16, Colors.black),
                  ),
                );
              }
              final orders = ordersSnapshot.data!;
              return SingleChildScrollView(
                padding: EdgeInsets.all(screenSize.width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: orders.map((order) {
                    return Card(
                      surfaceTintColor: Colors.white,
                      color: Color.fromARGB(255, 255, 229, 231),
                      margin: EdgeInsets.symmetric(
                          vertical: screenSize.width * 0.03),
                      child: Padding(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'رقم الطلب: ${order.orderId}',
                              style: StyleTextAdmin(
                                  screenSize.width * 0.035, Colors.black),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            Text(
                              'السعر الإجمالي : ${order.totalPrice.toStringAsFixed(2)} د,إ',
                              style: StyleTextAdmin(
                                  screenSize.width * 0.03, Colors.green),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            Text(
                              'عدد العناصر الإجمالي: ${order.totalItems}',
                              style: StyleTextAdmin(
                                  screenSize.width * 0.03, AdminButton),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            ...order.vendors.entries.map((vendorEntry) {
                              final vendorId = vendorEntry.key;
                              return FutureBuilder<String>(
                                future:
                                    UserDataBase.fetchBusinessName(vendorId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final businessName = snapshot.data ?? '';
                                  final vendorData = vendorEntry.value;
                                  final orderStatusId =
                                      vendorData['order_status_id']
                                          as DocumentReference;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'البائع: $businessName',
                                        style: StyleTextAdmin(
                                            screenSize.width * 0.03,
                                            AdminButton),
                                      ),
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: orderStatusId.snapshots(),
                                        builder: (context, statusSnapshot) {
                                          if (statusSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }
                                          final orderStatusData = statusSnapshot
                                              .data
                                              ?.get('description');
                                          final orderStatus =
                                              orderStatusData.toString();
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: Container(
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  'حالة الطلب: $orderStatus',
                                                  style: StyleTextAdmin(
                                                      screenSize.width * 0.035,
                                                      getColorForOrderStatus(
                                                          orderStatus)),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ...vendorData['vendor_id_items']
                                          .entries
                                          .map((itemEntry) {
                                        final itemData = itemEntry.value;
                                        final itemCode = itemData['item_code'];
                                        return FutureBuilder<String>(
                                          future: _fetchItemImage(
                                              itemCode,
                                              FirebaseFirestore.instance
                                                  .collection("vendor")
                                                  .doc(vendorId)),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            final itemImage =
                                                snapshot.data ?? '';
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      screenSize.height * 0.01),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        screenSize.width * 0.2,
                                                    height:
                                                        screenSize.width * 0.2,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                    ),
                                                    child: itemImage.isNotEmpty
                                                        ? Image.network(
                                                            itemImage,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Center(
                                                                child: Text(
                                                                  'الصورة\nغير موجودة',
                                                                  style: StyleTextAdmin(
                                                                      screenSize
                                                                              .width *
                                                                          0.02,
                                                                      AdminButton),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Center(
                                                            child: Text(
                                                              "لا توجد صورة",
                                                              style: StyleTextAdmin(
                                                                  screenSize
                                                                          .width *
                                                                      0.02,
                                                                  AdminButton),
                                                            ),
                                                          ),
                                                  ),
                                                  SizedBox(
                                                      width: screenSize.width *
                                                          0.04),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          itemData['item_name'],
                                                          style: StyleTextAdmin(
                                                              screenSize.width *
                                                                  0.035,
                                                              Colors.black),
                                                        ),
                                                        SizedBox(
                                                            height: screenSize
                                                                    .height *
                                                                0.01),
                                                        Text(
                                                          'الكمية: ${itemData['amount']}',
                                                          style: StyleTextAdmin(
                                                              screenSize.width *
                                                                  0.03,
                                                              Colors.black),
                                                        ),
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
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
