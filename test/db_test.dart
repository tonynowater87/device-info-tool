import 'package:device_info_tool/data/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var databaseProviderImpl = DatabaseProviderImpl(isUnitTest: true);

  test('database query/insert/update/delete-all', () async {
    // ARRANGE
    await databaseProviderImpl.insertOrUpdateUrlRecord("flutter_test");
    await databaseProviderImpl.insertOrUpdateUrlRecord("database_test");

    // ACTION
    var result = await databaseProviderImpl.queryUrlRecords(
        DatabaseOrder.asc, "flutter");

    // ASSERT
    expect(result.length, 1);
    expect(result.first.url, "flutter_test");

    // ACTION
    var queryPartiallyResult =
        await databaseProviderImpl.queryUrlRecords(DatabaseOrder.asc, "fl");

    // ASSERT
    expect(queryPartiallyResult.length, 1);
    expect(queryPartiallyResult.first.url, "flutter_test");

    // ACTION
    var queryAll =
        await databaseProviderImpl.queryUrlRecords(DatabaseOrder.asc, "");
    var deleteAllReturn = await databaseProviderImpl.deleteAllUrlRecords();
    var queryAllAfterDeleteAll =
        await databaseProviderImpl.queryUrlRecords(DatabaseOrder.asc, "");

    // ASSERT
    expect(queryAll.length, 2);
    expect(deleteAllReturn, true);
    expect(queryAllAfterDeleteAll.length, 0);
  });

  test('delete by id', () async {
    // ARRANGE
    await databaseProviderImpl.insertOrUpdateUrlRecord("www.google.com");
    var result = await databaseProviderImpl.queryUrlRecords(
        DatabaseOrder.asc, "www.google.com");

    // ACTION
    await databaseProviderImpl.deleteUrlRecord(result.first.id);
    result = await databaseProviderImpl.queryUrlRecords(
        DatabaseOrder.asc, "www.google.com");

    // ASSERT
    expect(result.length, 0);
  });
}
