import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Cart.dart';
import 'package:testtapp/screens/Home_screen.dart';
import 'package:testtapp/widgets/AppBarEevents.dart';

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
            return Center(
                child: Text(
              "لا يوجد مزودي خدمات لهذه الخدمة",
              style: StyleTextAdmin(16, Colors.black),
            ));
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
    );
  }
}
