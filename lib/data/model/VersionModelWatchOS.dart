class VersionModelWatchOs {
  VersionModelWatchOs({
    required this.version,
    required this.releaseDate,
    required this.latestVersion,
    required this.latestReleaseDate,
    required this.basedoniosversion,
  });

  VersionModelWatchOs.fromJson(dynamic json) {
    version = json['version'];
    releaseDate = json['release_date'];
    latestVersion = json['latest_version'];
    latestReleaseDate = json['latest_release_date'];
    basedoniosversion = json['based_on_ios_version'];
  }

  late String version;
  late String releaseDate;
  late String latestVersion;
  late String latestReleaseDate;
  late String basedoniosversion;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['version'] = version;
    map['release_date'] = releaseDate;
    map['latest_version'] = latestVersion;
    map['latest_release_date'] = latestReleaseDate;
    map['based_on_ios_version'] = basedoniosversion;
    return map;
  }
}
