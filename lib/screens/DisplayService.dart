import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Home_screen.dart';
import 'package:testtapp/screens/cart_screen.dart';
import 'package:testtapp/widgets/Service.dart';

class DisplayService extends StatelessWidget {
  static const screenRouter = 'DisplayService';
  final DocumentReference idService;
  final DocumentReference? Eventid;

  const DisplayService({Key? key, required this.idService, this.Eventid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vendor')
            .where('service_types_id', isEqualTo: idService)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }
          return ListView.builder(
            itemBuilder: (ctx, index) {
              var doc = snapshot.data!.docs[index];
              return GestureDetector(
                onTap: () {},
                child: Service(
                  title: doc['business_name'],
                  imageUrl: doc['logo_url'],
                  id: doc.id,
                  description: doc['bio'],
                  Idevent: Eventid,
                ),
              );
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: ColorPink_20,
        color: Colors.white,
        animationDuration: Duration(milliseconds: 300),
        items: <Widget>[
          Icon(
            Icons.dashboard,
            color: ColorPink_100,
          ),
          Icon(
            Icons.home,
            color: ColorPink_100,
          ),
          Icon(
            Icons.shopping_cart,
            color: ColorPink_100,
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation tap
          if (index != 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  if (index == 0) {
                    return HomeScreen(); // Navigate to HomeScreen
                  } else {
                    return cartScreen(); // Navigate to ShoppingCartPage
                  }
                },
              ),
            );
          }
        },
        index: 1, // Set the default selected index
      ),
    );
  }
}
