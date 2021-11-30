// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:bouldr/widgets/gradeBarChart.dart';
import 'package:bouldr/widgets/venue_map.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/widgets/area_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_weather_widget/open_weather_widget.dart';
import '../repository/data_repository.dart';
import '../models/venue.dart';
import '../widgets/photo_gradient.dart';
import 'add_area.dart';
import 'package:maps_launcher/maps_launcher.dart';

class VenuePage extends StatefulWidget {
  final String venueId;
  const VenuePage(this.venueId, {Key? key}) : super(key: key);

  @override
  _VenuePageState createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  Venue venue = Venue("Loading...", LatLng(999, 999), 0, "");
  DataRepository dataRepository = DataRepository();
  int areaCount = -1;
  List<int> gradeCount = [0, 0, 0, 0, 0];

  bool noRoutes() {
    int routeCount = 0;
    routeCount += gradeCount[0] +
        gradeCount[1] +
        gradeCount[2] +
        gradeCount[3] +
        gradeCount[4];
    return routeCount == 0;
  }

  void weatherDialogue() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(20),
              contentPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  // Get available height and width of the build area of this widget. Make a choice depending on the size.
                  var width = MediaQuery.of(context).size.width;
                  return Container(
                    width: width,
                    height: 200,
                    child: OpenWeatherWidget(
                      latitude: venue.location.latitude,
                      longitude: venue.location.longitude,
                      location: venue.name,
                      apiKey: "ed697e99a5234925f46e26bbd132e47e",
                      alignment: MainAxisAlignment.center,
                    ),
                  );
                },
              ),
            ));
  }

  void handleActions(String value) {
    switch (value) {
      case 'Add area':
        if (AuthenticationHelper().user != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddArea(venue)));
        } else {
          Fluttertoast.showToast(
            msg: 'Must be logged in to perform this action',
          );
          AuthenticationHelper().loginDialogue(context);
        }

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
    gradeCount = [0, 0, 0, 0, 0];
    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .get()
        .then((areas) => {
              areaCount = areas.size,
              areas.docs.forEach((area) {
                FirebaseFirestore.instance
                    .collection('venues')
                    .doc(widget.venueId)
                    .collection('areas')
                    .doc(area.id)
                    .collection('sections')
                    .get()
                    .then((sections) => {
                          sections.docs.forEach((section) {
                            FirebaseFirestore.instance
                                .collection('venues')
                                .doc(widget.venueId)
                                .collection('areas')
                                .doc(area.id)
                                .collection('sections')
                                .doc(section.id)
                                .collection('routes')
                                .get()
                                .then((routes) => {
                                      routes.docs.forEach((route) {
                                        FirebaseFirestore.instance
                                            .collection('venues')
                                            .doc(widget.venueId)
                                            .collection('areas')
                                            .doc(area.id)
                                            .collection('sections')
                                            .doc(section.id)
                                            .collection('routes')
                                            .doc(route.id)
                                            .get()
                                            .then((route) => {
                                                  setState(() {
                                                    if (route['grade'] <= 2) {
                                                      gradeCount[0] += 1;
                                                    }
                                                    if (route['grade'] > 2 &&
                                                        route['grade'] <= 4) {
                                                      gradeCount[1] += 1;
                                                    }
                                                    if (route['grade'] > 4 &&
                                                        route['grade'] <= 10) {
                                                      gradeCount[2] += 1;
                                                    }
                                                    if (route['grade'] > 10 &&
                                                        route['grade'] <= 16) {
                                                      gradeCount[3] += 1;
                                                    }
                                                    if (route['grade'] > 16) {
                                                      gradeCount[4] += 1;
                                                    }
                                                  }),
                                                });
                                      })
                                    });
                          })
                        });
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Visibility(
              visible: venue.venueType == 0 ? true : false,
              child: IconButton(
                icon: Icon(
                  Icons.cloud,
                  color: Colors.white,
                ),
                onPressed: weatherDialogue,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.directions,
                color: Colors.white,
              ),
              onPressed: () {
                MapsLauncher.launchCoordinates(
                    venue.location.latitude, venue.location.longitude);
              },
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
        body: SingleChildScrollView(
            child: Column(
          children: [
            PhotoGradient(venue.name, venue.description.toString(),
                venue.imagePath.toString()),
            Visibility(
              visible: !noRoutes(),
              child: Padding(
                padding: EdgeInsets.all(0),
                child: SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    width: double.infinity,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Colors.transparent,
                      child: GradeBarChart(gradeCount),
                    )),
              ),
            ),
            areaCount != 0
                ? AreaList(venue.referenceId.toString())
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Nothing to display',
                            style: TextStyle(fontSize: 21)),
                        ElevatedButton.icon(
                            onPressed: () => {
                                  if (AuthenticationHelper().user != null)
                                    {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddArea(venue)))
                                    }
                                  else
                                    {
                                      AuthenticationHelper()
                                          .loginDialogue(context),
                                      Fluttertoast.showToast(
                                        msg:
                                            'Must be logged in to perform this action',
                                      )
                                    }
                                },
                            icon: Icon(Icons.add),
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                            label: Text('Add area'))
                      ],
                    ),
                  ),
          ],
        )),
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
        ));
  }
}
