import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/Design/framApp.dart';
import 'package:testtapp/wizard/WizardSteps.dart'; // Import WizardSteps correctly

class EventItemDisplay extends StatefulWidget {
  const EventItemDisplay({
    Key? key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.onTapFunction,
  }) : super(key: key);

  final String id;
  final String title;
  final String imageUrl;
  final Function onTapFunction;

  @override
  State<EventItemDisplay> createState() => _EventItemDisplayState();
}

class _EventItemDisplayState extends State<EventItemDisplay> {
  List<String> serviceNames = [];
  List<String> serviceImages = [];
  List<DocumentReference> serviceIds = []; // Store DocumentReferences
  bool isLoading = false;
  int activeStep = 0;
  double progress = 0.2;

  Future<void> fetchServiceData(String id) async {
    try {
      setState(() {
        isLoading = true;
      });

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('event_wizard')
          .doc(id)
          .get();

      if (!snapshot.exists) {
        throw Exception("Document does not exist");
      }

      Map<String, dynamic>? servicesData =
          snapshot.get('services') as Map<String, dynamic>?;

      if (servicesData != null) {
        serviceNames.clear();
        serviceImages.clear();
        serviceIds.clear();
        servicesData.forEach((key, service) {
          serviceNames.add(service['servicename'].toString());
          serviceImages.add(service['serviceimage'].toString());
          serviceIds.add(service['serviceId']);
        });
      } else {
        throw Exception("Services data is null or not in the expected format");
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error reading data: $e");
      // Handle error state or show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      onTap: () async {
        print('id is: ${widget.id}');
        await fetchServiceData(widget.id.toString());
        if (!isLoading && serviceNames.isNotEmpty && serviceImages.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WizardSteps(
                activeStep: activeStep,
                imagePaths: serviceImages,
                titles: serviceNames,
                pages: serviceIds,
                onStepTapped: (int value) {
                  // Add your onTap logic here if needed
                },
                id: widget.id,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        height: 200,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(0.4),
                      ),
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
