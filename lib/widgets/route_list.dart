// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grade.dart';
import '../customisations/expansion_panel.dart' as custom_expansion_panel;

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

  Color getRouteColorByGrade(int grade) {
    if (grade <= 2) {
      return Colors.green;
    }
    if (grade > 2 && grade <= 4) {
      return Colors.yellow;
    }
    if (grade > 4 && grade <= 10) {
      return Colors.orange;
    }
    if (grade > 10 && grade <= 16) {
      return Colors.red;
    }
    if (grade > 16) {
      return Colors.black;
    }
    return Colors.white;
  }

  void optionsDialogue(
      {required String id,
      required String routeName,
      required String createdBy,
      required String description}) {
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
                return ListView(children: <Widget>[
                  Builder(builder: (BuildContext context) {
                    List<custom_expansion_panel.ExpansionPanel> panels = [];

                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      var route = snapshot.data!.docs[i];
                      panels.add(custom_expansion_panel.ExpansionPanel(
                        isExpanded: widget.selectedRouteId == route.id,
                        hasIcon: false,
                        headerBuilder:
                            (BuildContext context, bool isExpanded) => ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: getRouteColorByGrade(
                                            route['grade']),
                                        border: Border.all(
                                          color: getRouteColorByGrade(
                                              route['grade']),
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Text(
                                        widget.grade.getGradeByIndex(
                                            route['grade'],
                                            prefs
                                                .getString('gradingScale')
                                                .toString()),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                              )
                            ],
                          ),
                          trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Visibility(
                                          visible: route['dyno'] == true,
                                          child: Image(
                                              height: 30,
                                              width: 30,
                                              image: AssetImage(
                                                  'assets/images/dyno.png'))),
                                      Visibility(
                                          visible: route['crimpy'] == true,
                                          child: Image(
                                              height: 30,
                                              width: 30,
                                              image: AssetImage(
                                                  'assets/images/crimp.png'))),
                                      Visibility(
                                          visible: route['sitStart'] == true,
                                          child: Image(
                                              height: 30,
                                              width: 30,
                                              image: AssetImage(
                                                  'assets/images/sit_start.png'))),
                                      Visibility(
                                          visible: route['jam'] == true,
                                          child: Image(
                                              height: 30,
                                              width: 30,
                                              image: AssetImage(
                                                  'assets/images/jam.png'))),
                                    ])
                              ]),
                          onTap: () => {widget.callBackSelectRoute(route.id)},
                          onLongPress: () => {
                            optionsDialogue(
                                id: route.id,
                                routeName: route['name'],
                                createdBy: route['createdBy'],
                                description: route['description'])
                          },
                          //leading: Icon(FontAwesomeIcons.bookmark),
                          title: Align(
                            child: new Text(
                              route['name'],
                              style: TextStyle(
                                  color: widget.selectedRouteId == route.id
                                      ? Colors.green
                                      : Colors.black,
                                  fontWeight: widget.selectedRouteId == route.id
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            alignment: Alignment(-1.1, 0),
                          ),
                        ),
                        body: ListTile(
                          title: Text(
                            route['description'],
                          ),
                        ),
                      ));
                    }

                    return custom_expansion_panel.ExpansionPanelList(
                      children: panels,
                      expandedHeaderPadding: EdgeInsets.all(0),
                    );
                  })
                ]);
                /*
                ListView.builder(
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
                                  createdBy: route['createdBy'],
                                  description: route['description'])
                            },
                          ));
                    });
                    */
              }
            },
          );
        });
  }
}
