import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _dropDownValue = "";
  late SharedPreferences prefs;
  late PackageInfo packageInfo;

  Future<String> getGradingScale() async {
    prefs = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
    var scale = prefs.getString('gradingScale');
    return Future.value(scale);
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
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Version: ' + packageInfo.version))))
            ]),
          );
        });
  }
}
