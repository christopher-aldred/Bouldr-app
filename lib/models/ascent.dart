//import 'package:bouldr/models/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ascent {
  //Required
  String routeId;
  String style;
  DateTime timestamp;

  //Optional
  String? referenceId;

  Ascent(this.routeId, this.style, this.timestamp);

  factory Ascent.fromSnapshot(DocumentSnapshot snapshot) {
    final newAscent = Ascent.fromJson(snapshot.data() as Map<String, dynamic>);
    newAscent.referenceId = snapshot.reference.id;
    return newAscent;
  }

  factory Ascent.fromJson(Map<String, dynamic> json) => _AscentFromJson(json);

  Map<String, dynamic> toJson() => _AscentToJson(this);

  @override
  String toString() => 'Ascent<$routeId>';
}

Ascent _AscentFromJson(Map<String, dynamic> json) {
  Ascent ascent = Ascent(
    json['routeId'],
    json['style'],
    (json['timestamp'] as Timestamp).toDate(),
  );

  return ascent;
}

Map<String, dynamic> _AscentToJson(Ascent instance) => <String, dynamic>{
      'routeId': instance.routeId,
      'style': instance.style,
      'timestamp': Timestamp.fromDate(instance.timestamp),
      //'searchTerms': FieldValue.arrayUnion(SearchFunctions.getSearchTerms(instance.name)),
    };
