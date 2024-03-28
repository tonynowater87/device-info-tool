
import 'package:device_info_tool/data/model/Distribution.dart';

class AndroidDistribution {
  String lastUpdated;
  List<Distribution> versionDistribution;
  List<Distribution> cumulativeDistribution;

  AndroidDistribution({
    required this.lastUpdated,
    required this.versionDistribution,
    required this.cumulativeDistribution,
  });

  factory AndroidDistribution.fromJson(List<Map<String, dynamic>> json) {
    return AndroidDistribution(
      lastUpdated: json[0]['最後更新'],
      versionDistribution:
          (json[1]['版本分佈'] as List).map((e) => Distribution.fromJson(e)).toList(),
      cumulativeDistribution:
          (json[2]['累積分佈'] as List).map((e) => Distribution.fromJson(e)).toList(),
    );
  }
}
