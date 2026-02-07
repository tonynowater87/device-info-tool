# Codebase Concerns

**Analysis Date:** 2026-02-08

## Tech Debt

**SQL Injection Vulnerability in Database Provider:**
- Issue: Raw SQL string concatenation used for INSERT operations without parameterization
- Files: `lib/data/database_provider.dart` (line 134)
- Impact: The `_insert()` method constructs SQL with direct string interpolation: `"INSERT INTO $tableUrl($columnUrl, $columnUrlCreateDate, $columnUrlUpdateDate) VALUES('$url', $insertDateTimeStamp, $insertDateTimeStamp)"`. Malicious URLs with SQL injection payloads could corrupt or access database data.
- Fix approach: Replace `rawInsert()` with parameterized `insert()` method. Change from: `database!.rawInsert("INSERT INTO ... VALUES('$url', ...")` to: `database!.insert(tableUrl, {'$columnUrl': url, ...})`. This prevents SQL injection by treating values as data, not executable SQL.

**Unhandled HTTP Exceptions in Network Layer:**
- Issue: Network provider methods catch no exceptions; failures silently return empty lists
- Files: `lib/data/NetworkProviderGithub.dart` (lines 25-36, 39-50, 53-64, etc.)
- Impact: Network errors (timeout, connection failure, JSON parsing failure) are caught in finally block but cause uninitialized variable access or silent failures. The `model` variable in distribution methods (lines 125, 143) is used uninitialized if an exception occurs.
- Fix approach: Add explicit error handling with try-catch. Instead of relying on finally to close HttpClient, wrap JSON parsing and network calls. Return null or throw custom exceptions for upstream handling.

**Missing Return Type in Async Method:**
- Issue: `load()` method in `DeepLinkCubit` missing Future return type
- Files: `lib/view/deeplink/deep_link_cubit.dart` (line 15)
- Impact: The method signature is `load(String query) async` instead of `Future<void> load(String query)`. This breaks the contract for callers expecting a awaitable Future and can cause timing issues in state management.
- Fix approach: Add explicit return type: `Future<void> load(String query) async {}`

**Missing Return Type in Another Async Method:**
- Issue: `deleteById()` method in `DeepLinkCubit` missing Future return type
- Files: `lib/view/deeplink/deep_link_cubit.dart` (line 47)
- Impact: Same as above - callers cannot properly await this method. Another instance is `deleteAll()` on line 58.
- Fix approach: Add explicit return type: `Future<void> deleteById(int id) async {}`

**Unsafe State Casting Without Null Checks:**
- Issue: State is cast to `DeepLinkLoaded` without checking if state is actually that type
- Files: `lib/view/deeplink/deep_link_cubit.dart` (lines 25, 49, 60)
- Impact: If `open()` or `deleteById()` is called when state is `DeepLinkLoading`, a runtime crash occurs. No runtime type safety.
- Fix approach: Add state type guards before casting: `if (state is! DeepLinkLoaded) return;` and emit error state if operation fails due to wrong state.

**Inefficient Resource Management - HttpClient Not Properly Closed:**
- Issue: `httpClient.close()` is called in finally blocks after each request, but HttpClient is created fresh each time
- Files: `lib/data/NetworkProviderGithub.dart` (entire class)
- Impact: Creating and immediately closing HttpClient for every request adds overhead. Connection pooling and keep-alive benefits are lost. Memory and CPU inefficiency, especially with multiple concurrent requests.
- Fix approach: Keep HttpClient as a singleton or instance variable. Close it only once during app lifecycle, not after each request. Add proper cleanup in dispose methods.

**Unvalidated External JSON Data:**
- Issue: Distribution JSON response is manipulated without validation
- Files: `lib/data/NetworkProviderGithub.dart` (lines 130-132, 148-150)
- Impact: Code assumes JSON structure `[{...}, {...}, {...}]` and overwrites entries blindly. If remote JSON structure changes, the data mutation could corrupt values or throw index exceptions.
- Fix approach: Add structure validation and defensive indexing. Check array length before accessing indices.

## Known Bugs

**HttpClient State Corruption:**
- Symptoms: Occasional "Socket exception" or "Connection closed" errors on consecutive network calls
- Files: `lib/data/NetworkProviderGithub.dart` (created fresh in `main.dart` line 88)
- Trigger: Multiple rapid requests to version endpoints (Android, iOS, Distribution pages loading simultaneously). HttpClient is created once, closed after first request, then used again.
- Workaround: Refresh page or wait a few seconds before trying again

**Race Condition in Memory/Battery Update:**
- Symptoms: Occasional crashes when navigating away from Android Device Info page while timers are updating
- Files: `lib/view/androiddeviceinfo/android_device_info_cubit.dart` (lines 174-177, 232-234)
- Trigger: User navigates away (triggering `close()`), but timers fire concurrently with emit operations
- Workaround: None - intermittent crashes on navigation. Mitigation: timers are cancelled in close() but race condition window exists

