// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/grade.dart';
import 'package:bouldr/pages/add_route_2.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bouldr/models/route.dart' as custom_route;

class AddRoute1 extends StatefulWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  const AddRoute1(this.venueId, this.areaId, this.sectionId, {Key? key})
      : super(key: key);

  @override
  _AddRoute1State createState() => _AddRoute1State();
}

class _AddRoute1State extends State<AddRoute1> {
  Grade grade = Grade();
  final TextEditingController textControllerName = TextEditingController();
  final TextEditingController textControllerDescription =
      TextEditingController();
  String dropdownValue = 'Select grade';
  late SharedPreferences prefs;

  final Grade gradeconversion = Grade();

  bool crimpy = false;
  bool dyno = false;
  bool sitStart = false;
  bool jam = false;

  Future<String> getGradingScale() async {
    prefs = await SharedPreferences.getInstance();
    var defaultHomeTab = prefs.getString('gradingScale');
    return Future.value(defaultHomeTab);
  }

  @override
  void initState() {
    super.initState();
    if (AuthenticationHelper().user == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getGradingScale(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Add route'),
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
                      textCapitalization: TextCapitalization.words,
                      textAlignVertical: TextAlignVertical.center,
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
                  child: DropdownButton<String>(
                    onTap: () => {FocusScope.of(context).unfocus()},
                    isExpanded: true,
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: HexColor("808080")),
                    underline: Container(
                      height: 2,
                      color: Colors.green,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: prefs.getString('gradingScale') == "f"
                        ? grade.gradeMatrix[0]
                            .toSet()
                            .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : grade.gradeMatrix[1]
                            .toSet()
                            .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: CheckboxListTile(
                      title: Text("Sit start"),
                      value: sitStart,
                      onChanged: (newValue) {
                        setState(() {
                          sitStart = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: CheckboxListTile(
                      title: Text("Crimpy"),
                      value: crimpy,
                      onChanged: (newValue) {
                        setState(() {
                          crimpy = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: CheckboxListTile(
                      title: Text("Dyno"),
                      value: dyno,
                      onChanged: (newValue) {
                        setState(() {
                          dyno = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: CheckboxListTile(
                      title: Text("Hand jams"),
                      value: jam,
                      onChanged: (newValue) {
                        setState(() {
                          jam = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    )),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.green,
              onPressed: () => {
                if (textControllerName.text != "" &&
                    textControllerDescription.text != "" &&
                    dropdownValue.toLowerCase() != "select grade")
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddRoute2(
                                  widget.venueId,
                                  widget.areaId,
                                  widget.sectionId,
                                  custom_route.Route(
                                      name: textControllerName.text,
                                      createdBy:
                                          AuthenticationHelper().user.uid,
                                      grade: gradeconversion.getIndexByGrade(
                                          dropdownValue,
                                          prefs
                                              .getString('gradingScale')
                                              .toString()),
                                      description:
                                          textControllerDescription.text,
                                      sitStart: sitStart,
                                      crimpy: crimpy,
                                      dyno: dyno,
                                      jam: jam),
                                ))),
                    FocusScope.of(context).unfocus()
                  }
                else
                  {
                    Fluttertoast.showToast(
                      msg: "Must enter name, grade & description",
                    )
                  }
              },
              label: Text('Next'),
              icon: Icon(Icons.check),
            ),
          );
        });
  }
}
