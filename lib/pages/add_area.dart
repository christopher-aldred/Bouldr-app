// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:bouldr/models/area.dart';
import 'package:bouldr/models/venue.dart';
import 'package:bouldr/pages/area_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:bouldr/utils/authentication.dart';
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
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (AuthenticationHelper().user == null) {
      Navigator.pop(context);
    }
  }

  Future<void> save() async {
    if (widget.venue.venueType == 1) {
      location = widget.venue.location;
    }

    if (location == null ||
        textControllerName.text == "" ||
        AuthenticationHelper().user == null) return;

    setState(() {
      saving = true;
    });

    Area newArea = Area(textControllerName.text, location!, 0,
        AuthenticationHelper().user.uid, textControllerDescription.text);

    var response = dr.addArea(widget.venue.referenceId.toString(), newArea);

    response.then((value) => {
          newArea.referenceId = value.id,
          Navigator.pop(context),
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VenuePage(widget.venue.referenceId.toString()),
            ),
          ),
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AreaPage(
                  widget.venue.referenceId.toString(),
                  newArea.referenceId.toString()),
            ),
          )
        });
    /*
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VenuePage(widget.venue.referenceId.toString()),
      ),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Visibility(
                    visible: widget.venue.venueType == 0,
                    child: Padding(
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
                    )),
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
              if ((textControllerName.text != "" && location != null) ||
                  (textControllerName.text != "" &&
                      widget.venue.venueType == 1))
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
        ));
  }
}
