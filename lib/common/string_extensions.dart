import 'dart:io';

extension StringExtension on String {
  bool compareVersion(String otherVersion) {
    if (isEmpty || otherVersion.isEmpty) {
      return false;
    }
    if (Platform.isAndroid) {
      return this == otherVersion;
    } else {
      final thisMainVersion = split(".");
      final otherMainVersion = otherVersion.split(".");
      return thisMainVersion[0] == otherMainVersion[0];
    }
  }
}
