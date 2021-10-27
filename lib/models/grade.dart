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
