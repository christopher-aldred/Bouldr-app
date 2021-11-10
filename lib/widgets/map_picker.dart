// ignore_for_file: prefer_const_constructors

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class MapPicker extends StatefulWidget {
  final double startLat;
  final double startLong;
  const MapPicker(this.startLat, this.startLong, {Key? key}) : super(key: key);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late GoogleMapController _controller;
  Location _location = Location();
  late LatLng _lastMapPosition;

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _lastMapPosition = LatLng(widget.startLat, widget.startLong);
    _controller.moveCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _lastMapPosition, zoom: 18),
    ));
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose location"),
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.startLat, widget.startLong)),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              myLocationEnabled: true,
            ),
            Center(
              child: SizedBox(
                  child: Opacity(
                      opacity: 0.25,
                      child: Image(
                          image: AssetImage('assets/images/crosshairs.png'))),
                  height: 100,
                  width: 100),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () => {Navigator.pop(context, _lastMapPosition)},
        label: Text('Select'),
        icon: Icon(Icons.check),
      ),
    );
  }
}
