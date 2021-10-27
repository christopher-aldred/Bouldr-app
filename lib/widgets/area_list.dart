// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:bouldr/pages/area_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AreaList extends StatelessWidget {
  final String venueId;
  final db = FirebaseFirestore.instance;
  AreaList(this.venueId);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('venues')
          .doc(venueId)
          .collection('areas')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView(
            children: snapshot.data!.docs.map((area) {
              //print(snapshot.data!.docs.length);
              return Card(
                child: ListTile(
                  title: Text(area['name']),
                  subtitle: Text(area['routeCount'].toString() + ' routes'),
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AreaPage(venueId, area.id)))
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
