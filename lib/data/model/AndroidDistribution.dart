import 'package:device_info_tool/data/model/Distribution.dart';

class MobileDistribution {
  String lastUpdated;
  List<Distribution> versionDistribution;
  List<Distribution> cumulativeDistribution;

  MobileDistribution({
    required this.lastUpdated,
    required this.versionDistribution,
    required this.cumulativeDistribution,
  });

  factory MobileDistribution.fromJson(List<Map<String, dynamic>> json) {
    return MobileDistribution(
      lastUpdated: json[0]['最後更新'],
      versionDistribution: (json[1]['版本分佈'] as List)
          .map((e) => Distribution.fromJson(e))
          .toList()
          .reversed
          .toList(),
      cumulativeDistribution: (json[2]['累積分佈'] as List)
          .map((e) => Distribution.fromJson(e))
          .toList()
          .reversed
          .toList(),
    );
  }

  @override
  String toString() {
    return 'MobileDistribution{lastUpdated: $lastUpdated, versionDistribution: ${versionDistribution.length}, cumulativeDistribution: ${cumulativeDistribution.length}}';
  }
}
