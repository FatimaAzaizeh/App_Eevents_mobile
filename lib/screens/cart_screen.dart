import 'package:flutter/material.dart';
import 'package:testtapp/screens/checkout_screen.dart';

class CartItem {
  final String imageUrl;
  final String itemName;
  final double price;
  int quantity;

  CartItem({
    required this.imageUrl,
    required this.itemName,
    required this.price,
    required this.quantity,
  });
}

class cartScreen extends StatefulWidget {
  static const String screenRoute = 'cart_screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<cartScreen> {
  
  List<CartItem> _cartItems = [
    CartItem(
      imageUrl: 'assets/images/img_user1.png',
      itemName: 'العنصر 1',
      price: 10.0,
      quantity: 2,
    ),
    CartItem(
      imageUrl: 'assets/images/img_user2.png',
      itemName: 'العنصر 2',
      price: 15.0,
      quantity: 1,
    ),
    // Add more cart items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cartItems.isEmpty
          ? Center(
              child: Text(
                'لا يوجد عناصر في السلة',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = _cartItems[index];
                return ListTile(
                  leading: Image.asset(
                    cartItem.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  title: Text(cartItem.itemName),
                  subtitle: Text('\$${cartItem.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (cartItem.quantity > 1) {
                              cartItem.quantity--;
                            }
                          });
                        },
                      ),
                      Text('${cartItem.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            cartItem.quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('عدد العناصر: ${_cartItems.length}'),
              ElevatedButton(
                onPressed: _cartItems.isEmpty
                    ? null
                    : () {
                        // Navigate to checkout screen if cart is not empty
                        Navigator.pushNamed(
                            context, checkoutscreen.screenRoute);
                      },
                child: Text('الدفع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
