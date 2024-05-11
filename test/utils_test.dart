import 'package:device_info_tool/common/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('1080, 2340 (19.5:9)', () {
    expect(Utils.getScreenRatio(1080, 2340), '19.5:9.0');
  });

  test('2340, 1080 (19.5:9)', () {
    expect(Utils.getScreenRatio(2340, 1080), '19.5:9.0');
  });

  test('2560, 1080', () {
    expect(Utils.getScreenRatio(2560, 1080), '21.3:9.0');
  });

  test('1600, 900 (16:9)', () {
    expect(Utils.getScreenRatio(1600, 900), '16.0:9.0');
  });

  test('1366, 768 (≈ 16:9)', () {
    expect(Utils.getScreenRatio(1366, 768), '16.0:9.0');
  });

  test('1600, 1200 (4:3)', () {
    expect(Utils.getScreenRatio(1600, 1200), '4.0:3.0');
  });

  test('1680, 1050 (16:10)', () {
    expect(Utils.getScreenRatio(1680, 1050), '16.0:10.0');
  });

  test('1280, 1024 (5:4', () {
    expect(Utils.getScreenRatio(1280, 1024), '5.0:4.0');
  });

  test('720, 480 (3:2)', () {
    expect(Utils.getScreenRatio(720, 480), '3.0:2.0');
  });

  test('1179, 2556 (19.5:9)', () {
    expect(Utils.getScreenRatio(1179, 2556), '19.5:9.0');
  });
}
