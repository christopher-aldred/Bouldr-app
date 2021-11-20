// ignore_for_file: non_constant_identifier_names

//import 'package:bouldr/models/route.dart';
import 'package:bouldr/models/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  //Required
  String name;
  String createdBy;

  //Optional
  String? description;
  String? imagePath;
  String? referenceId;
  Verification? verification;
  //List<Route>? routes;

  Section(this.name, this.createdBy, [this.description, this.imagePath]);

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
  Section section = Section(
    json['name'],
    json['createdBy'],
    json['description'],
    json['image'],
  );

  return section;
}

Map<String, dynamic> _SectionToJson(Section instance) => <String, dynamic>{
      'name': instance.name,
      'createdBy': instance.createdBy,
      'description': instance.description,
      'image': instance.imagePath,
      'searchField': instance.name.toLowerCase(),
      'timestamp': FieldValue.serverTimestamp(),
    };
