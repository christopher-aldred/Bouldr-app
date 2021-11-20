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
      "6c+", // 10
      "7a", // 11
      "7a+", // 12
      "7b", // 13
      "7b+", // 14
      "7c", // 15
      "7c+", // 16
      "8a", // 17
      "8a+", // 18
      "8b", // 19
      "8b+", // 20
      "8c", // 21
      "8c+", // 22
      "9a", // 23
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
      "V5", // 10
      "V6", // 11
      "V7", // 12
      "V8", // 13
      "V9", // 14
      "V9", // 15
      "V10", // 16
      "V11", // 17
      "V12", // 18
      "V13", // 19
      "V14", // 20
      "V15", // 21
      "V16", // 22
      "V17", // 23
    ]
  ];

  String getGradeByIndex(int input, String type) {
    if (input == -1) {
      return "Error";
    }
    if (type == "f") {
      return gradeMatrix[0][input];
    }
    if (type == "v") {
      return gradeMatrix[1][input];
    }
    return "Error";
  }

  int getIndexByGrade(String input, String type) {
    int output = -1;
    List<String> grades = [];

    if (type == "f") {
      grades = gradeMatrix[0];
    }

    if (type == "v") {
      grades = gradeMatrix[1];
    }

    for (var j = 0; j < grades.length; j++) {
      if (grades[j] == input) {
        output = j;
        break;
      }
    }

    return output;
  }

  Grade();
}
