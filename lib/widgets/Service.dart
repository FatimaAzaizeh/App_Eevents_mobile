import 'package:flutter/material.dart';

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

  void selectService(BuildContext context) {
    /*Navigator.of(context)
        .pushNamed(ServiceDetailScreen.screenRoute, arguments: id)
        .then((result) {
      if (result != null) {}
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectService(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 7,
        margin: EdgeInsets.all(10),
        child: Column(
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
          ],
        ),
      ),
    );
  }
}
