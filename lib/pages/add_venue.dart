// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:io';
import 'dart:typed_data';
import 'package:bouldr/models/venue.dart';
import 'package:bouldr/pages/home_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/widgets/map_picker.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import 'package:image/image.dart' as img;

class AddVenue extends StatefulWidget {
  const AddVenue({Key? key}) : super(key: key);

  @override
  _AddVenueState createState() => _AddVenueState();
}

class _AddVenueState extends State<AddVenue> {
  final TextEditingController textControllerName = TextEditingController();
  final TextEditingController textControllerDescription =
      TextEditingController();

  LatLng? chosenLocation;
  File? imageFile;

  Location location = Location();
  DataRepository dr = DataRepository();
  late LocationData _pos;

  String _dropDownValue = "";

  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (AuthenticationHelper().user == null) {
      Navigator.pop(context);
    }
    getLocation();
  }

  void _showMaterialDialog() {
    FocusScope.of(context).unfocus();
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

  _getFromGallery() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 25);

    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  _getFromCamera() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 25);

    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  void getLocation() async {
    _pos = await location.getLocation();
  }

  /*
  void uploadImage(Venue newVenue) async {
    final imageData = imageFile!.readAsBytesSync();

    String filePath =
        "/images/" + newVenue.referenceId.toString() + "/venue_image.png";

    try {
      var storageimage = FirebaseStorage.instance.ref().child(filePath);
      UploadTask task1 = storageimage.putData(imageData);

      Future<String> url = (await task1).ref.getDownloadURL();
      url.then((value) => {
            {newVenue.imagePath = value},
            dr.updateVenue(newVenue),
            Navigator.of(context).pop(),
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        VenuePage(newVenue.referenceId.toString())))
          });
    } on FirebaseException catch (error) {
      print(error);
    }
  }
  */

  Future<void> save() async {
    if (chosenLocation == null ||
        _dropDownValue == "" ||
        textControllerName.text == "" ||
        AuthenticationHelper().user == null) return;

    setState(() {
      saving = true;
    });

    int? venueType;

    Venue? newVenue;

    if (_dropDownValue == 'Indoor') {
      venueType = 1;
    } else if (_dropDownValue == 'Outdoor') {
      venueType = 0;
    }

    if (textControllerDescription.text == "") {
      newVenue = Venue(textControllerName.text, chosenLocation!, venueType!,
          AuthenticationHelper().user.uid);
    } else {
      newVenue = Venue(textControllerName.text, chosenLocation!, venueType!,
          AuthenticationHelper().user.uid, textControllerDescription.text);
    }

    final imageFuture = imageFile!.readAsBytesSync();
    var finalImage = await FlutterImageCompress.compressWithList(
      imageFuture,
      quality: 75,
    );

    Future<DocumentReference> response =
        dr.addVenue(newVenue, context, finalImage);

    /*
    response.then((value) => {
          newVenue!.referenceId = value.id,
          if (imageFile == null)
            {
              Navigator.of(context).pop(),
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomePage(context))),
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VenuePage(newVenue!.referenceId.toString())))
            },
          if (imageFile != null) {uploadImage(newVenue)},
        });
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add venue'),
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
        body: Stack(
          children: <Widget>[
            Column(
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
                            borderSide:
                                BorderSide(color: Colors.black, width: 5)),
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
                            borderSide:
                                BorderSide(color: Colors.black, width: 5)),
                      ),
                      onSubmitted: (text) => {}),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: DropdownButton(
                    hint: _dropDownValue == ""
                        ? Text('Select venue type')
                        : Text(_dropDownValue),
                    isExpanded: true,
                    iconSize: 30.0,
                    items: ['Indoor', 'Outdoor'].map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      setState(
                        () {
                          _dropDownValue = val.toString();
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity, // <-- match_parent
                    child: ElevatedButton.icon(
                      onPressed: _showMaterialDialog,
                      icon: Icon(Icons.photo),
                      label: Text('Choose image'),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          textStyle: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity, // <-- match_parent
                    child: ElevatedButton.icon(
                      onPressed: () => {
                        FocusScope.of(context).unfocus(),
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapPicker(
                                          _pos.latitude!.toDouble(),
                                          _pos.longitude!.toDouble(),
                                        )))
                            .then((value) => {chosenLocation = value as LatLng})
                      },
                      icon: Icon(Icons.location_on),
                      label: Text(
                        'Set location',
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          textStyle: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
                visible: saving,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black.withOpacity(0.75),
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    ),
                  ),
                )),
          ],
        ),
        floatingActionButton: Visibility(
            visible: !saving,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.green,
              onPressed: () => {
                if (textControllerName.text != "" &&
                    chosenLocation != null &&
                    _dropDownValue != "")
                  {save()}
                else
                  {
                    Fluttertoast.showToast(
                      msg: "Must input name, location & venue type",
                    )
                  }
              },
              label: Text('Save'),
              icon: Icon(Icons.save),
            )));
  }
}
