// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:device_info_tool/common/string_extensions.dart';

void main() {
  test('Case 1', () {
    var s1 = "16.1";
    var s2 = "16";
    expect(s1.compareVersion(s2), true);
  });

  test('Case 2', () {
    var s1 = "16.4.1";
    var s2 = "16";
    expect(s1.compareVersion(s2), true);
  });

  test('Case 3', () {
    var s1 = "16";
    var s2 = "16";
    expect(s1.compareVersion(s2), true);
  });

  test('Case 4', () {
    var s1 = "4.4.2";
    var s2 = "4.4.2";
    expect(s1.compareVersion(s2), true);
  });
}
