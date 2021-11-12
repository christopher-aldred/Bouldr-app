// ignore_for_file: non_constant_identifier_names

import 'package:bouldr/models/route.dart';
import 'package:bouldr/models/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  //Required
  String name;
  String? imagePath;

  //Optional
  String? referenceId;
  String? description;
  Verification? verification;
  List<Route>? routes;

  Section(this.name, [this.imagePath]);

  factory Section.fromSnapshot(DocumentSnapshot snapshot) {
    final newSection =
        Section.fromJson(snapshot.data() as Map<String, dynamic>);
    newSection.referenceId = snapshot.reference.id;
    return newSection;
  }

  factory Section.fromJson(Map<String, dynamic> json) => _SectionFromJson(json);

  Map<String, dynamic> toJson() => _SectionToJson(this);

  @override
  String toString() => 'Section<$name>';
}

Section _SectionFromJson(Map<String, dynamic> json) {
  //Required attributes

  Section section = Section(json['name'], json['image']);

  //Optional attributes
  section.description = json['description'];
  section.imagePath = json['image'];

  //Return
  return section;
}

Map<String, dynamic> _SectionToJson(Section instance) => <String, dynamic>{
      'name': instance.name,
      'image': instance.imagePath,
    };
