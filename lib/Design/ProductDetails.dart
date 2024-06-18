// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Cart.dart'; // Import your Cart model
import 'package:testtapp/widgets/AppBarEevents.dart';
import 'package:testtapp/screens/VendorItemsPage.dart';
import 'package:testtapp/widgets/app_drawer.dart';

Cart cartItem = Cart(userId: FirebaseAuth.instance.currentUser!.uid);

class ProductDetails extends StatefulWidget {
  final String itemCode;
  final DocumentReference vendorId;

  ProductDetails({
    Key? key,
    required this.itemCode,
    required this.vendorId,
  }) : super(key: key);

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
          .where('vendor_id', isEqualTo: widget.vendorId)
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
        drawer: AppDrawer(
          onItemTapped: (int) {},
        ),
        appBar: AppBarEevents(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var data = itemData!.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBarEevents(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              style: StyleTextAdmin(
                20,
                Color(0xff1e2022),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${data['price']} د.أ',
              style: StyleTextAdmin(
                18,
                Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              data['description'],
              style: StyleTextAdmin(
                16,
                Color(0xff77838f),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Ensure the user is logged in before adding to cart
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "يرجى تسجيل الدخول لإضافة المنتج إلى عربة التسوق."),
                        ),
                      );
                      return;
                    }

                    // Add item to cart
                    cartItem.addItem(
                      widget.vendorId.id,
                      data['item_code'].toString(),
                      data['name'].toString(),
                      data['image_url'].toString(),
                      double.parse(data['price'].toString()),
                      1,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: ColorPink_100,
                        content: Text("تمت إضافة المنتج إلى عربة التسوق.",
                            style: StyleTextAdmin(16, Colors.white)),
                      ),
                    );
                  },
                  child: Text(
                    "أضف إلى عربة التسوق",
                    style: StyleTextAdmin(
                      14,
                      Colors.white,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(ColorPink_100),
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
