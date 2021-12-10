// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grade.dart';
import '../customisations/expansion_panel.dart' as custom_expansion_panel;
import 'package:share/share.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
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
  ScrollController controller = ScrollController();
  Set<String> climbedRoutes = {};

  //@override
  void getAscents() {
    //super.didChangeDependencies();
    if (AuthenticationHelper().user != null) {
      widget.db
          .collection('users')
          .doc(AuthenticationHelper().user.uid)
          .collection('ascents')
          .get()
          .then((value) => {
                if (value.docs.length > 0)
                  {
                    //setState(() {
                    value.docs.forEach((element) {
                      climbedRoutes.add(element['routeId']); //;
                      //});
                    })
                  }
              });
    }
  }

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

  void shareDynamicLink(String id, String name) async {
    String url = 'https://bouldr.co.uk/?venue=' +
        widget.venueId +
        '&area=' +
        widget.areaId +
        '&section=' +
        widget.sectionId +
        '&route=' +
        id;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://bouldr.page.link',
      link: Uri.parse(url),
      androidParameters: AndroidParameters(
        packageName: 'com.credible.bouldr',
        minimumVersion: 13,
      ),
      /*
      iosParameters: IosParameters(
        bundleId: 'com.credible.bouldr',
        minimumVersion: '13',
        appStoreId: 'your_app_store_id',
      ),
      */
    );
    var dynamicUrl = parameters.buildShortLink();
    //final Uri shortUrl = dynamicUrl.shortUrl;

    dynamicUrl.then((value) => {
          Share.share("I've shared a Bouldr route with you 🧗🏼‍♀️\n\n" +
              "Route name - " +
              name +
              "\n\n" +
              value.shortUrl.toString())
        });
  }

  void logAscent(route) async {
    if (AuthenticationHelper().user == null) {
      AuthenticationHelper().loginDialogue(context);
      Fluttertoast.showToast(
        msg: "Sign in to log climbs",
      );
      return;
    }
    showDialog(
        context: context,
        builder: (context) {
          String ascentStyle = "";
          DateTime ascentDate = DateTime.now();
          return StatefulBuilder(builder: (context, setStateDialogue) {
            return AlertDialog(
              title: Text('Log ascent', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(route['name']),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  DateTimeField(
                    initialValue: DateTime.now(),
                    format: DateFormat("dd-MM-yyyy"),
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                      if (date != null) {
                        ascentDate = date;
                        return date;
                      } else {
                        return currentValue;
                      }
                    },
                  ),
                  DropdownButton(
                    onTap: () => {FocusScope.of(context).unfocus()},
                    hint: ascentStyle == ""
                        ? Text('Select ascent style')
                        : Text(ascentStyle),
                    isExpanded: true,
                    iconSize: 30.0,
                    items: ['Onsight', 'Flash', 'Repeat'].map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      setStateDialogue(
                        () {
                          ascentStyle = val.toString();
                        },
                      );
                    },
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.grey)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'))),
                        SizedBox(width: 20),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  if (ascentStyle != "") {
                                    Navigator.pop(context);
                                    dr
                                        .addAscent(
                                            route.id, ascentStyle, ascentDate)
                                        .then((value) => {
                                              setState(() {
                                                widget.selectedRouteId =
                                                    route.id;
                                              }),
                                            });
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Must select ascent style",
                                    );
                                  }
                                },
                                child: Text('Save'))) // button 2
                      ])
                ],
              ),
            );
          });
        });
  }

  void viewAscent(route) {}

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
                            Text('Created by: ' + data['displayName']),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      shareDynamicLink(id, routeName);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Share route')))
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
                                            child: Text('Report route'))),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      shareDynamicLink(id, routeName);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Share route')))
                          ],
                        ),
                      );
                    }
                  })
            });
  }

  void scrollToListView(index) {
    double scrollOffset = 0;
    if ((index * 60.0) - 60 > 0) {
      scrollOffset = (index * 60.0) - 60;
    }
    controller.animateTo(scrollOffset,
        duration: Duration(milliseconds: 250), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    getAscents();
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
                return ListView(controller: controller, children: <Widget>[
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
                          /*
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
                              ]),*/
                          trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(mainAxisSize: MainAxisSize.min, children: <
                                    Widget>[
                                  InkWell(
                                    child: climbedRoutes.firstWhere(
                                                (item) =>
                                                    item.toString() == route.id,
                                                orElse: () => "") ==
                                            ""
                                        ? Icon(Icons.circle_outlined)
                                        : Icon(Icons.check_circle,
                                            color: Colors.green),
                                    onTap: climbedRoutes.firstWhere(
                                                (item) =>
                                                    item.toString() == route.id,
                                                orElse: () => "") ==
                                            ""
                                        ? () => {logAscent(route)}
                                        : () => {viewAscent(route)},
                                  )
                                ])
                              ]),
                          onTap: () => {
                            widget.callBackSelectRoute(route.id),
                          },
                          onLongPress: () => {
                            optionsDialogue(
                                id: route.id,
                                routeName: route['name'],
                                createdBy: route['createdBy'],
                                description: route['description'])
                          },
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
                          onLongPress: () => {
                            optionsDialogue(
                                id: route.id,
                                routeName: route['name'],
                                createdBy: route['createdBy'],
                                description: route['description'])
                          },
                        ),
                      ));

                      if (widget.selectedRouteId == route.id) {
                        scrollToListView(i);
                      }
                    }

                    return custom_expansion_panel.ExpansionPanelList(
                      children: panels,
                      expandedHeaderPadding: EdgeInsets.all(0),
                    );
                  }),
                  SizedBox(height: 140),
                ]);
              }
            },
          );
        });
  }
}
