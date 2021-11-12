// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/pages/venue_map.dart';
import 'package:bouldr/widgets/area_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repository/data_repository.dart';
import '../models/venue.dart';
import '../widgets/photo_gradient.dart';
import 'add_area.dart';

class VenuePage extends StatefulWidget {
  final String venueId;
  const VenuePage(this.venueId, {Key? key}) : super(key: key);

  @override
  _VenuePageState createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  Venue venue = Venue("Loading...", LatLng(999, 999), 0);
  DataRepository dataRepository = DataRepository();
  int areaCount = 0;

  void handleActions(String value) {
    switch (value) {
      case 'Add area':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddArea(venue)));
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
        .get()
        .then((querySnapshot) {
      if (querySnapshot.exists) {
        setState(() {
          venue = Venue.fromSnapshot(querySnapshot);
        });
      }
    });
    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .get()
        .then((areas) => {areaCount = areas.size});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            //title: Text(widget.venue.name),
            actions: <Widget>[
              Visibility(
                visible: venue.venueType == 0 ? true : false,
                child: IconButton(
                  icon: Icon(
                    Icons.cloud,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // do something
                  },
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (handleActions),
                itemBuilder: (BuildContext context) {
                  return {'Add area'}.map((String choice) {
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
          body: Column(
            children: [
              PhotoGradient(venue.name, venue.description.toString(),
                  venue.imagePath.toString()),
              areaCount > 0
                  ? Expanded(child: AreaList(venue.referenceId.toString()))
                  : Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('Nothing to display',
                              style: TextStyle(fontSize: 21)),
                          ElevatedButton.icon(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddArea(venue)))
                                  },
                              icon: Icon(Icons.add),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              label: Text('Add area'))
                        ],
                      ),
                    ),
            ],
          ),
          floatingActionButton: Visibility(
            visible: venue.venueType == 0 ? true : false,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.green,
              onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VenueMap(venue)))
              },
              label: Text('Map'),
              icon: Icon(Icons.map),
            ),
          )),
    );
  }
}
