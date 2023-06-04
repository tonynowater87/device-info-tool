class VersionModelAndroidWearOs {
  VersionModelAndroidWearOs({
    required this.version,
    required this.osName,
    required this.androidos,
    required this.releasedate,
  });

  VersionModelAndroidWearOs.fromJson(dynamic json) {
    version = json['version'];
    osName = json['os-name'];
    androidos = json['android-os'];
    releasedate = json['release-date'];
    order = json['order'];
  }

  late String version;
  late String osName;
  late String androidos;
  late String releasedate;
  late String order;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['version'] = version;
    map['os-name'] = osName;
    map['android-os'] = androidos;
    map['release-date'] = releasedate;
    map['order'] = order;
    return map;
  }
}
