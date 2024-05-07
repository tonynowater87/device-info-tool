import 'dart:math';

class Utils {
  static List<String> commonRatio = [
    '3.0:2.0',
    '4.0:3.0',
    '5.0:4.0',
    '16.0:9.0',
    '16.0:10.0',
    '19.5:9.0',
    '21.0:9.0',
  ];

  static String formatMB(int megabytes, int decimals) {
    if (megabytes <= 0) return "0 MB";
    const suffixes = ["MB", "GB", "TB"];
    var i = (log(megabytes) / log(1000)).floor();
    return '${(megabytes / pow(1000, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String getScreenRatio(int width, int height) {
    int? num = _calc(width, height);

    if (num == null) {
      return '$width:$height';
    }

    double ratioH = width / num;
    double ratioW = height / num;

    if (num != 1) {
      return getScreenRatio(ratioW.toInt(), ratioH.toInt());
    } else {
      if (ratioH > ratioW) {
        return scaleRatioIfNeeded('$ratioH:$ratioW');
      } else {
        return scaleRatioIfNeeded('$ratioW:$ratioH');
      }
    }
  }

  // calculate the greatest common divisor
  static int? _calc(int a, int b) {
    if (a == 0 || b == 0) {
      return null;
    }

    while (a > 0 && b > 0) {
      if (a > b) {
        a = a % b;
      } else {
        b = b % a;
      }
    }

    if (a == 0) {
      return b;
    } else {
      return a;
    }
  }

  static String scaleRatioIfNeeded(String ratio) {
    if (commonRatio.where((element) => element == ratio).isNotEmpty) {
      return ratio;
    }
    if (ratio == "8.0:5.0") {
      return "16.0:10.0";
    } else {
      double w = double.parse(ratio.split(":")[0]);
      double h = double.parse(ratio.split(":")[1]);
      if (h > 9) {
        double scale = 9 / h;
        String ratioWScale = (w * scale).toStringAsFixed(1);
        return "$ratioWScale:9.0";
      } else {
        double scale = h / 9;
        String ratioHScale = (w / scale).toStringAsFixed(1);
        return "$ratioHScale:9.0";
      }
    }
  }
}
