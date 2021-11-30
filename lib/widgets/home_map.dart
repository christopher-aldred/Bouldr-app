// ignore_for_file: prefer_const_constructors

import 'package:bouldr/pages/search_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeMapWidget extends StatefulWidget {
  String param;
  bool deep_link;
  HomeMapWidget(this.param, this.deep_link, {Key? key}) : super(key: key);

  @override
  _HomeMapWidgetState createState() => _HomeMapWidgetState();
}

class _HomeMapWidgetState extends State<HomeMapWidget>
    with AutomaticKeepAliveClientMixin {
  TextEditingController textController = TextEditingController();
  Location location = Location();
  late GoogleMapController mapController;
  late LocationData _pos;
  final LatLng _center = const LatLng(53.904338, -2.146366);
  String selectedCragName = "";
  String selectedCragId = "";

  late BitmapDescriptor icon;
  late BitmapDescriptor icon2;
  late BitmapDescriptor gymMarker;
  late String _mapStyle;
  List<Marker> allMarkers = [];

  bool cragButtonVisibility = false;
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
                                              setState(() {
                                                refreshMarker();
                                              });
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

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/boulder_marker.png')
        .then((value) => icon = value);

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/boulder_2_marker.png')
        .then((value) => icon2 = value);

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/gym_marker.png')
        .then((value) => gymMarker = value);

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (widget.deep_link == false) {
        Fluttertoast.showToast(
            msg: "Tap an icon to view the location", timeInSecForIosWeb: 2);
      }
    });
  }

  void mapItemClick(String id, String title, LatLng location) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 13),
      ),
    );
    setState(() {
      cragButtonVisibility = true;
      selectedCragName = title;
      selectedCragId = id;
    });
  }

  void viewVenueClick() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => VenuePage(selectedCragId)));
  }

  void addMapMarker(String id, String name, LatLng location, int venueType,
      String createdBy) {
    setState(() {
      // add marker
      allMarkers.add(Marker(
        markerId: MarkerId(id),
        infoWindow: InfoWindow(
          title: name,
          onTap: () =>
              {optionsDialogue(id: id, venueName: name, createdBy: createdBy)},
        ),
        draggable: false,
        icon: venueType == 0 ? icon : gymMarker,
        position: location,
        onTap: () => mapItemClick(id, name, location),
      ));
    });
  }

  void refreshMarker() {
    allMarkers = [];
    FirebaseFirestore.instance.collection("venues").get().then((querySnapshot) {
      //dataRepository.venues.get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        String id = result.id;
        String name = result["name"];
        GeoPoint geoPoint = result["location"];
        int venueType = result["venueType"].toInt();
        addMapMarker(id, name, LatLng(geoPoint.latitude, geoPoint.longitude),
            venueType, result['createdBy']);
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    controller.setMapStyle(_mapStyle);
    _pos = await location.getLocation();

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(_pos.latitude!, _pos.longitude!), zoom: 8),
      ),
    );

    FirebaseFirestore.instance.collection("venues").get().then((querySnapshot) {
      //dataRepository.venues.get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        String id = result.id;
        String name = result["name"];
        GeoPoint geoPoint = result["location"];
        int venueType = result["venueType"].toInt();
        addMapMarker(id, name, LatLng(geoPoint.latitude, geoPoint.longitude),
            venueType, result['createdBy']);
      });
    });
  }

  void search(String searchText) async {
    if (searchText != "") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SearchPage(searchText)));
      await Future.delayed(Duration(seconds: 1));
      textController.text = "";
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: <Widget>[
      // The containers in the background
      GoogleMap(
        onMapCreated: _onMapCreated,
        mapToolbarEnabled: false,
        mapType: MapType.normal,
        onTap: (latlng) => {
          setState(() {
            cragButtonVisibility = false;
            selectedCragName = "";
            selectedCragId = "";
          })
        },
        markers: Set.from(allMarkers),
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        zoomControlsEnabled: false,
      ),
      Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0),
        child: Card(
          child: TextField(
            textCapitalization: TextCapitalization.words,
            controller: textController,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              isCollapsed: true,
              hintText: 'Search',
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 5)),
            ),
            onSubmitted: search,
          ),
        ),
      ),
      Visibility(
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(
                selectedCragName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: HexColor("808080"),
                ),
              ),
            ),
            margin:
                const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 60.0),
          ),
        ),
        visible: cragButtonVisibility,
      ),
      Visibility(
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              textStyle: const TextStyle(fontSize: 20),
              minimumSize: Size(MediaQuery.of(context).size.width, 40),
              alignment: Alignment.center,
            ),
            onPressed: (viewVenueClick),
            child: Text(
              'Tap to view',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        visible: cragButtonVisibility,
      ),
      Visibility(
          visible: allMarkers.isEmpty,
          child: Center(
              child: SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )))
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
