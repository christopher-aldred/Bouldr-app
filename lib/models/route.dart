// ignore_for_file: non_constant_identifier_names

import 'package:bouldr/models/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Route {
  //Required
  String name;
  int grade;
  String? baseImagePath;

  //Optional
  String? referenceId;
  String? description;
  Verification? verification;
  String? imagePath;
  List? routes;

  Route(this.name, this.grade);

  factory Route.fromSnapshot(DocumentSnapshot snapshot) {
    final newSection = Route.fromJson(snapshot.data() as Map<String, dynamic>);
    newSection.referenceId = snapshot.reference.id;
    return newSection;
  }

  factory Route.fromJson(Map<String, dynamic> json) => _RouteFromJson(json);

  Map<String, dynamic> toJson() => _RouteToJson(this);

  @override
  String toString() => 'Route<$name>';
}

Route _RouteFromJson(Map<String, dynamic> json) {
  //Required attributes

  Route route = Route(json['name'], json['grade']);

  //Optional attributes
  route.description = json['description'];
  route.imagePath = json['image'];

  //Return
  return route;
}

Map<String, dynamic> _RouteToJson(Route instance) => <String, dynamic>{
      'name': instance.name,
      'grade': instance.grade,
      'image': instance.imagePath,
    };