**Distribution Data Format Assumption:**
- Symptoms: App crashes when viewing Android/iOS distribution if remote JSON structure changes
- Files: `lib/data/NetworkProviderGithub.dart` (lines 130-132 for Android, 148-150 for iOS)
- Trigger: Remote JSON format is hardcoded with key names '最後更新', '版本分佈', '累積分佈'. Any change breaks parsing.
- Workaround: Cannot be worked around - requires code change

## Security Considerations

**Advertising ID Tracking Disclosure:**
- Risk: App collects and displays Google Advertising ID and Android ID without explicit user consent banner
- Files: `lib/view/androiddeviceinfo/android_device_info_cubit.dart` (lines 50, 238-257)
- Current mitigation: App is "Device Info Tool" - clearly intended for developers/system inspection. Displayed in app UI, not transmitted.
- Recommendations: Add privacy policy reference. Consider adding user warning about data collection on first launch. Ensure no background transmission of IDs to remote servers (spot check code for hidden analytics).

**Firebase Crashlytics Exception Logging:**
- Risk: User-triggering exceptions and platform exceptions are sent to Firebase including potential sensitive error details
- Files: `lib/view/androiddeviceinfo/android_device_info_cubit.dart` (lines 245-246, 253-254), `lib/main.dart` (lines 73-75)
- Current mitigation: Firebase Crashlytics is configured; errors are logged with `recordError()`.
- Recommendations: Review Firebase project permissions. Ensure only non-production builds or debug variants disable analytics. Audit what exception messages contain.

**URL Validation Regex:**
- Risk: URL validation regex at `lib/view/deeplink/deep_link_cubit.dart` line 72 may not catch all malicious URLs
- Files: `lib/view/deeplink/deep_link_cubit.dart` (line 72)
- Current mitigation: Regex `r'^(\w+)://[^/\s?#]+(?:/[^?\s#]*)?(?:\?[^#\s]*)?(?:#[^\s]*)?$'` is basic. Doesn't validate against JavaScript/data URIs comprehensively.
- Recommendations: Use Uri.parse() with validation instead of regex. Whitelist safe schemes (http, https, intent). Reject javascript:, data:, file: schemes.

## Performance Bottlenecks

**Synchronous Memory Update Every Second:**
- Problem: Timer fires every 1 second to update CPU/memory info (lines 175, 232). Each triggers MethodChannel call and full state emission even if data unchanged
- Files: `lib/view/androiddeviceinfo/android_device_info_cubit.dart` (lines 119-170, 180-228)
- Cause: Aggressive 1-second polling with full state copies. No debouncing. Changes detection exists (lines 140-141, 200-204) but only prevents redundant emits, not the platform calls.
- Improvement path: Increase timer interval to 2-3 seconds for less critical info. Debounce platform channel calls. Consider using Stream from platform side instead of polling.

**HttpClient Recreation on Every Request:**
- Problem: Each network provider method creates and destroys HttpClient connection
- Files: `lib/main.dart` (line 88), consumed by multiple cubits
- Cause: HttpClient passed to constructor but closed immediately after first use. Subsequent requests create new connections.
- Improvement path: Implement connection pooling or reuse. Keep HttpClient alive for app lifetime. Implement proper connection cleanup on app termination.

**Full State Emission on Minor Data Changes:**
- Problem: Any memory/battery/CPU change triggers full `AndroidDeviceInfoLoaded` state emit with all 10 fields
- Files: `lib/view/androiddeviceinfo/android_device_info_cubit.dart` (lines 152-165, 210-222)
- Cause: BLoC pattern requires full state objects. No partial updates. Every 1-second timer triggers potential widget rebuild.
- Improvement path: Use Equatable to compare full states and prevent redundant rebuilds. Consider splitting state into smaller domains (memory updates separate from battery). Use `const` state constructors where possible.

## Fragile Areas

**Network Version Parsing:**
- Files: `lib/data/NetworkProviderGithub.dart`
- Why fragile: Assumes JSON response structure from hardcoded GitHub URL is immutable. No versioning, no fallback handling. If GitHub repo is deleted or structure changes, entire app feature breaks silently.
- Safe modification: Add response schema validation. Implement fallback to local resource data. Add retry logic with exponential backoff. Consider caching responses locally for offline use.
- Test coverage: No unit tests found for JSON parsing. No test fixtures for version models.

**State Type Casting in Cubits:**
- Files: `lib/view/deeplink/deep_link_cubit.dart` (lines 25, 49, 60)
- Why fragile: Direct casts like `(state as DeepLinkLoaded)` crash if state type assumption is wrong. No guards prevent usage in wrong state.
- Safe modification: Use `if (state is DeepLinkLoaded)` guards before all casts. Emit error states instead of silent failures. Add exhaustive state handling in UI layer.
- Test coverage: No unit tests for state transitions or error paths in cubits.

