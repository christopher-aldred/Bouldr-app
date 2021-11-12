// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:bouldr/models/area.dart';
import 'package:bouldr/models/venue.dart';
import 'package:bouldr/widgets/map_picker.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddArea extends StatefulWidget {
  final Venue venue;
  const AddArea(this.venue, {Key? key}) : super(key: key);

  @override
  _AddAreaState createState() => _AddAreaState();
}

class _AddAreaState extends State<AddArea> {
  final TextEditingController textControllerName = TextEditingController();
  final TextEditingController textControllerDescription =
      TextEditingController();
  LatLng? location;
  DataRepository dr = DataRepository();

  Future<void> save() async {
    if (location == null) return;

    Area newArea = Area(
        textControllerName.text, location!, 0, textControllerDescription.text);

    dr.addArea(widget.venue.referenceId.toString(), newArea);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add area'),
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
                    child: Text('Set location'),
                    onPressed: () => {
                      FocusScope.of(context).unfocus(),
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapPicker(
                                        widget.venue.location.latitude,
                                        widget.venue.location.longitude,
                                      )))
                          .then((value) => {location = value as LatLng})
                    },
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
            if (textControllerName.text != "" && location != null)
              {save()}
            else
              {
                Fluttertoast.showToast(
                  msg: "Must input name & location",
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
