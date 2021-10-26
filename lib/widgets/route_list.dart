// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/grade.dart';

class RouteList extends StatelessWidget {
  final String venueId;
  final String areaId;
  final String sectionId;
  final db = FirebaseFirestore.instance;
  final Grade grade = Grade();
  RouteList(this.venueId, this.areaId, this.sectionId);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('venues')
          .doc(venueId)
          .collection('areas')
          .doc(areaId)
          .collection('sections')
          .doc(sectionId)
          .collection('routes')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView(
            padding: EdgeInsets.all(0),
            children: snapshot.data!.docs.map((route) {
              return Card(
                child: ListTile(
                  title: Text(route['name']),
                  subtitle: Text(
                      "Grade: " + grade.getGradeByIndex(route['grade'], 'f')),
                  onTap: () => {
                    /*
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AreaPage(venueId, area.id)))
                            */
                  },
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
