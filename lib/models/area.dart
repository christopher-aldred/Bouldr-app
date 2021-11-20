//import 'package:bouldr/models/section.dart';
import 'package:bouldr/models/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Area {
  //Required
  String name;
  LatLng location;
  num routeCount;
  String createdBy;

  //Optional
  String? referenceId;
  String? description;
  Verification? verification;
  //List<Section>? sections;

  Area(this.name, this.location, this.routeCount, this.createdBy,
      [this.description]);

  factory Area.fromSnapshot(DocumentSnapshot snapshot) {
    final newArea = Area.fromJson(snapshot.data() as Map<String, dynamic>);
    newArea.referenceId = snapshot.reference.id;
    return newArea;
  }

  factory Area.fromJson(Map<String, dynamic> json) => _areaFromJson(json);

  Map<String, dynamic> toJson() => _areaToJson(this);

  @override
  String toString() => 'Area<$name>';
}

Area _areaFromJson(Map<String, dynamic> json) {
  GeoPoint pos = json['location'];
  LatLng latLng = LatLng(pos.latitude, pos.longitude);

  Area area = Area(
    json['name'],
    latLng,
    json['routeCount'],
    json['createdBy'],
    json['description'],
  );

  return area;
}

Map<String, dynamic> _areaToJson(Area instance) => <String, dynamic>{
      'name': instance.name,
      'location':
          GeoPoint(instance.location.latitude, instance.location.longitude),
      'routeCount': instance.routeCount,
      'createdBy': instance.createdBy,
      'description': instance.description,
      'searchField': instance.name.toLowerCase(),
      'timestamp': FieldValue.serverTimestamp(),
      //'searchTerms': FieldValue.arrayUnion(SearchFunctions.getSearchTerms(instance.name)),
    };
