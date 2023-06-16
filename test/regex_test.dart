import 'package:flutter_test/flutter_test.dart';

void main() {
  test('url regex', () {
    var isValid = _isValidUrl('kkk');
    expect(isValid, false);

    isValid = _isValidUrl('www.google.com');
    expect(isValid, false);

    isValid = _isValidUrl('test://google.com');
    expect(isValid, true);

    isValid = _isValidUrl('http://google.com?lan=zh');
    expect(isValid, true);

    isValid = _isValidUrl('https://google.com/lan/zh');
    expect(isValid, true);
  });
}

bool _isValidUrl(String url) {
  const pattern =
      r'^(\w+:\/\/)+[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?$';
  final regex = RegExp(pattern);
  return regex.hasMatch(url);
}
