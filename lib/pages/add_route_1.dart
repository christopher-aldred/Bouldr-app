// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/grade.dart';
import 'package:bouldr/pages/add_route_2.dart';
import 'package:bouldr/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  @override
  Widget build(BuildContext context) {
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
            child: DropdownButton<String>(
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
              items: grade.gradeMatrix[1]
                  .toSet()
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () => {
          if (textControllerName.text != "" &&
              dropdownValue.toLowerCase() != "select grade")
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddRoute2(
                          widget.venueId,
                          widget.areaId,
                          widget.sectionId,
                          textControllerName.text.toString(),
                          textControllerDescription.text.toString(),
                          dropdownValue))),
              FocusScope.of(context).unfocus()
            }
          else
            {
              Fluttertoast.showToast(
                msg: "Must enter name & grade",
              )
            }
        },
        label: Text('Next'),
        icon: Icon(Icons.check),
      ),
    );
  }
}
