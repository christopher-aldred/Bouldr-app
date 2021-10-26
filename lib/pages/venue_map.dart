// ignore_for_file: prefer_const_constructors

import 'package:bouldr/models/venue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class VenueMap extends StatefulWidget {
  final Venue venue;
  const VenueMap(this.venue, {Key? key}) : super(key: key);

  @override
  _VenueMapState createState() => _VenueMapState();
}

class _VenueMapState extends State<VenueMap> {
  MapboxMapController? controller;

  void loadAreas() async {
    List<LatLng> locations = [];
    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venue.referenceId)
        .collection('areas')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        String id = result.id;
        String name = result["name"];
        GeoPoint geoPoint = result["location"];

        locations.add(LatLng(geoPoint.latitude, geoPoint.longitude));

        setState(() {
          controller!.addSymbol(
            SymbolOptions(
                geometry: LatLng(
                  geoPoint.latitude,
                  geoPoint.longitude,
                ),
                iconImage: "assets/images/boulder_marker.png",
                textField: name,
                textOffset: Offset(0, 1.8)),
          );
        });
      });

      if (locations.length > 0) {
        double minLat = 99.0;
        double minLong = 99.0;
        double maxLat = 99.0;
        double maxLong = 99.0;

        locations.forEach((element) {
          if (minLat.compareTo(90.0) > 0) {
            minLat = element.latitude;
            maxLat = element.latitude;
            minLong = element.longitude;
            maxLong = element.longitude;
          } else {
            if (element.latitude > maxLat) {
              maxLat = element.latitude;
            }
            if (element.latitude < minLat) {
              minLat = element.latitude;
            }
            if (element.longitude > maxLong) {
              maxLong = element.longitude;
            }
            if (element.longitude < minLong) {
              minLong = element.longitude;
            }
          }
        });

        controller!.moveCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong),
          ),
        ));
        controller!.animateCamera(CameraUpdate.zoomBy(-2.0));
      }
    });
  }

  void _onStyleLoaded() {
    loadAreas();
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    //controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void handleActions(String value) {
    switch (value) {
      case 'Logout':
        break;
      case 'Settings':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.venue.name + " map"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.filter_list_alt,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            PopupMenuButton<String>(
              onSelected: (handleActions),
              itemBuilder: (BuildContext context) {
                return {'Add area', 'Delete area'}.map((String choice) {
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
        body: MapboxMap(
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            accessToken:
                "sk.eyJ1IjoiY2hyaXMtYWxkcmVkIiwiYSI6ImNrdXpxb2phczMxaGYydXF2bTZmZjNwYWEifQ.ED2yfLbLpNQ_BikUaOYAbg",
            initialCameraPosition: CameraPosition(
              zoom: 14,
              target: LatLng(
                widget.venue.location.latitude,
                widget.venue.location.longitude,
              ),
            )));
  }
}
