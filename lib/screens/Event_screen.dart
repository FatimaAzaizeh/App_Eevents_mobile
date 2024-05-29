import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/widgets/EventItemDisplay.dart';
import 'package:testtapp/wizard/WizardSteps.dart';

class EventScreen extends StatefulWidget {
  static const String screenRoute = 'Event_screen';

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('event_types').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final eventDocs = snapshot.data?.docs ?? [];
              return GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 7 / 8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: eventDocs.length,
                itemBuilder: (context, index) {
                  final doc = eventDocs[index];
                  return EventItemDisplay(
                    title: doc['name'].toString(),
                    imageUrl: doc['image_url'].toString(),
                    id: doc.id,
                    onTapFunction: () {
                      // Implement the desired onTap functionality here
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
