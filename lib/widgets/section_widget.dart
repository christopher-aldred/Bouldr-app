// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/section.dart';
import 'package:bouldr/pages/add_route_1.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/widgets/route_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bouldr/models/route.dart' as custom_route;
import 'package:fluttertoast/fluttertoast.dart';

class SectionWidget extends StatefulWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  const SectionWidget(this.venueId, this.areaId, this.sectionId, {Key? key})
      : super(key: key);

  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget>
    with AutomaticKeepAliveClientMixin {
  Section section = Section('Loading...', '');
  List<custom_route.Route> routes = [];
  String selectedRouteImageUrl = "";
  int routeCount = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .collection('sections')
        .doc(widget.sectionId)
        .collection('routes')
        .get()
        .then((routes) => {routeCount = routes.size});
  }

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .collection('sections')
        .doc(widget.sectionId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.exists) {
        setState(() {
          section = Section.fromSnapshot(querySnapshot);
        });
      }
    });

    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .collection('sections')
        .doc(widget.sectionId)
        .collection('routes')
        .orderBy('name')
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs.forEach((element) {
                setState(() {
                  routes.add(custom_route.Route.fromSnapshot(element));
                });
              }),
              {selectedRouteImageUrl = routes[0].imagePath!}
            });
  }

  void selectRoute(String id) {
    Set<custom_route.Route> mSet = routes.toSet();
    custom_route.Route filtered =
        mSet.firstWhere((item) => item.referenceId.toString() == id.toString());
    setState(() {
      selectedRouteImageUrl = filtered.imagePath.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(children: <Widget>[
        SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Stack(
              children: <Widget>[
                Container(
                  color: Colors.black,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.03, 0.9, 1],
                    ),
                  ),
                  child: InteractiveViewer(
                    panEnabled: false, // Set it to false
                    minScale: 1,
                    maxScale: 4,
                    child: Stack(children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: section.imagePath.toString(),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => SizedBox(
                          height: 100,
                          width: 100,
                          child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.grey),
                          ),
                        ),
                        /*
                  errorWidget: (context, url, error) => Image(
                      image: AssetImage('assets/images/missing.png'),
                      fit: BoxFit.cover),
                      */
                        errorWidget: (context, url, error) => SizedBox(
                          height: 100,
                          width: 100,
                          child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.grey),
                          ),
                        ),
                      ),
                      CachedNetworkImage(
                        imageUrl: selectedRouteImageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => SizedBox(
                          height: 100,
                          width: 100,
                          child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.grey),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(),
                      ),
                    ]),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        section.name,
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            )),
        routeCount != 0
            ? Expanded(
                child: RouteList(widget.venueId, widget.areaId,
                    widget.sectionId, selectRoute))
            : Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'No routes to display, try adding one',
                  style: TextStyle(color: Colors.grey),
                ))
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () => {
          if (AuthenticationHelper().user != null)
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddRoute1(
                          widget.venueId, widget.areaId, section.referenceId!)))
            }
          else
            {
              Fluttertoast.showToast(
                msg: 'Must be logged in to perform this action',
              ),
              AuthenticationHelper().loginDialogue(context)
            }
        },
        label: Text('Add route'),
        icon: Icon(Icons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
