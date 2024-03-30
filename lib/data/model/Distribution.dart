class Distribution {
  String versionName;
  String versionCode;
  double percentage;

  Distribution({
    required this.versionName,
    required this.versionCode,
    required this.percentage,
  });

  factory Distribution.fromJson(List<dynamic> json) {
    return Distribution(
      versionName: json[0],
      versionCode: json[1],
      percentage: double.parse((json[2].replaceAll('%', '')))
    );
  }

  @override
  String toString() {
    return 'Distribution{versionName: $versionName, versionCode: $versionCode, percentage: $percentage}';
  }
}
