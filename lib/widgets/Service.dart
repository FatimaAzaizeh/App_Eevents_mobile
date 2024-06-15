import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/widgets/VendorItemsPage.dart'; // Ensure the path is correct

class Service extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final DocumentReference? Idevent;

  const Service({
    Key? key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    this.Idevent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DocumentReference vendorId =
            FirebaseFirestore.instance.collection('vendor').doc(id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorItemsPage(
              vendorId: vendorId,
              EventId: Idevent,
            ),
          ),
        );
        print('hi');
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 7,
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 150,
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0),
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: [0.6, 1],
                    ),
                  ),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: Colors.white,
                        ),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                     Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
                
               
                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
