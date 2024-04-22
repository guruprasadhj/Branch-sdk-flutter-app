import 'package:flutter/material.dart';
class CustomShoppingCard extends StatelessWidget {
  const CustomShoppingCard({super.key, required this.title, required this.description, required this.actualPrice, required this.discountedPrice, this.onTap, required this.imageURL});
  final String imageURL;
  final String title;
  final String description;
  final String actualPrice;
  final String discountedPrice;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top:10),
        constraints: BoxConstraints(
            minHeight: 120,
            minWidth: 480,
            maxHeight: 130,
            maxWidth: 500
        ),
        padding: EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width,
        height: 120,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                // offset: Offset(0, 10),
                blurRadius: 5.0,
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
                image: DecorationImage(
                    image: NetworkImage(
                        imageURL,
                    ),
                    fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  SizedBox(
                    width: 170,
                    child: Text(
                      description,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 10),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "\$$actualPrice",
                            style: TextStyle(
                                color: Colors.black38,
                                decoration: TextDecoration.lineThrough)),
                        TextSpan(
                            text: ' \$$discountedPrice',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right,size: 28,)
          ],
        ),
      ),
    );
  }
}
