// ignore_for_file: prefer_const_constructors

import 'package:bouldr/pages/search_page.dart';
import 'package:bouldr/pages/venue_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VenueList extends StatefulWidget {
  const VenueList({Key? key}) : super(key: key);

  @override
  _VenueListState createState() => _VenueListState();
}

class _VenueListState extends State<VenueList>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController textController = TextEditingController();

  void search(String searchText) async {
    if (searchText != "") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SearchPage(searchText)));
      await Future.delayed(Duration(seconds: 1));
      textController.text = "";
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('venues')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(
                    top: 5.0, right: 0.0, left: 0.0, bottom: 0.0),
                child: Card(
                  child: TextField(
                    controller: textController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      isCollapsed: true,
                      hintText: 'Search',
                      border: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 5)),
                    ),
                    onSubmitted: search,
                  ),
                ),
              ),
              Expanded(
                  child: ListView(
                padding: EdgeInsets.all(0.0),
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    child: ListTile(
                      title: Text(doc['name']),
                      subtitle: Text('0 km'),
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VenuePage(doc.id)))
                      },
                    ),
                  );
                }).toList(),
              ))
            ],
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
