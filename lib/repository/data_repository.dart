import 'package:bouldr/models/area.dart';
import 'package:bouldr/models/route.dart';
import 'package:bouldr/models/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/venue.dart';

class DataRepository {
  Future<DocumentReference> addRoute(
      String venueId, String areaId, String sectionId, Route route) {
    final CollectionReference routes = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections')
        .doc(sectionId)
        .collection('routes');
    return routes.add(route.toJson());
  }

  void updateRoute(
      String venueId, String areaId, String sectionId, Route route) async {
    final CollectionReference routes = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections')
        .doc(sectionId)
        .collection('routes');
    await routes.doc(route.referenceId).update(route.toJson());
  }

  Future<DocumentReference> addSection(
      String venueId, String areaId, Section section) {
    final CollectionReference sections = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections');
    return sections.add(section.toJson());
  }

  void updateSection(String venueId, String areaId, Section section) async {
    final CollectionReference sections = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections');
    await sections.doc(section.referenceId).update(section.toJson());
  }

  Future<DocumentReference> addArea(String venueId, Area area) {
    final CollectionReference sections = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas');
    return sections.add(area.toJson());
  }

  void updateArea(String venueId, Area area) async {
    final CollectionReference areas = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas');
    await areas.doc(area.referenceId).update(area.toJson());
  }

  void incrementAreaRouteCount(String venueId, String areaId) async {
    FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .get()
        .then((querySnapshot) {
      Area area = Area.fromSnapshot(querySnapshot);
      area.routeCount += 1;
      updateArea(venueId, area);
    });
  }

  Future<DocumentReference> addVenue(Venue venue) {
    final CollectionReference venues =
        FirebaseFirestore.instance.collection('venues');
    return venues.add(venue.toJson());
  }

  void updateVenue(Venue venue) async {
    final CollectionReference venues =
        FirebaseFirestore.instance.collection('venues');
    await venues.doc(venue.referenceId).update(venue.toJson());
  }

  void deleteVenue(Venue venue) async {
    final CollectionReference venues =
        FirebaseFirestore.instance.collection('venues');
    await venues.doc(venue.referenceId).delete();
  }
}
