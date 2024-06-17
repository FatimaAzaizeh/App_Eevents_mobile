import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/Design/item_design.dart';
import 'package:testtapp/constants.dart';
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
  get vendorId => null;

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
            title: Text(
              'المحل غير متاح',
              style: StyleTextAdmin(14, Colors.black),
            ),
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
  //MAIN PAGE

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
                  style: StyleTextAdmin(28, Colors.black),
                ),
                FloatingActionButton(
                  backgroundColor: ColorPink_50,
                  onPressed: () {
                    _showWorkingHoursAlertDialog(context, vendorId);
                  },
                  child: Tooltip(
                    decoration: BoxDecoration(color: Colors.white),
                    textStyle: StyleTextAdmin(12, ColorPurple_100),
                    message: "عرض ساعات عمل المتجر",
                    child: Icon(
                      Icons.access_time,
                      color: Colors.black,
                    ),
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: ColorPink_50,
                  onPressed: () {
                    if (vendorUrl.isNotEmpty) {
                      _launchURL(vendorUrl);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "رابط البائع غير متاح.",
                            style: StyleTextAdmin(12, AdminButton),
                          ),
                        ),
                      );
                    }
                  },
                  child: Tooltip(
                    decoration: BoxDecoration(color: Colors.white),
                    textStyle: StyleTextAdmin(12, ColorPurple_100),
                    message: "عرض موقع البائع",
                    child: Icon(
                      Icons.location_on,
                      color: Colors.black,
                    ),
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
                            .doc('1'))
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
                        child: Text(
                      "لم يتم العثور على أي عناصر لهذا البائع.",
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.add_shopping_cart),
                            onPressed: () {
                              Future<bool> isVendorActive(
                                  String vendorId) async {
                                DocumentSnapshot userSnapshot =
                                    await FirebaseFirestore.instance
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
                                        title: Text(
                                          'المحل غير متاح',
                                          style:
                                              StyleTextAdmin(14, AdminButton),
                                        ),
                                        content: Text(
                                          'المحل مشغول للاحظات.',
                                          style:
                                              StyleTextAdmin(14, AdminButton),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'حسنا',
                                              style: StyleTextAdmin(
                                                  15, Colors.black),
                                            ),
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

void _showWorkingHoursAlertDialog(BuildContext context, String vendorId) async {
  final _firestore = FirebaseFirestore.instance;
  Map<String, TimeOfDay?> openingHours = {};
  Map<String, TimeOfDay?> closingHours = {};

  try {
    // Fetch vendor document
    final doc = await _firestore.collection('vendor').doc(vendorId).get();

    if (doc.exists) {
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('working_hours')) {
        final Map<String, dynamic> workingHours = data['working_hours'];

        for (var day in workingHours.keys) {
          openingHours[day] = _convertTimestampToTimeOfDay(
              workingHours[day]['working_hour_from']);
          closingHours[day] = _convertTimestampToTimeOfDay(
              workingHours[day]['working_hour_to']);
        }

        // Display alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("ساعات عمل المتجر"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < 7; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '${_getDayOfWeek(i)}: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'من ${_formatTime(openingHours[_getDayOfWeek(i)])} إلى ${_formatTime(closingHours[_getDayOfWeek(i)])}',
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('موافق'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle case where 'working_hours' key is missing
        throw FormatException('Data format error');
      }
    } else {
      // Handle case where document does not exist
      throw StateError('Document not found');
    }
  } catch (e) {
    // Handle errors (e.g., Firestore errors, data format errors)
    print('Error fetching data: $e');
    // Optionally show an error dialog or snackbar here
  }
}

String _getDayOfWeek(int index) {
  switch (index) {
    case 0:
      return 'الأحد';
    case 1:
      return 'الإثنين';
    case 2:
      return 'الثلاثاء';
    case 3:
      return 'الإربعاء';
    case 4:
      return 'الخميس';
    case 5:
      return 'الجمعة';
    case 6:
      return 'السبت';
    default:
      return '';
  }
}

TimeOfDay? _convertTimestampToTimeOfDay(Timestamp? timestamp) {
  if (timestamp == null) return null;
  final dateTime = timestamp.toDate();
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

String _formatTime(TimeOfDay? time) {
  if (time == null) return '';
  final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$minute: $hour $period';
}
