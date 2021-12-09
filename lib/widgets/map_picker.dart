// ignore_for_file: prefer_const_constructors

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class MapPicker extends StatefulWidget {
  double startLat;
  double startLong;
  MapPicker([this.startLat = -999, this.startLong = -999]);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late GoogleMapController _controller;
  LatLng _lastMapPosition = LatLng(0, 0);
  Location location = Location();

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    if (widget.startLat != -999 || widget.startLong != -999) {
      _lastMapPosition = LatLng(widget.startLat, widget.startLong);
      _controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _lastMapPosition, zoom: 17),
      ));
    } else {
      location.getLocation().then((value) => {
            _lastMapPosition =
                LatLng(value.latitude!.toDouble(), value.longitude!.toDouble()),
            _controller.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: _lastMapPosition, zoom: 17),
            ))
          });
    }
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
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                  zoom: 1,
                  target: LatLng(
                      _lastMapPosition.latitude, _lastMapPosition.longitude)),
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
