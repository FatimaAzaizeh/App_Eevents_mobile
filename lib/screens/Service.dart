import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/widgets/Service.dart';
import 'package:testtapp/widgets/Service_item.dart';

class DisplayService extends StatelessWidget {
  static const screenRouter = 'Service';
  final DocumentReference idService;

  const DisplayService({Key? key, required this.idService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service'),
      ),
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
                onTap: () {
                  _removeService(context, doc.id);
                },
                child: service(
                  title: doc['business_name'],
                  imageUrl: doc['logo_url'],
                  id: doc.id,
                  description: doc['bio'],
                ),
              );
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
    );
  }

  void _removeService(BuildContext context, String serviceId) {
    // Implement your removal logic here, maybe show a confirmation dialog.
    // For now, we'll just print the id.
    print('Removing service with id: $serviceId');
  }
}
