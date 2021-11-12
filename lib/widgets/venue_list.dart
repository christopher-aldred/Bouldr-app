// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:bouldr/pages/search_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class VenueList extends StatefulWidget {
  const VenueList({Key? key}) : super(key: key);

  @override
  _VenueListState createState() => _VenueListState();
}

class _VenueListState extends State<VenueList>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController textController = TextEditingController();
  final Location location = Location();

  void search(String searchText) async {
    if (searchText != "") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SearchPage(searchText)));
      await Future.delayed(Duration(seconds: 1));
      textController.text = "";
      FocusScope.of(context).unfocus();
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData>(
      future: location.getLocation(),
      builder: (
        BuildContext context,
        AsyncSnapshot<LocationData> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          double currentLat;
          double currentLong;
          if (snapshot.hasData) {
            currentLat = snapshot.data!.latitude!;
            currentLong = snapshot.data!.longitude!;
          } else {
            currentLat = 99;
            currentLong = 99;
          }
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('venues')
                .orderBy('name')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(
                          top: 5.0, right: 0.0, left: 0.0, bottom: 0.0),
                      child: Card(
                        child: TextField(
                          controller: textController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            isCollapsed: true,
                            hintText: 'Search',
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 5)),
                          ),
                          onSubmitted: search,
                        ),
                      ),
                    ),
                    Expanded(
                        child: ListView(
                      padding: EdgeInsets.all(0.0),
                      children: snapshot.data!.docs.map((doc) {
                        double distance = 0.0;
                        GeoPoint venueLocation = doc['location'];
                        if (currentLat != 99) {
                          distance = calculateDistance(currentLat, currentLong,
                              venueLocation.latitude, venueLocation.longitude);
                        }
                        return Card(
                          child: ListTile(
                            title: Text(doc['name']),
                            subtitle: Text(distance.toStringAsFixed(2) + ' km'),
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VenuePage(doc.id)))
                            },
                          ),
                        );
                      }).toList(),
                    ))
                  ],
                );
              }
            },
          );
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
