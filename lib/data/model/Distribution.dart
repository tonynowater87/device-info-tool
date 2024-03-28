class Distribution {
  String versionName;
  String versionCode;
  String percentage;

  Distribution({
    required this.versionName,
    required this.versionCode,
    required this.percentage,
  });

  factory Distribution.fromJson(List<dynamic> json) {
    return Distribution(
      versionName: json[0],
      versionCode: json[1],
      percentage: json[2],
    );
  }
}