# Testing Patterns

**Analysis Date:** 2026-02-08

## Test Framework

**Runner:**
- `flutter_test` (included in Flutter SDK)
- Located in `pubspec.yaml` as dev dependency

**Assertion Library:**
- Dart's built-in `expect()` function from `flutter_test`
- No external assertion library (matcher is built-in)

**Run Commands:**
```bash
flutter test                      # Run all tests
flutter test --watch              # Watch mode (re-run on file changes)
flutter test --coverage           # Generate coverage report
flutter test test/utils_test.dart # Run specific test file
```

## Test File Organization

**Location:**
- Co-located with source: `test/` directory at root level, mirrors `lib/` structure
- Test files in `test/` directory, not alongside source files

**Naming:**
- Suffix pattern: `*_test.dart`
- Examples: `utils_test.dart`, `db_test.dart`, `widget_test.dart`, `version_comparing_test.dart`, `regex_test.dart`

**Structure:**
```
test/
├── db_test.dart
├── utils_test.dart
├── widget_test.dart
├── version_comparing_test.dart
└── regex_test.dart
```

## Test Structure

**Suite Organization:**
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test description', () {
    // Test body
    expect(actual, expected);
  });

  testWidgets('widget test description', (WidgetTester tester) async {
    // Widget test body
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
  });
}
```

**Patterns:**
- Single `main()` function containing all tests
- Tests grouped by functionality (not organized into nested describe blocks)
- Test description written in plain English
- Each test is independent and can run in isolation
- AAA Pattern: Arrange, Action, Assert (commented in test structure)

**AAA Pattern Example:**
```dart
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
});
```

## Test Types

**Unit Tests:**
- Test pure functions and business logic
- No widget or UI testing
- Location: `test/utils_test.dart`, `test/version_comparing_test.dart`, `test/regex_test.dart`
- Scope: Single function or method
- Example: Testing `Utils.getScreenRatio()`, `String.compareVersion()`, regex URL validation

```dart
test('1080, 2340 (19.5:9)', () {
  expect(Utils.getScreenRatio(1080, 2340), '19.5:9.0');
});

test('url regex', () {
  var isValid = _isValidUrl('http://google.com?lan=zh');
  expect(isValid, true);
});
```

**Database/Integration Tests:**
- Test database operations with real database instance
- Location: `test/db_test.dart`
- Setup: `DatabaseProviderImpl(isUnitTest: true)` - uses FFI database for testing
- Cleanup: No explicit teardown, relies on test isolation

```dart
test('database query/insert/update/delete-all', () async {
  var databaseProviderImpl = DatabaseProviderImpl(isUnitTest: true);
  // ...
});
```

**Widget Tests:**
- Test Flutter widgets and UI interactions
- Location: `test/widget_test.dart`
- Use `WidgetTester` for interactions and verification
- Examples: Tapping buttons, finding widgets, verifying text

```dart
testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();

  expect(find.text('1'), findsOneWidget);
});
```

**E2E Tests:**
- Not detected in codebase
- Would use `flutter_test` with full app initialization if implemented

## Async Testing

**Pattern:**
- Async operations tested with `async/await` syntax
- Database operations wrapped in `async` test functions
- Use `await` for all async calls

```dart
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
```

**Widget Async Pattern:**
- Use `tester.pump()` and `tester.pumpWidget()` for async operations
- `pump()` rebuilds widget after async work
- `pumpWidget()` builds the entire app widget tree

```dart
testWidgets('Counter increments', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();  // Rebuild after state change
});
```

## Fixtures and Test Data

**Test Data:**
- Inline test data defined in test functions
- No external fixture files or factory patterns detected

```dart
test('1600, 900 (16:9)', () {
  expect(Utils.getScreenRatio(1600, 900), '16.0:9.0');
});
```

**Database Test Setup:**
- Instantiate `DatabaseProviderImpl(isUnitTest: true)` at test start
- Uses in-memory FFI database for isolation
- Each test uses same instance (no per-test cleanup observed)

## Coverage

**Requirements:**
- No coverage targets enforced
- Coverage generation available via `flutter test --coverage`

**View Coverage:**
```bash
flutter test --coverage        # Generate coverage data
# Coverage report in coverage/lcov.info
```

## Mocking

**Framework:**
- Not explicitly detected; no mocking libraries in `pubspec.yaml`
- Manual mocking can be done with test implementations

**Pattern for Testing:**
- Mock implementations provided: `NetworkProviderDebug()` for debug mode
- Concrete implementations used in tests: `DatabaseProviderImpl(isUnitTest: true)`
- No test doubles with mock/stub/spy libraries

**What to Mock:**
- Network calls: Use `NetworkProviderDebug()` or test implementations
- External dependencies: Provide test variants of providers

**What NOT to Mock:**
- Database operations: Use real database with test flag (`isUnitTest: true`)
- Business logic functions: Test pure functions directly
- Extension methods: Test as-is with real implementations

## Test Isolation

**Pattern:**
- Tests run independently
- No shared state between tests observed
- Each database test creates fresh instance
- No explicit setup/teardown (test() doesn't support beforeEach/afterEach)

## Widget Testing Utilities

**WidgetTester Methods Used:**
- `pumpWidget(widget)` - Build and render widget tree
- `pump()` - Rebuild after async operations
- `tap(finder)` - Simulate tap gesture
- `find.text(string)` - Find widget by text
- `find.byIcon(icon)` - Find widget by icon
- `expect(finder, matcher)` - Assert widget existence/count

**Finders:**
- `findsOneWidget` - Exactly one match
- `findsNothing` - No matches
- `findsWidgets` - One or more matches

**Example:**
```dart
testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('0'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('0'), findsNothing);
  expect(find.text('1'), findsOneWidget);
});
```

## Test Characteristics

**Current Coverage:**
- Unit tests for utilities: `utils_test.dart` (9 tests for screen ratio calculation)
- Unit tests for extensions: `version_comparing_test.dart` (4 version comparison tests)
- Unit tests for regex: `regex_test.dart` (5 URL validation tests)
- Database/integration tests: `db_test.dart` (2 tests for CRUD operations)
- Widget smoke test: `widget_test.dart` (1 basic counter test - placeholder)

**Test Distribution:**
- Most tests focus on utility functions and business logic
- Limited Cubit/state management testing
- UI layer testing minimal (placeholder widget test)
- Database layer well-tested

## Deprecated Tests

**Placeholder Tests:**
- `test/widget_test.dart` - Generic "Counter increments" test unrelated to actual app
- Suggests template wasn't updated for actual application logic

---

*Testing analysis: 2026-02-08*
