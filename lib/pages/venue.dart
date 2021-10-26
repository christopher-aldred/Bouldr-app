import 'package:flutter/material.dart';

class VenuePage extends StatefulWidget {
  final String venueName;
  const VenuePage(this.venueName, {Key? key}) : super(key: key);

  @override
  _VenuePageState createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.venueName),
          backgroundColor: Colors.green,
        ),
        body: null,
      ),
    );
  }
}
