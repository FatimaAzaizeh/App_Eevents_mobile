import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/models/Cart.dart'; // Import the Cart class
import 'package:url_launcher/url_launcher.dart';

String Vendor_id = '';
String vendorUrl = '';
Cart cartItem = Cart(userId: FirebaseAuth.instance.currentUser!.uid);

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
    getDataFromFirestore();
  }

  void getDataFromFirestore() async {
    DocumentSnapshot documentSnapshot = await widget.vendorId.get();
    if (documentSnapshot.exists) {
      Vendor_id = documentSnapshot.get('UID');
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendor')
          .doc(Vendor_id)
          .get();

      if (vendorDoc.exists) {
        vendorUrl =
            vendorDoc['location_url']; // Assuming 'url' is the field name
        setState(() {});
      } else {
        print('Document does not exist');
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch $url';
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
              cartItem.uploadToFirebase().then((result) {
                print(result);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Call the method to delete all items from the cart
              cartItem.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All items deleted from cart.'),
                ),
              );
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
            ElevatedButton(
              onPressed: () {
                if (vendorUrl.isNotEmpty) {
                  _launchURL(vendorUrl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Vendor URL not available.'),
                    ),
                  );
                }
              },
              child: Text('Fetch Vendor URL Location'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('item')
                    .where('vendor_id', isEqualTo: widget.vendorId)
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
                        addToCart: cartItem.addItemByVendorId,
                        vendorId: Vendor_id,
                        itemId: item.id,
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
  final Function(String, String, String, String, double, int) addToCart;
  final String vendorId;
  final String itemId;

  ServiceCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.addToCart,
    required this.vendorId,
    required this.itemId,
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
                            addToCart(
                              vendorId,
                              itemId,
                              title,
                              imageUrl,
                              price,
                              1,
                            );
                            cartItem.editItemAmount(vendorId, itemId);
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
