import 'dart:math';

class Utils {
  static String formatMB(int megabytes, int decimals) {
    if (megabytes <= 0) return "0 MB";
    const suffixes = ["MB", "GB", "TB"];
    var i = (log(megabytes) / log(1000)).floor();
    return '${(megabytes / pow(1000, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}