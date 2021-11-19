import 'package:bouldr/models/area.dart';
import 'package:bouldr/models/route.dart';
import 'package:bouldr/models/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    incrementAreaRouteCount(venueId, areaId);
    return routes.add(route.toJson());
  }

  void addUserDisplayName(String uid, String displayName) {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    users.doc(uid) // <-- Document ID
        .set({'displayName': displayName}).catchError(
            (error) => print('Add failed: $error'));
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

  void deleteRoute(
      String venueId, String areaId, String sectionId, String routeId) async {
    String filePath =
        "/images/" + venueId + "/" + sectionId + "/" + routeId + ".png";
    FirebaseStorage.instance
        .ref()
        .child(filePath)
        .delete()
        .then((_) => print('Successfully deleted $filePath storage item'));
    final CollectionReference routes = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections')
        .doc(sectionId)
        .collection('routes');
    decrementAreaRouteCount(venueId, areaId);
    await routes.doc(routeId).delete();
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

  void deleteSection(String venueId, String areaId, String sectionId) async {
    String filePath = "/images/" + venueId + "/" + sectionId + "/";
    deleteFolderContents(filePath);
    final CollectionReference sections = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections');
    await sections.doc(sectionId).delete();
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

  void deleteArea(String venueId, String areaId) async {
    FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections')
        .snapshots()
        .forEach((element) {
      for (QueryDocumentSnapshot snapshot in element.docs) {
        snapshot.reference.delete();
      }
    });

    final CollectionReference areas = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas');
    await areas.doc(areaId).delete();
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

  void decrementAreaRouteCount(String venueId, String areaId) async {
    FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .get()
        .then((querySnapshot) {
      Area area = Area.fromSnapshot(querySnapshot);
      area.routeCount -= 1;
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

  void deleteVenue(String venueId) async {
    String filePath = "/images/" + venueId + "/";
    deleteFolderContents(filePath);

    FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .snapshots()
        .forEach((element) {
      for (QueryDocumentSnapshot snapshot in element.docs) {
        snapshot.reference.delete();
      }
    });

    final CollectionReference venues =
        FirebaseFirestore.instance.collection('venues');
    await venues.doc(venueId).delete();
  }
}

void deleteFolderContents(path) {
  var ref = FirebaseStorage.instance.ref(path);
  ref.listAll().then((dir) => {
        dir.items
            .forEach((fileRef) => {deleteFile(ref.fullPath, fileRef.name)}),
        dir.prefixes
            .forEach((folderRef) => {deleteFolderContents(folderRef.fullPath)})
      });
}

void deleteFile(pathToFile, fileName) {
  var ref = FirebaseStorage.instance.ref(pathToFile);
  var childRef = ref.child(fileName);
  childRef.delete();
}
