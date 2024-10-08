import 'package:bouldr/models/verification.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'area.dart';

class Venue {
  //Required
  String name;
  LatLng location;
  int venueType; // 0=Crag, 1=Gym
  String createdBy;

  //Optional
  String? referenceId;
  String? description;
  Verification? verification;
  String? imagePath;
  //List<Area>? areas;

  Venue(this.name, this.location, this.venueType, this.createdBy,
      [this.description, this.imagePath]);

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
  //Parsing location
  GeoPoint pos = json['location'];
  LatLng latLng = LatLng(pos.latitude, pos.longitude);

  //Creating object
  Venue venue = Venue(
    json['name'],
    latLng,
    json['venueType'],
    json['createdBy'],
    json['description'],
    json['image'],
  );

  //Returning object
  return venue;
}

Map<String, dynamic> _venueToJson(Venue instance) => <String, dynamic>{
      'name': instance.name,
      'location':
          GeoPoint(instance.location.latitude, instance.location.longitude),
      'venueType': instance.venueType,
      'createdBy': instance.createdBy,
      'description': instance.description,
      'image': instance.imagePath,
      'searchField': instance.name.toLowerCase(),
      'timestamp': FieldValue.serverTimestamp(),
      //'searchTerms': FieldValue.arrayUnion(SearchFunctions.getSearchTerms(instance.name)),
    };
