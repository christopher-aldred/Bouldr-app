import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final String search;
  const SearchPage(this.search, {Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.green,
      ),
      body: Text(widget.search),
    );
  }
}
