import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/Design/ProductDetails.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Cart.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/screens/EditProfile.dart';
import 'package:testtapp/screens/Home_screen.dart';
import 'package:testtapp/screens/VendorItemsPage.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class ShoppingCartPage extends StatefulWidget {
  static const String screenRoute = 'Cart';

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  double totalOrderPrice = 0.0;
  int totalQuantity = 0;

  void updateTotals(Map<String, dynamic>? vendors) {
    double newTotalOrderPrice = 0.0;
    int newTotalQuantity = 0;

    if (vendors != null && vendors.isNotEmpty) {
      vendors.values.forEach((items) {
        items.forEach((_, itemData) {
          newTotalOrderPrice +=
              (itemData['price'] ?? 0.0) * (itemData['amount'] ?? 0);
          newTotalQuantity += (itemData['amount'] ?? 0) as int;
        });
      });
    }

    if (newTotalOrderPrice != totalOrderPrice ||
        newTotalQuantity != totalQuantity) {
      setState(() {
        totalOrderPrice = newTotalOrderPrice;
        totalQuantity = newTotalQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
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
                  final userId = snapshot.data!.uid;
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("cart")
                        .doc(userId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        updateTotals(
                            null); // إعادة تعيين الإجماليات إذا لم توجد بيانات
                        return Center(
                          child: Text(
                            'لا توجد عناصر في السلة',
                            style: StyleTextAdmin(
                              screenSize.width * 0.04,
                              Colors.black,
                            ),
                          ),
                        );
                      }

                      final Map<String, dynamic>? cartData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      if (cartData == null || cartData.isEmpty) {
                        updateTotals(
                            null); // إعادة تعيين الإجماليات إذا كانت السلة فارغة
                        return Center(
                          child: Text(
                            'لا توجد عناصر في السلة',
                            style: StyleTextAdmin(
                              screenSize.width * 0.04,
                              Colors.black,
                            ),
                          ),
                        );
                      }

                      final Map<String, dynamic>? vendors = cartData['vendors'];
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        updateTotals(vendors);
                      });

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: vendors!.length,
                        itemBuilder: (context, index) {
                          final String vendorId = vendors.keys.elementAt(index);
                          final items =
                              vendors[vendorId] as Map<String, dynamic>;
                          return VendorContainer(
                            vendorId: vendorId,
                            items: items,
                            userId: userId,
                            onItemChanged: () {
                              FirebaseFirestore.instance
                                  .collection('cart')
                                  .doc(userId)
                                  .get()
                                  .then((doc) {
                                final vendors = doc.data()?['vendors'] ?? {};
                                updateTotals(vendors);
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(screenSize.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'المجموع الكلي:  د.ا$totalOrderPrice',
                    style:
                        StyleTextAdmin(screenSize.width * 0.04, Colors.black),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    'كمية الطلب: $totalQuantity',
                    style:
                        StyleTextAdmin(screenSize.width * 0.04, Colors.black),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  ElevatedButton(
                    onPressed: () async {
                      // Check if the total quantity is zero to determine if the cart is empty
                      if (totalQuantity == 0) {
                        ErrorAlert(
                          context,
                          'طلب فارغ',
                          'لا يوجد طلبات للإرسال',
                        );
                      } else {
                        bool userDataExists =
                            await UserDataBase.checkUserDataExists(
                                auth.currentUser!.uid);
                        if (userDataExists) {
                          cartItem.moveToOrders(totalOrderPrice, totalQuantity);
                          setState(() {
                            totalOrderPrice = 0;
                            totalQuantity = 0;
                          });
                          cartItem.clearCart();
                          SuccessAlert(
                            context,
                            'تم ارسال طلبك بنجاح',
                          );
                        } else {
                          ErrorAlert(
                            context,
                            "معلومات ناقصة",
                            "يرجى ملء جميع الحقول للمتابعة.",
                          );
                          await Future.delayed(
                              Duration(seconds: 2)); // Wait for 2 seconds
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditUserPage(),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'اتمام الطلب',
                      style: StyleTextAdmin(16, Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPink_100,
                      minimumSize:
                          Size(double.infinity, screenSize.height * 0.06),
                    ),
                  ),
                ],
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
  final String userId;
  final VoidCallback onItemChanged;

  VendorContainer({
    required this.vendorId,
    required this.items,
    required this.userId,
    required this.onItemChanged,
  });

  Future<double> calculateTotalPrice() async {
    double totalPrice = 0.0;
    await Future.forEach(items.values, (itemData) {
      totalPrice += itemData['price'] * itemData['amount'];
    });
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder<double>(
      future: calculateTotalPrice(),
      builder: (context, snapshot) {
        double totalPrice = snapshot.data ?? 0.0;

        // Calculate card width as 80% of screen width
        double cardWidth = screenSize.width * 0.8;

        return Card(
          surfaceTintColor: Colors.white,
          color: Color.fromARGB(255, 255, 229, 231),
          margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
          child: Container(
            width: cardWidth,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: UserDataBase.fetchBusinessName(vendorId),
                    builder: (context, snapshot) {
                      String businessName = snapshot.data ?? '';

                      return Text(
                        'البائع: $businessName',
                        style: StyleTextAdmin(
                            screenSize.width * 0.0352, AdminButton),
                      );
                    },
                  ),
                  Column(
                    children: items.entries.map((entry) {
                      final itemData = entry.value as Map<String, dynamic>;
                      return CartItem(
                        userId: userId,
                        vendorId: vendorId,
                        itemCode: entry.key,
                        title: itemData['item_name'],
                        quantity: itemData['amount'],
                        price: itemData['price'],
                        imageUrl: itemData['item_image'],
                        onItemChanged: onItemChanged,
                      );
                    }).toList(),
                  ),
                  Text(
                    'السعر الإجمالي : ${totalPrice.toStringAsFixed(2)} د,إ',
                    style:
                        StyleTextAdmin(screenSize.width * 0.03, Colors.black),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CartItem extends StatefulWidget {
  final String userId;
  final String vendorId;
  final String itemCode;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;
  final VoidCallback onItemChanged;

  CartItem({
    required this.userId,
    required this.vendorId,
    required this.itemCode,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.onItemChanged,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  int quantity;

  _CartItemState() : quantity = 0;

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.network(
            widget.imageUrl,
            width: screenSize.width * 0.15,
            height: screenSize.height * 0.15,
          ),
          title: Text(
            widget.title,
            style: StyleTextAdmin(screenSize.width * 0.035, Colors.black),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.remove, size: screenSize.width * 0.06),
                    onPressed: () {
                      setState(() {
                        cartItem.editItemAmountSub(
                            widget.vendorId, widget.itemCode);
                        widget.onItemChanged();
                      });
                    },
                  ),
                  Text(
                    ' $quantity',
                    style: StyleTextAdmin(screenSize.width * 0.03, AdminButton),
                  ),
                  IconButton(
                    icon: Icon(
                      color: Colors.black,
                      Icons.add,
                      size: screenSize.width * 0.06,
                    ),
                    onPressed: () {
                      setState(() {
                        cartItem.editItemAmount(
                            widget.vendorId, widget.itemCode);
                        widget.onItemChanged();
                      });
                    },
                  ),
                ],
              ),
              Text(
                'السعر: ${widget.price.toStringAsFixed(2)} د.إ',
                style: StyleTextAdmin(screenSize.width * 0.03, Colors.black),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                cartItem.deleteItem(widget.vendorId, widget.itemCode);
                widget.onItemChanged();
              });
            },
          ),
        ),
      ],
    );
  }
}
