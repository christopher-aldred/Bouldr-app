// ignore_for_file: non_constant_identifier_names

import 'package:bouldr/models/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Route {
  //Required
  String name;
  int grade;
  String createdBy;

  //Optional
  String? referenceId;
  String? description;
  Verification? verification;
  String? imagePath;

  bool? crimpy;
  bool? dyno;
  bool? sitStart;
  bool? jam;
  //List? routes;

  //Route(this.name, this.grade, this.createdBy,
  //[this.description, this.imagePath]);
  Route(
      {required this.name,
      required this.grade,
      required this.createdBy,
      this.description,
      this.imagePath,
      this.crimpy,
      this.dyno,
      this.sitStart,
      this.jam});

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

  Route route = Route(
      name: json['name'],
      grade: json['grade'],
      createdBy: json['createdBy'],
      description: json['description'],
      imagePath: json['image'],
      crimpy: json['crimpy'],
      dyno: json['dyno'],
      sitStart: json['sitStart'],
      jam: json['jam']);

  //Return
  return route;
}

Map<String, dynamic> _RouteToJson(Route instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'grade': instance.grade,
      'createdBy': instance.createdBy,
      'image': instance.imagePath,
      'searchField': instance.name.toLowerCase(),
      'timestamp': FieldValue.serverTimestamp(),
      'crimpy': instance.crimpy,
      'dyno': instance.dyno,
      'sitStart': instance.sitStart,
      'jam': instance.jam
      // 'searchTerms': FieldValue.arrayUnion(SearchFunctions.getSearchTerms(instance.name)),
    };
