class VersionModeliOs {
  VersionModeliOs({
    required this.version,
    required this.latestVersion,
    required this.releaseDate,
    required this.latestDate,
  });

  VersionModeliOs.fromJson(dynamic json) {
    version = json['version'];
    latestVersion = json['latest_version'];
    releaseDate = json['release_date'];
    latestDate = json['latest_date'];
  }

  late String version;
  late String latestVersion;
  late String releaseDate;
  late String latestDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['version'] = version;
    map['latest_version'] = latestVersion;
    map['release_date'] = releaseDate;
    map['latest_date'] = latestDate;
    return map;
  }
}
