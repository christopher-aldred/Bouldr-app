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
  late SharedPreferences prefs;
  late List<dynamic> gradeCount;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('venues')
            .doc(widget.venueId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading");
          }

          try {
            gradeCount = snapshot.data!['grades'];
          } catch (e) {
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
                                if (prefs.getString('gradingScale') == "v") {
                                  return 'VB - V0';
                                }
                                if (prefs.getString('gradingScale') == "f") {
                                  return 'f3 - f4';
                                }
                                return "";

                              case 1:
                                if (prefs.getString('gradingScale') == "v") {
                                  return 'V1 - V2';
                                }
                                if (prefs.getString('gradingScale') == "f") {
                                  return 'f4 - f5';
                                }
                                return "";
                              case 2:
                                if (prefs.getString('gradingScale') == "v") {
                                  return 'V3 - V5';
                                }
                                if (prefs.getString('gradingScale') == "f") {
                                  return 'f6A - f6C';
                                }
                                return "";
                              case 3:
                                if (prefs.getString('gradingScale') == "v") {
                                  return 'V6 - V10';
                                }
                                if (prefs.getString('gradingScale') == "f") {
                                  return 'f7A - f7C';
                                }
                                return "";
                              case 4:
                                if (prefs.getString('gradingScale') == "v") {
                                  return 'V11+';
                                }
                                if (prefs.getString('gradingScale') == "f") {
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
