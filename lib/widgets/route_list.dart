// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:bouldr/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/grade.dart';

class RouteList extends StatefulWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  final db = FirebaseFirestore.instance;
  final Grade grade = Grade();
  Function(String) callBack;
  RouteList(this.venueId, this.areaId, this.sectionId, this.callBack);

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.db
          .collection('venues')
          .doc(widget.venueId)
          .collection('areas')
          .doc(widget.areaId)
          .collection('sections')
          .doc(widget.sectionId)
          .collection('routes')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
              padding: EdgeInsets.all(0.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var route = snapshot.data!.docs[index];
                return Card(
                    color: index == selectedIndex
                        ? HexColor('e0e0e0')
                        : Colors.white,
                    child: ListTile(
                      title: Text(
                        route['name'],
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: index == selectedIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text("Grade: " +
                          widget.grade.getGradeByIndex(route['grade'], 'f')),
                      onTap: () => {
                        widget.callBack(route.id),
                        setState(() {
                          selectedIndex = index;
                        })
                      },
                    ));
              });
        }
      },
    );
  }
}
