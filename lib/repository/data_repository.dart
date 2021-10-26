import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/venue.dart';

class DataRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('venues');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> addVenue(Venue venue) {
    return collection.add(venue.toJson());
  }

  void updateVenue(Venue venue) async {
    await collection.doc(venue.referenceId).update(venue.toJson());
  }

  void deleteVenue(Venue venue) async {
    await collection.doc(venue.referenceId).delete();
  }
}
