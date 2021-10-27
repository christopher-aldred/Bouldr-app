// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bouldr/models/grade.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  String dropdownValue = 'Select grade';

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
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          onPressed: () => {
            if (textControllerName.text != "" &&
                dropdownValue.toLowerCase() != "select grade")
              {
                //to-do
              }
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
