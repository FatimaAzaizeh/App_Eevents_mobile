import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/screens/Service.dart';
import 'package:testtapp/widgets/Service_item.dart';

class Service extends StatefulWidget {
  static const String screenRoute = 'Service_screen';
  const Service({super.key});

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  @override
  Widget build(BuildContext context) {
    {
      return SafeArea(
        child: Material(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('service_types')
                .orderBy('id')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final eventDocs = snapshot.data!.docs;
                return GridView.builder(
                  padding: EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        191, // Adjust according to your requirement
                    childAspectRatio: 1, // Ensure each item is square
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: eventDocs.length,
                  itemBuilder: (context, index) {
                    final doc = eventDocs[index];
                    return ServiceItem(
                      imageUrl: doc['image_url'].toString(),
                      id: doc.id,
                      onTapFunction: () {
                        DocumentReference ServiceId = FirebaseFirestore.instance
                            .collection('service_types')
                            .doc(doc.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DisplayService(idService: ServiceId),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      );
    }
  }
}
