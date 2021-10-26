// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/section.dart';
import 'package:bouldr/pages/add_route_1.dart';
import 'package:bouldr/widgets/route_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SectionWidget extends StatefulWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  const SectionWidget(this.venueId, this.areaId, this.sectionId, {Key? key})
      : super(key: key);

  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget>
    with AutomaticKeepAliveClientMixin {
  Section section = Section('Loading...', '');

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .collection('sections')
        .doc(widget.sectionId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.exists) {
        setState(() {
          section = Section.fromSnapshot(querySnapshot);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Column(children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Container(
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.03, 0.97, 1],
              ),
            ),
            child: InteractiveViewer(
              panEnabled: false, // Set it to false
              minScale: 1,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: section.imagePath,
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
            ),
          ),
        ),
        Expanded(
            child: RouteList(widget.venueId, widget.areaId, widget.sectionId))
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddRoute1(
                      widget.venueId, widget.areaId, section.referenceId!)))
        },
        label: Text('Add route'),
        icon: Icon(Icons.add),
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
