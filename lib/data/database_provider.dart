import 'package:device_info_tool/data/model/url_record.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

enum DatabaseOrder { ASC, DESC }

abstract class DatabaseProvider {
  Future<List<UrlRecord>> queryUrlRecords(
      DatabaseOrder order, String query /* empty string means query all */);

  Future<bool> deleteUrlRecord(int id);

  Future<bool> deleteAllUrlRecords();

  Future<bool> insertOrUpdateUrlRecord(String url);

  Future<void> close();
}

class DatabaseProviderImpl extends DatabaseProvider {
  static const String databaseName = 'sqflite_db.db';
  Database? database;
  bool isUnitTest;

  DatabaseProviderImpl({required this.isUnitTest});

  @override
  Future<void> close() async {
    await _ensureDatabaseOpen();
    debugPrint('[DB-CLOSE]');
    return database!.close();
  }

  @override
  Future<bool> deleteAllUrlRecords() async {
    await _ensureDatabaseOpen();
    var count = await database!.delete(tableUrl);
    debugPrint('[DB-DELETE-ALL] count=$count');
    return Future.value(true);
  }

  @override
  Future<bool> deleteUrlRecord(int id) async {
    await _ensureDatabaseOpen();
    var count = await database!
        .delete(tableUrl, where: "$columnId = ?", whereArgs: [id]);
    debugPrint('[DB-DELETE] id=$id');
    return Future.value(true);
  }

  Future<List<UrlRecord>> _queryUrlRecords(String url) async {
    await _ensureDatabaseOpen();
    List<UrlRecord> result;
    List<Map<String, Object?>>? maps = await database?.query(tableUrl,
        columns: [
          columnId,
          columnUrl,
          columnUrlCreateDate,
          columnUrlUpdateDate
        ],
        where: "$columnUrl = ?",
        whereArgs: [url]);

    if (maps == null) {
      debugPrint('[DB-QUERY-MATCH] []');
      return Future.value([]);
    }

    result = maps.map((e) {
      return UrlRecord.fromMap(e);
    }).toList();

    debugPrint('[DB-QUERY-MATCH] result=$result');
    return Future.value(result);
  }

  @override
  Future<List<UrlRecord>> queryUrlRecords(
      DatabaseOrder order, String query) async {
    await _ensureDatabaseOpen();
    List<UrlRecord> result;
    List<Map<String, Object?>>? maps;
    if (query.isEmpty) {
      maps = await database?.query(tableUrl,
          columns: [
            columnId,
            columnUrl,
            columnUrlCreateDate,
            columnUrlUpdateDate
          ],
          orderBy: "$columnUrlUpdateDate ${order.name}");
    } else {
      maps = await database?.query(tableUrl,
          columns: [
            columnId,
            columnUrl,
            columnUrlCreateDate,
            columnUrlUpdateDate
          ],
          where: "$columnUrl LIKE ?",
          whereArgs: ["%$query%"],
          orderBy: "$columnUrlUpdateDate ${order.name}");
    }

    if (maps == null) {
      debugPrint('[DB-QUERY-CONTAINS] []');
      return Future.value([]);
    }

    result = maps.map((e) {
      return UrlRecord.fromMap(e);
    }).toList();

    debugPrint('[DB-QUERY-CONTAINS] result=$result');
    return Future.value(result);
  }

  @override
  Future<bool> insertOrUpdateUrlRecord(String url) async {
    await _ensureDatabaseOpen();
    var query = await _queryUrlRecords(url);
    if (query.isEmpty) {
      _insert(url);
    } else {
      _update(query.first);
    }
    return Future.value(true);
  }

  Future<int> _insert(String url) async {
    var insertDateTime = DateTime.now();
    var insertDateTimeStamp = insertDateTime.millisecondsSinceEpoch;
    var id = await database!.rawInsert(
        "INSERT INTO $tableUrl($columnUrl, $columnUrlCreateDate, $columnUrlUpdateDate) VALUES('$url', $insertDateTimeStamp, $insertDateTimeStamp)");
    debugPrint('[DB-INSERT] id=$id, url=$url');
    return Future.value(id);
  }

  Future<int> _update(UrlRecord urlRecord) async {
    var updatedDateTime = DateTime.now();
    urlRecord.updateDate = updatedDateTime.millisecondsSinceEpoch;
    int count = await database!.update(tableUrl, urlRecord.toMap(),
        where: "$columnId = ?", whereArgs: [urlRecord.id]);
    debugPrint(
        '[DB-UPDATE] id=${urlRecord.id}, count=$count, urlRecord=$urlRecord');
    return Future.value(count);
  }

  Future<void> _ensureDatabaseOpen() async {
    if (database?.isOpen == true) {
      return;
    }
    DatabaseFactory factory;
    if (isUnitTest) {
      debugPrint('[DB] isUnitTest');
      sqfliteFfiInit();
      factory = databaseFactoryFfi;
    } else {
      debugPrint('[DB] isNotUnitTest');
      factory = databaseFactory;
    }
    final databasePath = await factory.getDatabasesPath();
    debugPrint('[DB] databasePath=$databasePath');
    database = await factory.openDatabase("$databasePath/$databaseName",
        options: OpenDatabaseOptions(
            version: 1,
            onOpen: (Database db) {
              debugPrint('[DB] database onOpen');
            },
            onCreate: (Database db, int version) async {
              debugPrint('[DB] database onCreated');
              await db.execute('''
            create table $tableUrl (
              $columnId integer primary key autoincrement,
              $columnUrl TEXT NOT NULL,
              $columnUrlCreateDate INTEGER NOT NULL,
              $columnUrlUpdateDate INTEGER NOT NULL
            )
          ''');
            }));
  }
}
