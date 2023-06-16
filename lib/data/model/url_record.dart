const String tableUrl = 'url_table';
const String columnId = '_id';
const String columnUrl = 'url';
const String columnUrlCreateDate = 'create_date';
const String columnUrlUpdateDate = 'update_date';

class UrlRecord {
  final int id;
  final String url;
  final int createDate;
  int updateDate;

  UrlRecord({
    required this.id,
    required this.url,
    required this.createDate,
    required this.updateDate,
  });

  Map<String, Object> toMap() {
    var map = <String, Object>{
      columnId: id,
      columnUrl: url,
      columnUrlCreateDate: createDate,
      columnUrlUpdateDate: updateDate
    };
    return map;
  }

  static UrlRecord fromMap(Map<String, Object?> map) {
    var id = map[columnId] as int;
    var url = map[columnUrl] as String;
    var createDate = map[columnUrlCreateDate] as int;
    var updateDate = map[columnUrlUpdateDate] as int;
    return UrlRecord(
        id: id, url: url, createDate: createDate, updateDate: updateDate);
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

class UrlModel {
  final int id;
  final String url;

  const UrlModel({
    required this.id,
    required this.url,
  });
}
