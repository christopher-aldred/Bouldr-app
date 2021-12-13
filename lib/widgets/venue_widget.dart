// ignore_for_file: prefer_const_constructors

import 'package:bouldr/pages/add_venue.dart';
import 'package:bouldr/pages/search_page.dart';
import 'package:bouldr/repository/data_repository.dart';
import 'package:bouldr/utils/authentication.dart';
import 'package:bouldr/widgets/venue_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class VenueWidget extends StatefulWidget {
  String? searchText;
  VenueWidget([this.searchText]);

  @override
  _VenueWidgetState createState() => _VenueWidgetState();
}

class _VenueWidgetState extends State<VenueWidget> {
  final TextEditingController textController = TextEditingController();
  final Location location = Location();
  DataRepository dr = DataRepository();

  void search(String searchText) async {
    if (searchText != "") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SearchPage(searchText)));
      await Future.delayed(Duration(seconds: 1));
      textController.text = "";
      //FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              padding:
                  EdgeInsets.only(top: 5.0, right: 0.0, left: 0.0, bottom: 0.0),
              child: Card(
                child: TextField(
                  controller: textController,
                  textCapitalization: TextCapitalization.words,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    isCollapsed: true,
                    hintText: 'Search',
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 5)),
                  ),
                  onSubmitted: search,
                ),
              ),
            ),
            Expanded(
              child: VenueList(),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.green,
            onPressed: () => {
                  if (AuthenticationHelper().user != null)
                    {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddVenue()))
                    }
                  else
                    {
                      Fluttertoast.showToast(
                        msg: "Must be logged in to perform this action",
                      ),
                      AuthenticationHelper().loginDialogue(context)
                    }
                },
            label: Text('Add location'),
            icon: Icon(Icons.location_on)));
  }
}
