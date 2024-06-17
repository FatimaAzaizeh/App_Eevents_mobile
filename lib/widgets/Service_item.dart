import 'package:flutter/material.dart';

class ServiceItem extends StatelessWidget {
  const ServiceItem({
    Key? key,
    required this.id,
    required this.imageUrl,
    required this.onTapFunction,
  }) : super(key: key);

  final String id;
  final String imageUrl;
  final Function onTapFunction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        // Handle onTap if needed
        onTapFunction();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        height: 180,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(0),
                      //alignment: Alignment.bottomLeft,
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
