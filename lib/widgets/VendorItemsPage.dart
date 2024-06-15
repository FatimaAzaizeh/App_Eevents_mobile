import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/Design/item_design.dart';
import 'package:testtapp/models/Cart.dart'; // Import the Cart class
import 'package:testtapp/widgets/AppBarEevents.dart';
import 'package:url_launcher/url_launcher.dart';

String Vendor_id = '';
String vendorUrl = '';
String VendorName = '';
Cart cartItem = Cart(userId: FirebaseAuth.instance.currentUser!.uid);

class VendorItemsPage extends StatefulWidget {
  final DocumentReference vendorId;
  final DocumentReference? EventId;
  VendorItemsPage({required this.vendorId, this.EventId});

  @override
  _VendorItemsPageState createState() => _VendorItemsPageState();
}

class _VendorItemsPageState extends State<VendorItemsPage> {
  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
    checkVendorStatus();
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
        VendorName = vendorDoc['business_name'];
        setState(() {});
      } else {
        print('Document does not exist');
      }
    }
  }

  Future<bool> isVendorActive(String vendorId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(vendorId)
        .get();
    if (userSnapshot.exists) {
      bool isActive = userSnapshot.get('active');
      return isActive;
    }
    return false; // Assuming inactive if not found
  }

  void checkVendorStatus() async {
    bool isActive = await isVendorActive(Vendor_id);
    if (!isActive) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('المحل غير متاح'),
            content: Text('المحل مشغول للاحظات.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('حسنا'),
              ),
            ],
          );
        },
      );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  VendorName,
                  style: TextStyle(fontSize: 28),
                ),
                FloatingActionButton(
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
                  child: Tooltip(
                    message: 'View Vendor Location',
                    child: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('item')
                    .where('vendor_id', isEqualTo: widget.vendorId)
                    .where('event_type_id', isEqualTo: widget.EventId)
                    .where('item_status_id',
                     isEqualTo: FirebaseFirestore.instance
                     .collection('item_status')
                     .doc('1')
                    )
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
                        vendorId: Vendor_id,
                        itemId: item['item_code'],
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

  final String vendorId;
  final String itemId;

  ServiceCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.vendorId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              itemCode: itemId,
              vendorId: Vendor_id,
              cartItem: cartItem,
            ),
          ),
        );
      },
      child: Card(
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
                          'د.ا $price',
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
                              Future<bool> isVendorActive(String vendorId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(vendorId)
        .get();
    if (userSnapshot.exists) {
      bool isActive = userSnapshot.get('active');
      return isActive;
    }
    return false; // Assuming inactive if not found
  }

  void checkVendorStatus() async {
    bool isActive = await isVendorActive(Vendor_id);
    if (!isActive) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('المحل غير متاح'),
            content: Text('المحل مشغول للاحظات.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('حسنا'),
              ),
            ],
          );
        },
      );
    }
  }

                              cartItem.addItem(
                                vendorId,
                                itemId,
                                title,
                                imageUrl,
                                price,
                                1,
                              );
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
      ),
    );
  }
}
