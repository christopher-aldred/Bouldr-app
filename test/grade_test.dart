import 'package:flutter_test/flutter_test.dart';

import '../lib/models/grade.dart';

void main() {
  test('Counter value should be incremented', () {
    final Grade grade = Grade();

    int response = grade.getIndexByGrade("V4", "v");

    expect(response, 7);
  });
}
