/// api_level : "1"
/// version : "1.0"
/// code_name : "Alpha"
/// release_date : "2008-09-23"

class VersionModelAndroid {
  VersionModelAndroid({
    required String apiLevel,
    required String version,
    required String codeName,
    required String releaseDate,
  }) {
    _apiLevel = apiLevel;
    _version = version;
    _codeName = codeName;
    _releaseDate = releaseDate;
  }

  VersionModelAndroid.fromJson(dynamic json) {
    _apiLevel = json['api_level'];
    _version = json['version'];
    _codeName = json['code_name'];
    _releaseDate = json['release_date'];
  }

  late String _apiLevel;
  late String _version;
  late String _codeName;
  late String _releaseDate;

  VersionModelAndroid copyWith({
    String? apiLevel,
    String? version,
    String? codeName,
    String? releaseDate,
  }) =>
      VersionModelAndroid(
        apiLevel: apiLevel ?? _apiLevel,
        version: version ?? _version,
        codeName: codeName ?? _codeName,
        releaseDate: releaseDate ?? _releaseDate,
      );

  String get apiLevel => _apiLevel;

  String get version => _version;

  String get codeName => _codeName;

  String get releaseDate => _releaseDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['api_level'] = _apiLevel;
    map['version'] = _version;
    map['code_name'] = _codeName;
    map['release_date'] = _releaseDate;
    return map;
  }
}
