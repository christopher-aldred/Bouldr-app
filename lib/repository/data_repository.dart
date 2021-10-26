import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/venue.dart';

class DataRepository {
  final CollectionReference venues =
      FirebaseFirestore.instance.collection('venues');

/*
  CollectionReference getVenue(String id) {
    return FirebaseFirestore.instance.collection('venue').doc(id).get().then((value) => null);
  }
*/
  /*
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }
  */

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
