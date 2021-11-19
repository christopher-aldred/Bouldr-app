import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _dropDownValue = "";
  late SharedPreferences prefs;

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<String> getGradingScale() async {
    prefs = await SharedPreferences.getInstance();
    var defaultHomeTab = prefs.getString('gradingScale');
    return Future.value(defaultHomeTab);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getGradingScale(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.data == "f") {
            _dropDownValue = "Font";
          } else if (snapshot.data == "v") {
            _dropDownValue = "Vermin (V grade)";
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Settings'),
              actions: <Widget>[],
              backgroundColor: Colors.green,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
            body: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Grading scale')),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: DropdownButton(
                  hint: Text(_dropDownValue),
                  isExpanded: true,
                  iconSize: 30.0,
                  items: ['Font', 'Vermin (V grade)'].map(
                    (val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    },
                  ).toList(),
                  onChanged: (val) {
                    setState(
                      () {
                        _dropDownValue = val.toString();
                        if (_dropDownValue == "Font") {
                          prefs.setString('gradingScale', "f");
                        }
                        if (_dropDownValue == "Vermin (V grade)") {
                          prefs.setString('gradingScale', "v");
                        }
                      },
                    );
                  },
                ),
              ),
            ]),
          );
        });

    ;
  }
}
