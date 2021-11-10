// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/area.dart';
import 'package:bouldr/pages/add_section.dart';
import 'package:bouldr/widgets/section_page_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repository/data_repository.dart';

class AreaPage extends StatefulWidget {
  final String areaId;
  final String venueId;
  const AreaPage(this.venueId, this.areaId, {Key? key}) : super(key: key);

  @override
  _AreaPageState createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  Area area = Area("Loading...", LatLng(999, 999), 0);
  DataRepository dataRepository = DataRepository();

  void handleActions(String value) {
    switch (value) {
      case 'Add section':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddSection(widget.venueId, widget.areaId)));
        break;
      case 'Settings':
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.exists) {
        setState(() {
          area = Area.fromSnapshot(querySnapshot);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text(area.name),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (handleActions),
                itemBuilder: (BuildContext context) {
                  return {
                    'Add section',
                    'Delete section',
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
            backgroundColor: Colors.green,
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          body: SectionPageView(widget.venueId, widget.areaId)),
    );
  }
}
