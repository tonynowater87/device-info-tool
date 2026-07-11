import 'package:device_info_tool/common/android_version_doc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = 'https://developer.android.com/about/versions';

  group('Android 5.x (android-5.0 格式，不含代號)', () {
    test('5.0', () {
      expect(AndroidVersionDoc.urlFor('5.0', 'Lollipop'), '$base/android-5.0');
    });
    test('5.0.2 收斂到 5.0', () {
      expect(
          AndroidVersionDoc.urlFor('5.0.2', 'Lollipop'), '$base/android-5.0');
    });
    test('5.1.1 收斂到 5.1', () {
      expect(
          AndroidVersionDoc.urlFor('5.1.1', 'Lollipop'), '$base/android-5.1');
    });
  });

  group('Android 6–9 (代號/android-X.0 格式)', () {
    test('6.0.1 -> marshmallow/android-6.0', () {
      expect(AndroidVersionDoc.urlFor('6.0.1', 'Marshmallow'),
          '$base/marshmallow/android-6.0');
    });
    test('7.1.2 -> nougat/android-7.1', () {
      expect(AndroidVersionDoc.urlFor('7.1.2', 'Nougat'),
          '$base/nougat/android-7.1');
    });
    test('8.1.0 -> oreo/android-8.1', () {
      expect(
          AndroidVersionDoc.urlFor('8.1.0', 'Oreo'), '$base/oreo/android-8.1');
    });
    test('9 (無小版號) -> pie/android-9.0', () {
      expect(AndroidVersionDoc.urlFor('9', 'Pie'), '$base/pie/android-9.0');
    });
  });

  group('Android 10+ (純數字格式)', () {
    test('10', () {
      expect(AndroidVersionDoc.urlFor('10', 'Q'), '$base/10');
    });
    test('16', () {
      expect(AndroidVersionDoc.urlFor('16', 'Baklava (QPR2)'), '$base/16');
    });
    test('12L 保留 L 後綴', () {
      expect(AndroidVersionDoc.urlFor('12L', 'S_V2(Snow Cone)'), '$base/12L');
    });
  });

  group('沒有官方頁面的版本回傳 null', () {
    test('Android 4.4', () {
      expect(AndroidVersionDoc.urlFor('4.4', 'KitKat'), isNull);
    });
    test('Android 1.0', () {
      expect(AndroidVersionDoc.urlFor('1.0', '(no codename)'), isNull);
    });
  });

  group('語系 hl 參數', () {
    test('zh_TW -> ?hl=zh-tw', () {
      expect(AndroidVersionDoc.urlFor('16', 'Baklava', localeCode: 'zh_TW'),
          '$base/16?hl=zh-tw');
    });
    test('en 不帶 hl 參數', () {
      expect(AndroidVersionDoc.urlFor('16', 'Baklava', localeCode: 'en'),
          '$base/16');
    });
    test('6–9 也會帶 hl', () {
      expect(AndroidVersionDoc.urlFor('9', 'Pie', localeCode: 'ja'),
          '$base/pie/android-9.0?hl=ja');
    });
  });
}
