import 'package:flutter/material.dart';

class Grade {
  List gradeMatrix = [
    [
      "Select grade", // 0
      "3", // 1
      "4", // 2
      "5", // 3
      "5+", // 4
      "6a", // 5
      "6a+", // 6
      "6b", // 7
      "6b+", // 8
      "6c", // 9
    ],
    [
      "Select grade", // 0
      "VB", // 1
      "V0", // 2
      "V1", // 3
      "V2", // 4
      "V3", // 5
      "V3", // 6
      "V4", // 7
      "V4", // 8
      "V5", // 9
      "V6", // 10
      "V7", // 11
      "V8", // 12
      "V9", // 13
      "V10", // 14
      "V11", // 15
      "V12", // 16
      "V13", // 17
      "V14", // 18
      "V15", // 19
      "V16", // 20
      "V17", // 21
    ]
  ];

  String getGradeByIndex(int input, String type) {
    if (type == "f") {
      return gradeMatrix[0][input];
    }
    if (type == "v") {
      return gradeMatrix[1][input];
    }
    return "Error";
  }

  Grade();
}
