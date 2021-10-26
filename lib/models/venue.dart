import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Venue {
  String name;
  String? description;
  LatLng location;
  List? areas; //to-do hold object areas
  int venueType; // 0=Crag, 1=Gym
  String? referenceId;

  Venue(this.name, this.location, this.venueType);

  factory Venue.fromSnapshot(DocumentSnapshot snapshot) {
    final newVenue = Venue.fromJson(snapshot.data() as Map<String, dynamic>);
    newVenue.referenceId = snapshot.reference.id;
    return newVenue;
  }

  factory Venue.fromJson(Map<String, dynamic> json) => _venueFromJson(json);

  Map<String, dynamic> toJson() => _venueToJson(this);

  @override
  String toString() => 'Venue<$name>';
}

Venue _venueFromJson(Map<String, dynamic> json) {
  GeoPoint pos = json['location'];
  LatLng latLng = LatLng(pos.latitude, pos.longitude);
  return Venue(json['name'], latLng, json['venueType']);
}

Map<String, dynamic> _venueToJson(Venue instance) => <String, dynamic>{
      'name': instance.name,
      'location':
          GeoPoint(instance.location.latitude, instance.location.longitude),
      'venueType': instance.venueType,
    };

Venue createVenue(record) {
  Map<dynamic, dynamic> attributes = {
    'name': '',
    'location': '',
    'venueType': ''
  };

  record.forEach((key, value) => {attributes[key] = value});

  Venue venue = Venue(
      attributes['name'], attributes['location'], attributes['venueType']);
  return venue;
}
