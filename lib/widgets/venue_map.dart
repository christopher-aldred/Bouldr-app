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
  List<LatLng> markers = [];
  bool loaded = false;

  void loadAreas() {
    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venue.referenceId)
        .collection('areas')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        String name = result["name"];
        GeoPoint geoPoint = result["location"];

        markers.add(LatLng(geoPoint.latitude, geoPoint.longitude));

        setState(() {
          controller!.addSymbol(
            SymbolOptions(
                geometry: LatLng(
                  geoPoint.latitude,
                  geoPoint.longitude,
                ),
                iconImage: "assets/images/boulder_marker.png",
                textField: name,
                textOffset: Offset(0, 2.2)),
          );
        });
      });

      if (markers.length > 0) {
        double minLat = -1;
        double minLong = -1;
        double maxLat = -1;
        double maxLong = -1;

        markers.forEach((element) {
          if (minLat == -1 || minLong == -1 || maxLat == -1 || maxLong == -1) {
            minLat = element.latitude;
            maxLat = element.latitude;
            minLong = element.longitude;
            maxLong = element.longitude;
          }

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
        });

        controller!.moveCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong),
          ),
        ));
        controller!.moveCamera(CameraUpdate.zoomBy(-1.0));
      }
    }).timeout(Duration(seconds: 10));
    setState(() {
      loaded = true;
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
        body: Stack(children: [
          MapboxMap(
              myLocationEnabled: true,
              compassEnabled: true,
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
              )),
          Visibility(
              visible: !loaded,
              child: Center(
                  child: SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              )))
        ]));
  }
}
