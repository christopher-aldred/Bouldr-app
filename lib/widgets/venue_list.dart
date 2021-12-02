// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:algolia/algolia.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/widgets/gradeBarCharSmall.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

// ignore: must_be_immutable
class VenueList extends StatefulWidget {
  String? searchText;
  VenueList([this.searchText]);

  @override
  _VenueListState createState() => _VenueListState();
}

class _VenueListState extends State<VenueList> {
  final Location location = Location();
  DataRepository dr = DataRepository();
  double currentLat = -999;
  double currentLong = -999;
  List<String> matchedVenues = ["-XYZ"];

  Algolia algolia = Algolia.init(
    applicationId: 'FT3I3LE34T',
    apiKey: '87439e6206f73431de605ad86da3e139',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void queryAlgolia() async {
    if (widget.searchText != null &&
        matchedVenues.length == 1 &&
        matchedVenues[0] == "-XYZ") {
      List<String> temp = [];
      AlgoliaQuery query =
          algolia.instance.index('venues').query(widget.searchText.toString());
      AlgoliaQuerySnapshot snap = await query.getObjects();
      snap.hits.forEach((element) {
        temp.add(element.data['objectID']);
      });
      setState(() {
        matchedVenues = temp;
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStream(
      GeoPoint lesserGeopoint, GeoPoint greaterGeopoint) {
    if (widget.searchText == null) {
      if (currentLat == -999 || currentLong == -999) {
        return FirebaseFirestore.instance
            .collection('venues')
            .orderBy('name')
            .snapshots();
      } else {
        return FirebaseFirestore.instance
            .collection('venues')
            .where("location", isGreaterThan: lesserGeopoint)
            .where("location", isLessThan: greaterGeopoint)
            .snapshots();
      }
    } else {
      return FirebaseFirestore.instance
          .collection('venues')
          .where(FieldPath.documentId, whereIn: matchedVenues)
          .snapshots();
    }
  }

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
    queryAlgolia();
    return FutureBuilder<LocationData>(
      future: location.getLocation(),
      builder: (
        BuildContext context,
        AsyncSnapshot<LocationData> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            currentLat = snapshot.data!.latitude!;
            currentLong = snapshot.data!.longitude!;
          }

          var distance = 50;

          double lat = 0.0144927536231884;
          double lon = 0.0181818181818182;
          double lowerLat = currentLat - (lat * distance);
          double lowerLon = currentLong - (lon * distance);
          double greaterLat = currentLat + (lat * distance);
          double greaterLon = currentLong + (lon * distance);

          GeoPoint lesserGeopoint = GeoPoint(lowerLat, lowerLon);
          GeoPoint greaterGeopoint = GeoPoint(greaterLat, greaterLon);

          return StreamBuilder<QuerySnapshot>(
            stream: getStream(lesserGeopoint, greaterGeopoint),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                List geoOrdered = snapshot.data!.docs.toList();

                if (currentLat != -999) {
                  for (int i = 0; i < geoOrdered.length - 1; i++) {
                    for (int j = 0; j < geoOrdered.length - i - 1; j++) {
                      var docA = geoOrdered[j];
                      var docB = geoOrdered[j + 1];

                      GeoPoint geoA = docA['location'];
                      GeoPoint geoB = docB['location'];

                      double distA = calculateDistance(currentLat, currentLong,
                          geoA.latitude, geoA.longitude);

                      double distB = calculateDistance(currentLat, currentLong,
                          geoB.latitude, geoB.longitude);

                      if (distA > distB) {
                        // Swapping using temporary variable
                        var temp = geoOrdered[j];
                        geoOrdered[j] = geoOrdered[j + 1];
                        geoOrdered[j + 1] = temp;
                      }
                    }
                  }
                }

                var cardsList = geoOrdered.map((doc) {
                  double distance = 0.0;
                  GeoPoint venueLocation = doc['location'];
                  if (currentLat != -999) {
                    distance = calculateDistance(currentLat, currentLong,
                        venueLocation.latitude, venueLocation.longitude);
                  }
                  return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                          onTap: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VenuePage(doc.id)))
                              },
                          onLongPress: () => {
                                optionsDialogue(
                                    id: doc.id,
                                    venueName: doc['name'],
                                    createdBy: doc['createdBy'])
                              },
                          child: Container(
                              height: 120,
                              padding: const EdgeInsets.all(0),
                              child: Row(children: [
                                Expanded(
                                    flex: 6,
                                    child: Container(
                                        child: doc['image'] != null
                                            ? CachedNetworkImage(
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                                imageUrl: doc['image'])
                                            : Image(
                                                image: AssetImage(
                                                    'assets/images/missing.png'),
                                                fit: BoxFit.fill))),
                                Spacer(
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 14,
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(doc['name'],
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold)),
                                        Text(distance.toStringAsFixed(2) +
                                            ' km'),
                                        Expanded(
                                            child: Container(
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 10, 0, 10),
                                                    child: GradeBarChartSmall(
                                                        doc.id)))),
                                      ],
                                    ),
                                  ),
                                ),
                              ]))));
                }).toList();
                return FadeIn(
                  child: ListView(
                    padding: EdgeInsets.all(0.0),
                    children: cardsList,
                  ),
                  // Optional paramaters
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeIn,
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
}
