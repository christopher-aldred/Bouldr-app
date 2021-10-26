// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/route.dart';
import 'package:bouldr/models/section.dart';
import 'package:bouldr/pages/add_route_1.dart';
import 'package:bouldr/widgets/route_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bouldr/models/route.dart' as customRoute;

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
  List<customRoute.Route> routes = [];
  String selectedRouteImageUrl = "";

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
                  routes.add(customRoute.Route.fromSnapshot(element));
                });
              }),
              {selectedRouteImageUrl = routes[0].imagePath!}
            });

/*
    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .collection('sections')
        .doc(widget.sectionId)
        .collection('routes')
        .orderBy('name')
        .limit(1)
        .get()
        .then((querySnapshot) =>
            {selectedRouteImageUrl = querySnapshot.docs[0]['image']});
*/
  }

  void selectRoute(String id) {
    Set<customRoute.Route> mSet = routes.toSet();
    customRoute.Route filtered =
        mSet.firstWhere((item) => item.referenceId.toString() == id.toString());
    setState(() {
      selectedRouteImageUrl = filtered.imagePath.toString();
    });
  }
/*
  void selectRoute(String id) {
    FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .doc(widget.areaId)
        .collection('sections')
        .doc(widget.sectionId)
        .collection('routes')
        .doc(id)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.exists) {
        setState(() {
          selectedRouteImageUrl = querySnapshot['image'];
        });
      }
    });
  }
  */

  /*

  void selectRoute(String id) {
    Set<customRoute.Route> routesSet = routes.toSet();
    //Set filteredSet = routesSet.where((item) => item.a  == "someString1").length > 0;
    customRoute.Route route =
        routesSet.firstWhere((item) => item.referenceId == id);
    //return filtered.first.imagePath;
    selectedRouteImageUrl = route.imagePath!;
  }

  */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Column(children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Container(
            color: Colors.black,
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.03, 0.97, 1],
              ),
            ),
            child: InteractiveViewer(
              panEnabled: false, // Set it to false
              minScale: 1,
              maxScale: 4,
              child: Stack(children: <Widget>[
                CachedNetworkImage(
                  imageUrl: section.imagePath,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image(
                      image: AssetImage('assets/images/missing.png'),
                      fit: BoxFit.contain),
                ),
                CachedNetworkImage(
                  imageUrl: selectedRouteImageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    ),
                  ),
                  errorWidget: (context, url, error) => SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        Expanded(
            child: RouteList(
                widget.venueId, widget.areaId, widget.sectionId, selectRoute))
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddRoute1(
                      widget.venueId, widget.areaId, section.referenceId!)))
        },
        label: Text('Add route'),
        icon: Icon(Icons.add),
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
