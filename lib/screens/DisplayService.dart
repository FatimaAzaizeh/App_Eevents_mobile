import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            .where('vendor_status_id',
                isEqualTo: FirebaseFirestore.instance
                    .collection("vendor_status")
                    .doc('2'))
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
                child: service(
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
