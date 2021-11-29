import 'dart:typed_data';
import 'package:bouldr/models/area.dart';
import 'package:bouldr/models/section.dart';
import 'package:bouldr/pages/area_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:bouldr/models/route.dart' as custom_route;

import '../models/venue.dart';

class DataRepository {
  Future<DocumentReference> addRoute(
      String venueId,
      String areaId,
      String sectionId,
      custom_route.Route route,
      Uint8List routeImage,
      var context) {
    final CollectionReference routes = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections')
        .doc(sectionId)
        .collection('routes');
    var result = routes.add(route.toJson());

    String filePath;
    var storageImage;
    UploadTask task1;
    Future<String> url;

    result.then((value) async => {
          route.referenceId = value.id,
          filePath = "/images/" +
              venueId +
              "/" +
              sectionId +
              "/" +
              route.referenceId.toString() +
              ".png",
          storageImage = FirebaseStorage.instance.ref().child(filePath),
          task1 = storageImage.putData(routeImage),
          url = (await task1).ref.getDownloadURL(),
          url.then((value) => {
                {route.imagePath = value},
                updateRoute(venueId, areaId, sectionId, route, context)
              })
        });
    return result;
  }

  void updateRoute(String venueId, String areaId, String sectionId,
      custom_route.Route route, var context) async {
    final CollectionReference routes = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections')
        .doc(sectionId)
        .collection('routes');
    await routes.doc(route.referenceId).update(route.toJson()).then((value) => {
          incrementAreaRouteCount(venueId, areaId),
          Navigator.of(context).pop(),
          Navigator.of(context).pop(route.referenceId),
          /*
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AreaPage(venueId, areaId),
            ),
          )
          */
          //newRoute.referenceId = value.id,
          //uploadImage(newRoute),
        });
  }

  Future<void> deleteRoute(
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
    return await routes
        .doc(routeId)
        .delete()
        .then((value) => {decrementAreaRouteCount(venueId, areaId)});
  }

  Future<DocumentReference> addSection(String venueId, String areaId,
      Section section, Uint8List imageFile, var context) {
    final CollectionReference sections = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections');
    var result = sections.add(section.toJson());

    String filePath;
    var storageimage;
    UploadTask task1;
    Future<String> url;

    result.then((value) async => {
          section.referenceId = value.id,
          filePath = "/images/" +
              venueId +
              "/" +
              section.referenceId.toString() +
              "/base_image.png",
          storageimage = FirebaseStorage.instance.ref().child(filePath),
          task1 = storageimage.putData(imageFile),
          url = (await task1).ref.getDownloadURL(),
          url.then((value) => {
                {section.imagePath = value},
                updateSection(venueId, areaId, section),
                Navigator.of(context).pop(),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AreaPage(venueId, areaId),
                  ),
                )
              })
        });
    return result;
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
    await sections
        .doc(sectionId)
        .delete()
        .then((value) => {updateUserTimestamp()});
  }

  void updateSection(String venueId, String areaId, Section section) async {
    final CollectionReference sections = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas')
        .doc(areaId)
        .collection('sections');
    await sections
        .doc(section.referenceId)
        .update(section.toJson())
        .then((value) => {updateUserTimestamp()});
  }

  Future<DocumentReference> addArea(String venueId, Area area) {
    final CollectionReference sections = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas');
    var result = sections.add(area.toJson());
    result.then((value) => {updateUserTimestamp()});
    return result;
  }

  void updateArea(String venueId, Area area) async {
    final CollectionReference areas = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('areas');

    await areas
        .doc(area.referenceId)
        .update(area.toJson())
        .then((value) => {updateUserTimestamp()});
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
    await areas.doc(areaId).delete().then((value) => {updateUserTimestamp()});
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

  Future<DocumentReference> addVenue(Venue venue, var context,
      [Uint8List? venueImage]) {
    final CollectionReference venues =
        FirebaseFirestore.instance.collection('venues');
    Future<DocumentReference> result = venues.add(venue.toJson());

    String filePath;
    var storageimage;
    UploadTask task1;
    Future<String> url;

    result.then((value) async => {
          venue.referenceId = value.id,
          if (venueImage == null)
            {
              updateVenue(venue),
              Navigator.of(context).pop(),
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VenuePage(venue.referenceId.toString()))),
              //updateUserTimestamp()
            }
          else
            {
              filePath = "/images/" +
                  venue.referenceId.toString() +
                  "/venue_image.png",
              storageimage = FirebaseStorage.instance.ref().child(filePath),
              task1 = storageimage.putData(venueImage),
              url = (await task1).ref.getDownloadURL(),
              url.then((value) => {
                    {venue.imagePath = value},
                    updateVenue(venue),
                    Navigator.of(context).pop(),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                VenuePage(venue.referenceId.toString()))),
                    //updateUserTimestamp()
                  })
            },
        });
    return result;
  }

  void updateVenue(Venue venue) async {
    final CollectionReference venues =
        FirebaseFirestore.instance.collection('venues');
    await venues
        .doc(venue.referenceId)
        .update(venue.toJson())
        .then((value) => {updateUserTimestamp()});
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
    await venues.doc(venueId).delete().then((value) => {updateUserTimestamp()});
  }

  void addUserDisplayName(String uid, String displayName) {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    users.doc(uid) // <-- Document ID
        .set({
      'displayName': displayName,
      'lastWriteTimestamp': FieldValue.serverTimestamp()
    }).catchError((error) => print('Add failed: $error'));
  }

  void updateUserTimestamp() async {
    //await Future.delayed(Duration(seconds: 1));
    var users = FirebaseFirestore.instance.collection('users');
    users.doc(AuthenticationHelper().user.uid) // <-- Document ID
        .update({
      'lastWriteTimestamp': FieldValue.serverTimestamp()
    }).catchError((error) => print('User timestamp update failed: $error'));
  }

  void deleteFolderContents(path) {
    var ref = FirebaseStorage.instance.ref(path);
    ref.listAll().then((dir) => {
          dir.items
              .forEach((fileRef) => {deleteFile(ref.fullPath, fileRef.name)}),
          dir.prefixes.forEach(
              (folderRef) => {deleteFolderContents(folderRef.fullPath)})
        });
  }

  void deleteFile(pathToFile, fileName) {
    var ref = FirebaseStorage.instance.ref(pathToFile);
    var childRef = ref.child(fileName);
    childRef.delete();
  }
}
