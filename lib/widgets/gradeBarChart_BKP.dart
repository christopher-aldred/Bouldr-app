import 'package:bouldr/utils/hex_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class GradeBarChart extends StatefulWidget {
  String venueId;

  GradeBarChart(this.venueId);

  @override
  _GradeBarChartState createState() => _GradeBarChartState();
}

class _GradeBarChartState extends State<GradeBarChart> {
  List<int> gradeCount = [0, 0, 0, 0, 0];
  late SharedPreferences prefs;

  bool noRoutes() {
    int routeCount = 0;
    routeCount += gradeCount[0] +
        gradeCount[1] +
        gradeCount[2] +
        gradeCount[3] +
        gradeCount[4];
    return routeCount == 0;
  }

  void getCachedGrades() async {
    prefs = await SharedPreferences.getInstance();
    List<int> grades = [0, 0, 0, 0, 0];
    List<String>? gradesString =
        prefs.getStringList('grades:' + widget.venueId);
    if (gradesString != null) {
      grades[0] = int.parse(gradesString[0]);
      grades[1] = int.parse(gradesString[1]);
      grades[2] = int.parse(gradesString[2]);
      grades[3] = int.parse(gradesString[3]);
      grades[4] = int.parse(gradesString[4]);
    }

    gradeCount = grades;
  }

  @override
  void initState() {
    super.initState();
    getCachedGrades();
    updateGrades();
  }

  void setCachedGrades(List<int> gradeCount) {
    List<String> grades = ["", "", "", "", ""];
    grades[0] = gradeCount[0].toString();
    grades[1] = gradeCount[1].toString();
    grades[2] = gradeCount[2].toString();
    grades[3] = gradeCount[3].toString();
    grades[4] = gradeCount[4].toString();
    prefs.setStringList('grades:' + widget.venueId, grades);
  }

  void updateGrades() async {
    List<int> grades = [0, 0, 0, 0, 0];

    var areas = await FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.venueId)
        .collection('areas')
        .get();

    for (int areaIndex = 0; areaIndex < areas.docs.length; areaIndex++) {
      var sections = await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .collection('areas')
          .doc(areas.docs.elementAt(areaIndex).id)
          .collection('sections')
          .get();

      for (int sectionIndex = 0;
          sectionIndex < sections.docs.length;
          sectionIndex++) {
        var routes = await FirebaseFirestore.instance
            .collection('venues')
            .doc(widget.venueId)
            .collection('areas')
            .doc(areas.docs.elementAt(areaIndex).id)
            .collection('sections')
            .doc(sections.docs.elementAt(sectionIndex).id)
            .collection('routes')
            .get();

        for (int routeIndex = 0;
            routeIndex < routes.docs.length;
            routeIndex++) {
          var route = await FirebaseFirestore.instance
              .collection('venues')
              .doc(widget.venueId)
              .collection('areas')
              .doc(areas.docs.elementAt(areaIndex).id)
              .collection('sections')
              .doc(sections.docs.elementAt(sectionIndex).id)
              .collection('routes')
              .doc(routes.docs.elementAt(routeIndex).id)
              .get();

          if (route['grade'] <= 2) {
            grades[0] += 1;
          }
          if (route['grade'] > 2 && route['grade'] <= 4) {
            grades[1] += 1;
          }
          if (route['grade'] > 4 && route['grade'] <= 10) {
            grades[2] += 1;
          }
          if (route['grade'] > 10 && route['grade'] <= 16) {
            grades[3] += 1;
          }
          if (route['grade'] > 16) {
            grades[4] += 1;
          }
        }
      }
    }
    setState(() {
      gradeCount = grades;
    });
    setCachedGrades(grades);
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
          if (noRoutes()) {
            return Text('No routes');
          }
          return AspectRatio(
              aspectRatio: 3,
              child: Stack(children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      barTouchData: barTouchData,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (context, value) => TextStyle(
                            color: HexColor('525252'),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          margin: 5,
                          getTitles: (double value) {
                            switch (value.toInt()) {
                              case 0:
                                if (snapshot.data == "v") {
                                  return 'VB - V0';
                                }
                                if (snapshot.data == "f") {
                                  return 'f3 - f4';
                                }
                                return "";

                              case 1:
                                if (snapshot.data == "v") {
                                  return 'V1 - V2';
                                }
                                if (snapshot.data == "f") {
                                  return 'f4 - f5';
                                }
                                return "";
                              case 2:
                                if (snapshot.data == "v") {
                                  return 'V3 - V5';
                                }
                                if (snapshot.data == "f") {
                                  return 'f6A - f6C';
                                }
                                return "";
                              case 3:
                                if (snapshot.data == "v") {
                                  return 'V6 - V10';
                                }
                                if (snapshot.data == "f") {
                                  return 'f7A - f7C';
                                }
                                return "";
                              case 4:
                                if (snapshot.data == "v") {
                                  return 'V11+';
                                }
                                if (snapshot.data == "f") {
                                  return 'f8A+';
                                }
                                return "";
                              default:
                                return '';
                            }
                          },
                        ),
                        leftTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(showTitles: false),
                      ),
                      borderData: borderData,
                      barGroups: barGroups,
                      alignment: BarChartAlignment.spaceAround,
                    ),
                  ),
                )
              ]));
        });
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 0,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.y.round().toString(),
              TextStyle(
                color: HexColor('525252'),
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
                width: 20,
                y: gradeCount[0].toDouble(),
                colors: [Colors.green, Colors.greenAccent])
          ],
          //showingTooltipIndicators: gradeCount[0] == 0 ? null : [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
                width: 20,
                y: gradeCount[1].toDouble(),
                colors: [Colors.yellow, Colors.yellowAccent])
          ],
          //showingTooltipIndicators: gradeCount[1] == 0 ? null : [0],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
                width: 20,
                y: gradeCount[2].toDouble(),
                colors: [Colors.orange, Colors.yellow])
          ],
          //showingTooltipIndicators: gradeCount[2] == 0 ? null : [0],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
                width: 20,
                y: gradeCount[3].toDouble(),
                colors: [Colors.red, HexColor('ffadc2')])
          ],
          //showingTooltipIndicators: gradeCount[3] == 0 ? null : [0],
        ),
        BarChartGroupData(
          x: 4,
          barRods: [
            BarChartRodData(
                width: 20,
                y: gradeCount[4].toDouble(),
                colors: [Colors.black, Colors.grey])
          ],
          //showingTooltipIndicators: gradeCount[4] == 0 ? null : [0],
        )
      ];
}
