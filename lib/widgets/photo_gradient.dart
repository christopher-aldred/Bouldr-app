// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PhotoGradient extends StatelessWidget {
  final String name;
  final String description;
  final String imagePath;
  const PhotoGradient(this.name, this.description, this.imagePath, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4,
      child: Stack(
        children: <Widget>[
          Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.95)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.1, 0.2, 1],
                ),
              ),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minWidth: MediaQuery.of(context).size.width,
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image(
                      image: AssetImage('assets/images/missing.png'),
                      fit: BoxFit.cover),
                ),
              )),
          Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(name,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  Visibility(
                    child: Text(description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        )),
                    visible: description.toString() != "null",
                  )
                ],
              )),
        ],
      ),
    );
  }
}

/*

Text(text,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ))

*/