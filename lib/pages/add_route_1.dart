// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/grade.dart';
import 'package:bouldr/pages/add_route_2.dart';
import 'package:bouldr/utils/hex_color.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController textControllerName = TextEditingController();
  final TextEditingController textControllerDescription =
      TextEditingController();
  String dropdownSelection = "";

  void goToRouteDraw() {}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                  textAlignVertical: TextAlignVertical.center,
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
                  decoration: InputDecoration(
                    hintText: 'Description',
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 5)),
                  ),
                  onSubmitted: (text) => {}),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: DropdownSelection(dropdownSelection),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddRoute2(
                          widget.venueId,
                          widget.areaId,
                          widget.sectionId,
                          textControllerName.value.toString(),
                          textControllerDescription.value.toString(),
                          dropdownSelection,
                        )))
          },
          label: Text('Next'),
          icon: Icon(Icons.check),
        ),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class DropdownSelection extends StatefulWidget {
  String returnValue;
  DropdownSelection(this.returnValue, {Key? key}) : super(key: key);

  @override
  State<DropdownSelection> createState() => _DropdownSelectionState();
}

/// This is the private State class that goes with DropdownSelection.
class _DropdownSelectionState extends State<DropdownSelection> {
  String dropdownValue = 'Select grade';
  Grade grade = Grade();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
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
          widget.returnValue = newValue;
        });
      },
      items: grade.gradeMatrix[1]
          .toSet()
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
