# Coding Conventions

**Analysis Date:** 2026-02-08

## Naming Patterns

**Files:**
- Snake_case for all Dart files: `android_device_info_cubit.dart`, `database_provider.dart`, `string_extensions.dart`
- Mixedcase files exist but discouraged: `AppVersionProvider.dart`, `NetworkProvider.dart`
- State files use suffix pattern: `android_device_info_state.dart` (part of cubit files)

**Functions:**
- camelCase for all functions: `formatMB()`, `getScreenRatio()`, `copyAdvertisingId()`
- Private functions use leading underscore: `_calc()`, `_updateMemoryInfo()`, `_sort()`
- Async functions return `Future<T>`: `Future<void> load()`, `Future<List<UrlRecord>> queryUrlRecords()`

**Variables:**
- camelCase for local variables: `selfVersion`, `currentState`, `wifiIp`
- Private class fields use leading underscore: `_networkProvider`, `_isScrolling`, `_apiLevel`
- Constants use snake_case or camelCase depending on context: `DefaultTitle = 'Device Info Tool'`, `const databaseName = 'sqflite_db.db'`

**Types & Classes:**
- PascalCase for all class names: `MyApp`, `AndroidDeviceInfoCubit`, `VersionModelAndroid`
- PascalCase for enum names: `DatabaseOrder`, `FGBGType`, `DeviceType`
- Private classes use leading underscore: `_MyAppState`
- Model classes use suffix convention: `VersionModelAndroid`, `AndroidDeviceInfoModel`, `AndroidBatteryInfoModel`

**Getters & Setters:**
- camelCase: `get apiLevel`, `get version`, `get codeName`
- Private backing fields paired with public getters: `late String _apiLevel` with `String get apiLevel => _apiLevel`

## Code Style

**Formatting:**
- Dart standard formatting with 2-space indentation
- No explicit formatter configured (uses Flutter default)

**Linting:**
- Uses `flutter_lints` 2.0.0 with Flutter recommended rules enabled
- Configuration: `include: package:flutter_lints/flutter.yaml` in `analysis_options.yaml`
- Lints can be suppressed per-line with `// ignore: lint_name` or per-file with `// ignore_for_file: lint_name`
- Target SDK: Dart 3.7.0 or higher

**Line Length:**
- Standard Flutter convention (~80 chars for readability, but not strictly enforced)

## Import Organization

**Order:**
1. Dart standard library imports: `import 'dart:io'`, `import 'dart:math'`, `import 'dart:async'`
2. Flutter framework imports: `import 'package:flutter/material.dart'`, `import 'package:flutter/services.dart'`
3. Package imports (alphabetically): `import 'package:bloc/bloc.dart'`, `import 'package:connectivity_plus/connectivity_plus.dart'`
4. Local project imports: `import 'package:device_info_tool/common/utils.dart'`
5. Part files: `part 'android_device_info_state.dart'` (at end)

**Path Aliases:**
- Full package path used throughout: `package:device_info_tool/data/NetworkProvider.dart`
- No path aliases configured

## Error Handling

**Patterns:**
- Try-catch blocks around platform channel calls and network requests
- Silent failure in periodic timers: `try { } catch (e) { debugPrint('...'); }` - errors logged but not thrown
- Exception recording to Firebase Crashlytics: `FirebaseCrashlytics.instance.recordError(Exception(...), null)`
- Generic catch pattern: `catch (e) { emit(PageFailureState()); }` in Cubit classes
- PlatformException handling for MethodChannel calls
- Null coalescing with fallback values: `advertisingId ?? 'Failed to get advertisingId.'`

**State Management Errors:**
- Cubits emit failure states on error: `emit(AndroidVersionPageFailure())`
- No custom exception classes defined; using generic Exception

## Logging

**Framework:** `debugPrint()` from Flutter

**Patterns:**
- Log database operations with prefix tags: `debugPrint('[DB-INSERT] id=$id, url=$url')`
- Log initialization steps: `debugPrint('[DB] isUnitTest')`, `debugPrint('[DB] database onCreated')`
- Log state changes and updates
- Use for debugging only, not production analytics (Firebase Crashlytics used for error tracking)

**Example:**
```dart
debugPrint('[DB-UPDATE] id=${urlRecord.id}, count=$count, urlRecord=$urlRecord');
debugPrint('[DB-QUERY-CONTAINS] result=$result');
```

## Comments

**When to Comment:**
- JSDoc-style comments for models explaining JSON field mappings
- Comments for complex algorithms: `// calculate the greatest common divisor`
- Comments for clarification on non-obvious logic
- Comments for deferred updates: `// Wait for the widget tree to be built before navigating`

**JSDoc/TSDoc:**
- Dart documentation comments using `///` for public APIs
- Field documentation in models:

```dart
/// api_level : "1"
/// version : "1.0"
/// code_name : "Alpha"
/// release_date : "2008-09-23"
class VersionModelAndroid { ... }
```

## Function Design

**Size:**
- Keep functions focused and small
- Complex logic broken into private helper methods: `_sort()`, `_updateMemoryInfo()`, `_ensureDatabaseOpen()`
- Typical function size: 5-50 lines

**Parameters:**
- Use named parameters with `required` keyword: `{required NetworkProvider networkProvider}`
- Constructor pattern: Store dependencies as late-initialized private fields
- No positional parameters for public APIs (except simple getters)

**Return Values:**
- Async functions return `Future<T>` wrapped in `Future.value(result)` or direct return
- Query methods return `List<T>` or `List<T>?`
- Boolean returns for success/failure: `Future<bool>`
- State-based returns for Cubits (via `emit()`)

## Module Design

**Exports:**
- Each feature/screen has dedicated directory with: `*_cubit.dart`, `*_state.dart`, `*_page.dart`
- Data layer has abstract interfaces with Impl suffixes: `NetworkProvider` / `NetworkProviderGithub`
- Database module: `database_provider.dart` with abstract class and implementation

**Barrel Files:**
- Not commonly used; explicit imports preferred
- State files imported via `part` directive in Cubit: `part 'android_version_page_state.dart'`

**Private Visibility:**
- Use underscore prefix for private: `_networkProvider`, `_ensureDatabaseOpen()`, `_MyAppState`
- Abstract classes define public contracts; implementations are internal

## Extension Methods

**Pattern:**
- Extensions defined in separate files: `string_extensions.dart`
- Extend only core types: `extension StringExtension on String`
- Method body handles type-specific logic with platform checks

**Example:**
```dart
extension StringExtension on String {
  bool compareVersion(String otherVersion) {
    if (isEmpty || otherVersion.isEmpty) {
      return false;
    }
    if (Platform.isAndroid) {
      return this == otherVersion;
    } else {
      final thisMainVersion = split(".");
      final otherMainVersion = otherVersion.split(".");
      return thisMainVersion[0] == otherMainVersion[0];
    }
  }
}
```

## Model Serialization

**Pattern:**
- Manual JSON serialization with `fromJson()` and `toJson()` methods
- No code generation tools (json_serializable) used
- Factory constructor: `VersionModelAndroid.fromJson(dynamic json)`
- Copy method pattern for immutability: `copyWith({...})`

**Private Backing Fields:**
```dart
late String _apiLevel;
String get apiLevel => _apiLevel;
```

---

*Convention analysis: 2026-02-08*
