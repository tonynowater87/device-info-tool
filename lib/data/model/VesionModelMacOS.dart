class VesionModelMacOs {
  VesionModelMacOs({
    required this.version,
    required this.versionName,
    required this.initialReleaseDate,
    required this.latestVersion,
    required this.latestReleaseDate,
  });

  VesionModelMacOs.fromJson(dynamic json) {
    version = json['version'];
    versionName = json['version_name'];
    initialReleaseDate = json['initial_release_date'];
    latestVersion = json['latest_version'];
    latestReleaseDate = json['latest_release_date'];
  }

  late String version;
  late String versionName;
  late String initialReleaseDate;
  late String latestVersion;
  late String latestReleaseDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['version'] = version;
    map['version_name'] = versionName;
    map['initial_release_date'] = initialReleaseDate;
    map['latest_version'] = latestVersion;
    map['latest_release_date'] = latestReleaseDate;
    return map;
  }
}
