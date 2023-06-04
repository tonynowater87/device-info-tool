class VersionModelTvOs {
  VersionModelTvOs({
    required this.version,
    required this.releaseDate,
    required this.latestVersion,
    required this.latestDate,
  });

  VersionModelTvOs.fromJson(dynamic json) {
    version = json['version'];
    releaseDate = json['release_date'];
    latestVersion = json['latest_version'];
    latestDate = json['latest_date'];
  }

  late String version;
  late String releaseDate;
  late String latestVersion;
  late String latestDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['version'] = version;
    map['release_date'] = releaseDate;
    map['latest_version'] = latestVersion;
    map['latest_date'] = latestDate;
    return map;
  }
}
