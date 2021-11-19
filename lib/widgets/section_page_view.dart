// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:bouldr/widgets/section_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

class SectionPageView extends StatelessWidget {
  final String venueId;
  final String areaId;
  final db = FirebaseFirestore.instance;
  SectionPageView(this.venueId, this.areaId);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('venues')
          .doc(venueId)
          .collection('areas')
          .doc(areaId)
          .collection('sections')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return PreloadPageView.builder(
            itemBuilder: (context, position) {
              return Column(children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                      (position + 1).toString() +
                          ' / ' +
                          snapshot.data!.docs.length.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                Expanded(
                    child: SectionWidget(
                  venueId,
                  areaId,
                  snapshot.data!.docs[position].id.toString(),
                ))
              ]);
            },
            itemCount: snapshot.data!.docs.length, // Can be null
          );
        }
      },
    );
  }
}
