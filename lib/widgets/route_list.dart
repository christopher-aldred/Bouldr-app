// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grade.dart';

class RouteList extends StatefulWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  final db = FirebaseFirestore.instance;
  final Grade grade = Grade();
  final Function(String) callBackSelectRoute;
  final Function() callBackRefreshSection;

  String selectedRouteId = "";

  RouteList(this.venueId, this.areaId, this.sectionId, this.callBackSelectRoute,
      this.callBackRefreshSection, this.selectedRouteId);

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  DataRepository dr = DataRepository();
  late SharedPreferences prefs;

  Future<String> getGradingScale() async {
    prefs = await SharedPreferences.getInstance();
    var defaultHomeTab = prefs.getString('gradingScale');
    return Future.value(defaultHomeTab);
  }

  void optionsDialogue(
      {required String id,
      required String routeName,
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
                        title: Text(routeName, textAlign: TextAlign.center),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Created by: ' + data['displayName'])
                          ],
                        ),
                      );
                    } else {
                      return AlertDialog(
                        title: Text(routeName, textAlign: TextAlign.center),
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
                                              dr
                                                  .deleteRoute(
                                                      widget.venueId,
                                                      widget.areaId,
                                                      widget.sectionId,
                                                      id)
                                                  .then((value) => {
                                                        widget
                                                            .callBackRefreshSection()
                                                      });
                                            },
                                            child: Text('Delete route'))
                                        : ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Report route')))
                          ],
                        ),
                      );
                    }
                  })
            });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getGradingScale(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: widget.db
                .collection('venues')
                .doc(widget.venueId)
                .collection('areas')
                .doc(widget.areaId)
                .collection('sections')
                .doc(widget.sectionId)
                .collection('routes')
                .orderBy('name')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var route = snapshot.data!.docs[index];
                      return Card(
                          color: widget.selectedRouteId == route.id
                              ? HexColor('e0e0e0')
                              : Colors.white,
                          child: ListTile(
                            title: Text(
                              route['name'],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: widget.selectedRouteId == route.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text("Grade: " +
                                widget.grade.getGradeByIndex(
                                    route['grade'],
                                    prefs
                                        .getString('gradingScale')
                                        .toString())),
                            onTap: () => {widget.callBackSelectRoute(route.id)},
                            onLongPress: () => {
                              optionsDialogue(
                                  id: route.id,
                                  routeName: route['name'],
                                  createdBy: route['createdBy'])
                            },
                          ));
                    });
              }
            },
          );
        });
  }
}
