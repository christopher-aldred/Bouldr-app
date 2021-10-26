import 'package:bouldr/models/verification.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Route {
  //Required
  String name;
  LatLng location;
  String? baseImagePath;

  Route(this.name, this.location);

  //Optional
  String? referenceId;
  String? description;
  Verification? verification;
  String? imagePath;
  List? routes;
}
