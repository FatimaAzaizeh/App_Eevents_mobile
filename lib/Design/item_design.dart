import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Corrected import statement
import 'package:testtapp/models/Cart.dart';

Cart cartItem = Cart(userId: FirebaseAuth.instance.currentUser!.uid);

class ProductDetails extends StatefulWidget {
  final String itemCode;
  final String vendorId;
  bool firstime;

  ProductDetails(
      {required this.itemCode, required this.vendorId, required this.firstime});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  DocumentSnapshot? itemData;

  @override
  void initState() {
    super.initState();
    fetchItemData();
  }

  void fetchItemData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('item')
          .where('item_code', isEqualTo: widget.itemCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          itemData = querySnapshot.docs.first;
        });
      } else {
        print('No item found with the given item code');
      }
    } catch (e) {
      print('Error fetching item data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (itemData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Product Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var data = itemData!.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 360,
              color: Color(0xffffeff3),
              child: Image.network(data['image_url'], fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            Text(
              data['name'],
              style: TextStyle(
                color: Color(0xff1e2022),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${data['price']}',
              style: TextStyle(
                color: Color(0xff77838f),
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              data['description'],
              style: TextStyle(
                color: Color(0xff77838f),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    if (widget.firstime) {
                      cartItem.addItem(
                        widget.vendorId,
                        data['item_code'].toString(),
                        data['name'].toString(),
                        data['image_url'].toString(),
                        double.parse(data['price'].toString()),
                        1,
                      );
                      widget.firstime = false;
                    } else {
                      cartItem.editItemAmount(
                          widget.itemCode, data['item_code']);
                    }
                  },
                  child: Text(
                    'Add to Bag',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xffdd5d79)),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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
