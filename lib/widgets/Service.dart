import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/widgets/Item_vendore.dart';

class service extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final String description;

  const service({
    Key? key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        DocumentReference VendorId =
            FirebaseFirestore.instance.collection('vendor').doc(id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorItemsPage(
              vendorId: VendorId,
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
        child: Column(children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 250,
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
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today,
                      color: Theme.of(context).hintColor,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(' أيام')
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          color: Theme.of(context).hintColor,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text('hiii')
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.family_restroom,
                          color: Theme.of(context).hintColor,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text('hiii')
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
