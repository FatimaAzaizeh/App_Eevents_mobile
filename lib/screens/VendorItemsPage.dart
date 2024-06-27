import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/Design/ProductDetails.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/User.dart';
import 'package:url_launcher/url_launcher.dart';

String Vendor_id = '';
String vendorUrl = '';
String VendorName = '';

bool is_active = false; // Initialize is_active as false initially

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
  }

  Future<void> getDataFromFirestore() async {
    // Fetch vendor details and set state
    DocumentSnapshot documentSnapshot = await widget.vendorId.get();
    if (documentSnapshot.exists) {
      Vendor_id = documentSnapshot.get('UID');
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
          .collection('vendor')
          .doc(Vendor_id)
          .get();

      if (vendorDoc.exists) {
        vendorUrl = vendorDoc['location_url'];
        VendorName = vendorDoc['business_name'];
        is_active = await UserDataBase.isVendorActive(
            Vendor_id); // Assuming 'is_active' field exists in vendorDoc
        setState(() {});
      } else {
        print('Vendor document does not exist');
      }
    } else {
      print('Document does not exist');
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    VendorName,
                    style: StyleTextAdmin(
                        MediaQuery.sizeOf(context).width * 0.06, Colors.black),
                  ),
                  FloatingActionButton(
                    backgroundColor: ColorPink_100,
                    onPressed: () {
                      if (vendorUrl.isNotEmpty) {
                        _launchURL(vendorUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.white,
                            content: Text(
                              'الرابط الخاص بالبائع غير متوفر.',
                              style: StyleTextAdmin(16, ColorPink_100),
                            ),
                          ),
                        );
                      }
                    },
                    child: Tooltip(
                      textStyle: StyleTextAdmin(14, ColorPink_100),
                      decoration: BoxDecoration(color: Colors.white),
                      message: "عرض موقع البائع",
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
                            .doc('1'))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "حدث خطأ ما.",
                      style: StyleTextAdmin(16, Colors.red),
                    ));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.requireData;

                  if (data.size == 0) {
                    return Center(
                        child: Text(
                      "لا توجد عناصر متاحة لهذا البائع.",
                      style: StyleTextAdmin(16, Colors.black),
                    ));
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
                        vendorId: widget.vendorId,
                        itemId: item['item_code'],
                      );
                    },
                  );
                },
              ),
            ),
            // Render FloatingActionButton based on is_active status
            if (!is_active)
              Container(
                width: MediaQuery.sizeOf(context).width * 0.45,
                margin: EdgeInsets.only(bottom: 90),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(165, 255, 255, 255)
                          .withOpacity(0.3),
                      width: 2),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.withOpacity(0.7),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "المحل غير متاح حاليا",
                    style: StyleTextAdmin(18, Colors.white),
                  ),
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

  final DocumentReference vendorId;
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
              vendorId: vendorId,
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
                          style: StyleTextAdmin(16, Colors.black),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'د.ا $price',
                          style: StyleTextAdmin(
                            16,
                            Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: is_active
                              ? () {
                                  cartItem.addItem(
                                    Vendor_id,
                                    itemId,
                                    title,
                                    imageUrl,
                                    price,
                                    1,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: ColorPink_100,
                                      content: Text(
                                          'تمت إضافة المنتج إلى عربة التسوق.',
                                          style:
                                              StyleTextAdmin(16, Colors.white)),
                                    ),
                                  );
                                }
                              : null,
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
