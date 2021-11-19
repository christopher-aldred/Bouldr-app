// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:bouldr/pages/area_page.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AreaList extends StatelessWidget {
  final String venueId;
  final db = FirebaseFirestore.instance;
  AreaList(this.venueId);
  late BuildContext localContext;
  final DataRepository dr = DataRepository();

  void optionsDialogue(
      {required String id,
      required String areaName,
      required String createdBy}) {
    FirebaseFirestore.instance
        .collection("/users")
        .doc(createdBy)
        .get()
        .then((data) => {
              showDialog(
                  context: localContext,
                  builder: (context) {
                    if (AuthenticationHelper().user == null) {
                      return AlertDialog(
                        title: Text(areaName, textAlign: TextAlign.center),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Created by: ' + data['displayName'])
                          ],
                        ),
                      );
                    } else {
                      return AlertDialog(
                        title: Text(areaName, textAlign: TextAlign.center),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Created by: ' + data['displayName']),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                child:
                                    createdBy == AuthenticationHelper().user.uid
                                        ? ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              dr.deleteArea(venueId, id);
                                            },
                                            child: Text('Delete area'))
                                        : ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              // Report Route
                                            },
                                            child: Text('Report area')))
                          ],
                        ),
                      );
                    }
                  })
            });
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;
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
                  onLongPress: () => {
                    optionsDialogue(
                        id: area.id,
                        areaName: area['name'],
                        createdBy: area['createdBy'])
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
