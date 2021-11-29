// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:bouldr/pages/search_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class VenueList extends StatefulWidget {
  String? searchText;
  VenueList([this.searchText]);

  @override
  _VenueListState createState() => _VenueListState();
}

class _VenueListState extends State<VenueList>
    with AutomaticKeepAliveClientMixin {
  final Location location = Location();
  DataRepository dr = DataRepository();

  void optionsDialogue(
      {required String id,
      required String venueName,
      required String createdBy}) {
    FirebaseFirestore.instance
        .collection("/users")
        .doc(createdBy)
        .get()
        .then((data) => {
              showDialog(
                  context: context,
                  builder: (context) {
                    if (AuthenticationHelper().user == null) {
                      return AlertDialog(
                        title: Text(venueName, textAlign: TextAlign.center),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Created by: ' + data['displayName'])
                          ],
                        ),
                      );
                    } else {
                      return AlertDialog(
                        title: Text(venueName, textAlign: TextAlign.center),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Created by: ' + data['displayName']),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child:
                                    createdBy == AuthenticationHelper().user.uid
                                        ? ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              dr.deleteVenue(id);
                                            },
                                            child: Text('Delete venue'))
                                        : ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Report venue')))
                          ],
                        ),
                      );
                    }
                  })
            });
  }

  void search(String searchText) async {
    if (searchText != "") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SearchPage(searchText)));
      //await Future.delayed(Duration(seconds: 1));
      //textController.text = "";
      //FocusScope.of(context).unfocus();
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
    super.build(context);
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
            currentLat = -1;
            currentLong = -1;
          }
          return StreamBuilder<QuerySnapshot>(
            stream: widget.searchText == null
                ? FirebaseFirestore.instance
                    .collection('venues')
                    .orderBy('name')
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('venues')
                    .orderBy('searchField')
                    .startAt([widget.searchText!.toLowerCase()]).endAt([
                    widget.searchText!.toLowerCase() + '\uf8ff'
                  ]).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView(
                  padding: EdgeInsets.all(0.0),
                  children: snapshot.data!.docs.map((doc) {
                    double distance = 0.0;
                    GeoPoint venueLocation = doc['location'];
                    if (currentLat != -1) {
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
                        onLongPress: () => {
                          optionsDialogue(
                              id: doc.id,
                              venueName: doc['name'],
                              createdBy: doc['createdBy'])
                        },
                      ),
                    );
                  }).toList(),
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
