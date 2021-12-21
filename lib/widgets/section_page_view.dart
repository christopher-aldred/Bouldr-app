// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:bouldr/widgets/section_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

// ignore: must_be_immutable
class SectionPageView extends StatefulWidget {
  final String venueId;
  final String areaId;
  String? sectionId;
  String? routeId;
  final Function(String) onSectionChanged;

  SectionPageView(this.venueId, this.areaId,
      {required this.onSectionChanged, this.sectionId, this.routeId});

  @override
  _SectionPageViewState createState() => _SectionPageViewState();
}

class _SectionPageViewState extends State<SectionPageView> {
  late PreloadPageController? controller;

  @override
  void initState() {
    super.initState();
    controller = PreloadPageController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .collection('areas')
          .doc(widget.areaId)
          .collection('sections')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          widget.onSectionChanged(snapshot.data!.docs[0].id);
          return PreloadPageView.builder(
            onPageChanged: (index) =>
                {widget.onSectionChanged(snapshot.data!.docs[index].id)},
            controller: controller,
            itemBuilder: (context, position) {
              if (widget.sectionId != null) {
                if (widget.sectionId == snapshot.data!.docs[position].id) {
                  Future.delayed(Duration(milliseconds: 100), () {
                    controller!.animateToPage(position,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.ease);
                  });
                }
              }
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
                  widget.venueId,
                  widget.areaId,
                  snapshot.data!.docs[position].id.toString(),
                  routeId: widget.routeId,
                )),
              ]);
            },
            itemCount: snapshot.data!.docs.length, // Can be null
          );
        }
      },
    );
  }
}