**Platform Channel Method Name Hardcoding:**
- Files: `lib/view/androiddeviceinfo/android_device_info_cubit.dart` (lines 39, 130, 190)
- Why fragile: Method name `"getDeviceInfo"` is hardcoded string in Dart. If Android side renames it, crashes without clear error. No version negotiation.
- Safe modification: Define method channel names as constants. Add try-catch for MissingPluginException. Implement fallback behavior or user-friendly error message.
- Test coverage: No tests for platform channel failure modes.

**Localization String Generation:**
- Files: `lib/l10n/app_localizations.dart` (5257 lines - generated file)
- Why fragile: Large auto-generated file with no manual modifications possible. If generation tool fails, entire localization system breaks. No fallback language specified.
- Safe modification: Ensure generation process is integrated into build pipeline. Define default locale fallback (e.g., English). Test that generation step runs successfully.
- Test coverage: None visible.

## Scaling Limits

**Database Single Table Query Performance:**
- Current capacity: URL records are queried with LIKE pattern matching (`%$query%`), which performs full table scans
- Limit: At 10,000+ URL records, LIKE queries will be slow. No indexes defined on `columnUrl`.
- Scaling path: Add database index on URL column. Migrate to full-text search. Implement pagination for result sets. Cache frequent queries.

**Memory Update Polling:**
- Current capacity: 1-second timer fires for memory/battery updates, each triggering MethodChannel call
- Limit: On devices with slow MethodChannel performance or many concurrent cubits, timers may queue up and cause jank
- Scaling path: Use platform-side streaming instead of polling. Implement debouncing with longer intervals. Consider moving to separate isolate.

**Ad Loading Synchronous Initialization:**
- Current capacity: Google Mobile Ads initializes synchronously in main() with no timeout
- Limit: If ad network is slow or unavailable, app startup hangs
- Scaling path: Initialize ads asynchronously. Implement timeout with graceful degradation. Show ads only if initialization succeeds within timeout.

## Dependencies at Risk

**google_mobile_ads 6.0.0:**
- Risk: Ad library version is several major releases old (current is 7+). May have security vulnerabilities or compatibility issues with newer Android/iOS SDKs.
- Impact: Ad loading may fail on newer OS versions. Security patches not applied. Increased app size without benefit.
- Migration plan: Update to latest `google_mobile_ads` version. Test ad display on target devices. May require Firebase/AdMob account reconfiguration.

**intl: any:**
- Risk: Wildcard dependency allows breaking changes. No pinned version means different environments could use incompatible versions.
- Impact: Localization behavior could differ between developer and production builds.
- Migration plan: Pin to specific version (e.g., `intl: ^0.19.0`). Add upper bound constraint.

**fluttertoast from Git:**
- Risk: Dependency from custom Git fork instead of pub.dev. Difficult to maintain and audit.
- Impact: If fork is deleted, builds fail. No automatic updates. Security issues in fork may not be known.
- Migration plan: Check if original `fluttertoast` on pub.dev is suitable. Migrate away from fork if possible. If fork is necessary, document why and maintain it actively.

**firebase_crashlytics 3.2.0:**
- Risk: Version is 1-2 major releases old. May not support latest Flutter SDK or have known issues fixed.
- Impact: Crash reporting may not work on latest Android/iOS versions. Security vulnerabilities possible.
- Migration plan: Update to Firebase suite compatible version. Test crash reporting.

## Missing Critical Features

**No Offline Support:**
- Problem: Version data is fetched from GitHub on every page load. No local caching.
- Blocks: Cannot use app without internet. Poor UX in poor connectivity situations.

**No Error User Feedback:**
- Problem: Network errors emit `Failure` state but UI shows nothing or blank screen
- Blocks: Users cannot understand why page is blank. No retry mechanism visible.

**No Request Timeout Handling:**
- Problem: Network requests have no explicit timeout set
- Blocks: Slow networks cause indefinite hangs

## Test Coverage Gaps

**Unit Tests Missing for Critical Logic:**
- What's not tested: Version model parsing, JSON deserialization, version comparison logic, database operations
- Files: `lib/data/model/`, `lib/data/NetworkProviderGithub.dart`, `lib/data/database_provider.dart`
- Risk: JSON parsing errors, null reference exceptions, or database corruption could occur undetected
- Priority: High

**Cubit State Transition Tests:**
- What's not tested: State transitions in all cubits, error handling paths, state casting safety
- Files: `lib/view/**/cubit.dart`
- Risk: State corruption bugs, crashes on wrong state, unhandled edge cases
- Priority: High

**Platform Channel Integration Tests:**
- What's not tested: MethodChannel calls, success/failure paths, timeout behavior
- Files: `lib/view/androiddeviceinfo/android_device_info_cubit.dart`
- Risk: Platform code failures crash the app silently or with confusing errors
- Priority: High

**Widget Tests:**
- What's not tested: Widget rebuild efficiency, error state UI, loading state UI, integration with cubits
- Files: `test/widget_test.dart` contains placeholder "Counter increments" test unrelated to actual app
- Risk: UI regressions undetected, poor performance not caught
- Priority: Medium

---

*Concerns audit: 2026-02-08*
