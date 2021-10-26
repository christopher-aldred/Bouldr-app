import 'package:bouldr/models/route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/venue.dart';

class DataRepository {
  final CollectionReference venues =
      FirebaseFirestore.instance.collection('venues');

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

  Future<DocumentReference> addVenue(Venue venue) {
    return venues.add(venue.toJson());
  }

  void updateVenue(Venue venue) async {
    await venues.doc(venue.referenceId).update(venue.toJson());
  }

  void deleteVenue(Venue venue) async {
    await venues.doc(venue.referenceId).delete();
  }
}
