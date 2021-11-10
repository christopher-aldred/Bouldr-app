// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'dart:typed_data';

import 'package:bouldr/models/grade.dart';
import 'package:bouldr/models/section.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class AddSection extends StatefulWidget {
  final String venueId;
  final String areaId;
  const AddSection(this.venueId, this.areaId, {Key? key}) : super(key: key);

  @override
  _AddSectionState createState() => _AddSectionState();
}

class _AddSectionState extends State<AddSection> {
  Grade grade = Grade();
  final TextEditingController textControllerName = TextEditingController();
  final TextEditingController textControllerDescription =
      TextEditingController();
  File? imageFile;
  DataRepository dr = DataRepository();

  void _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select image'),
            content: null,
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    _getFromGallery();
                    Navigator.pop(context);
                  },
                  child: Text('Gallery')),
              TextButton(
                onPressed: () {
                  _getFromCamera();
                  Navigator.pop(context);
                },
                child: Text('Camera'),
              )
            ],
          );
        });
  }

  /*
  /// Get from gallery
  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
  */

  _getFromGallery() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 25);

    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 25);

    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  void uploadImage(Section newSection) async {
    final imageFuture = imageFile!.readAsBytesSync();

    img.Image? imageTemp = img.decodeImage(imageFuture);
    img.Image resizedImg = img.copyResizeCropSquare(imageTemp!, 1000);
    final uploadImage =
        Uint8List.fromList(img.JpegEncoder().encodeImage(resizedImg));

    String filePath = "/images/" +
        widget.venueId +
        "/" +
        newSection.referenceId.toString() +
        "/base_image.png";

    try {
      var storageimage = FirebaseStorage.instance.ref().child(filePath);
      UploadTask task1 = storageimage.putData(uploadImage);

      Future<String> url = (await task1).ref.getDownloadURL();
      url.then((value) => {
            {newSection.imagePath = value},
            dr.updateSection(widget.venueId, widget.areaId, newSection)
          });
      Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      print(error);
    }
  }

  Future<void> save() async {
    if (imageFile == null) return;

    Section newSection = Section(textControllerName.text, '');

    Future<DocumentReference> response =
        dr.addSection(widget.venueId, widget.areaId, newSection);

    response.then((value) => {
          newSection.referenceId = value.id,
          uploadImage(newSection),
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add section'),
          actions: <Widget>[],
          backgroundColor: Colors.green,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                  autofocus: true,
                  controller: textControllerName,
                  textAlignVertical: TextAlignVertical.center,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 5)),
                  ),
                  onSubmitted: (text) => {}),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                  controller: textControllerDescription,
                  textAlignVertical: TextAlignVertical.center,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 5)),
                  ),
                  onSubmitted: (text) => {}),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                  width: double.infinity, // <-- match_parent
                  child: ElevatedButton(
                    child: Text('Select image'),
                    onPressed: _showMaterialDialog,
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 20)),
                  )),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          onPressed: () => {
            if (textControllerName.text != "" && imageFile != null)
              {save()}
            else
              {
                Fluttertoast.showToast(
                  msg: "Must input name & image",
                )
              }
          },
          label: Text('Save'),
          icon: Icon(Icons.save),
        ),
      ),
    );
  }
}
