// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:bouldr/pages/search_page.dart';
import 'package:bouldr/pages/venue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../models/hexColor.dart';
import '../models/venue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/data_repository.dart';

class HomeMap extends StatefulWidget {
  HomeMap(BuildContext context, {Key? key}) : super(key: key);
  final DataRepository repository = DataRepository();

  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  TextEditingController textController = TextEditingController();
  Location location = new Location();
  late GoogleMapController mapController;
  late LocationData _pos;
  final LatLng _center = const LatLng(53.904338, -2.146366);
  String selectedCragName = "";

  late BitmapDescriptor icon;
  late BitmapDescriptor icon2;
  late BitmapDescriptor gymMarker;
  late String _mapStyle;
  List<Marker> allMarkers = [];

  bool cragButtonVisibility = false;

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
  }

  void mapItemClick(String title, LatLng location) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 13),
      ),
    );
    setState(() {
      cragButtonVisibility = true;
      selectedCragName = title;
    });
  }

  void addMapMarker(String Id, String name, LatLng location, int venueType) {
    setState(() {
      // add marker
      allMarkers.add(Marker(
        markerId: MarkerId(Id),
        infoWindow: InfoWindow(
            title: name,
            onTap: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => VenuePage(Id)))
                }),
        draggable: false,
        icon: venueType == 0 ? icon : gymMarker,
        position: location,
        onTap: () => mapItemClick(name, location),
      ));
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
      querySnapshot.docs.forEach((result) {
        String id = result.id;
        String name = result["name"];
        GeoPoint geoPoint = result["location"];
        int venueType = result["venueType"].toInt();
        addMapMarker(
            id, name, LatLng(geoPoint.latitude, geoPoint.longitude), venueType);
      });
    });

    /*
    setState(() {
      // add marker
      allMarkers.add(Marker(
        markerId: MarkerId('Stanage'),
        infoWindow: InfoWindow(
            title: 'Stanage',
            onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VenuePage('Stanage')))
                }),
        draggable: false,
        icon: icon,
        position: LatLng(53.330051, -1.656470),
        onTap: () => mapItemClick("Stanage", LatLng(53.330051, -1.656470)),
      ));

      allMarkers.add(Marker(
        markerId: MarkerId('Climbing depot'),
        infoWindow: InfoWindow(
            title: 'Climbing depot',
            onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VenuePage('Climbing depot')))
                }),
        draggable: false,
        icon: gymMarker,
        position: LatLng(53.471803, -2.321629),
        onTap: () =>
            mapItemClick("Climbing depot", LatLng(53.471803, -2.321629)),
      ));
    });
    */
  }

  void search(String searchText) async {
    if (searchText != "") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SearchPage(searchText)));
      await Future.delayed(Duration(seconds: 1));
      textController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bouldr'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.filter_list_alt,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
              },
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          // The containers in the background
          GoogleMap(
            onMapCreated: _onMapCreated,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            onTap: (latlng) => {
              setState(() {
                cragButtonVisibility = false;
                selectedCragName = "";
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
            padding: new EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0),
            child: Card(
              child: TextField(
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
                child: Text(
                  selectedCragName,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: HexColor("808080"),
                  ),
                ),
                margin: const EdgeInsets.only(
                    left: 30.0, right: 30.0, bottom: 60.0),
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
                  textStyle: const TextStyle(fontSize: 20),
                  minimumSize: Size(MediaQuery.of(context).size.width, 40),
                  alignment: Alignment.center,
                ),
                onPressed: (() => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  VenuePage(selectedCragName)))
                    }),
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
        ]));
  }
}
