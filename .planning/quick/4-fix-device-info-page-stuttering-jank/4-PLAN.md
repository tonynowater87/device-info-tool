---
phase: quick-4
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/main.dart
  - lib/view/androiddeviceinfo/android_device_info_cubit.dart
  - lib/view/androiddeviceinfo/android_device_info_page.dart
autonomous: true
must_haves:
  truths:
    - "Switching tabs to/from device info page is smooth with no visible jank or frame drops"
    - "Memory and battery data still update periodically when page is visible"
    - "Returning to device info page shows existing data immediately without loading spinner"
  artifacts:
    - path: "lib/main.dart"
      provides: "BlocProvider created once, not on every build"
    - path: "lib/view/androiddeviceinfo/android_device_info_cubit.dart"
      provides: "Single consolidated update timer, lifecycle-aware pause/resume"
    - path: "lib/view/androiddeviceinfo/android_device_info_page.dart"
      provides: "Proper lifecycle using dispose instead of deactivate"
  key_links:
    - from: "lib/main.dart"
      to: "AndroidDeviceInfoCubit"
      via: "BlocProvider hoisted above build method"
      pattern: "BlocProvider.*AndroidDeviceInfoCubit"
---

<objective>
Fix the UI jank/stuttering when navigating back to the Android device info page.

Purpose: The device info page exhibits visible frame drops when switching tabs because:
1. BlocProvider is recreated inside `build()` on every setState, triggering full `load()` with heavy Platform Channel calls each time the drawer navigation triggers a rebuild
2. Two separate 1-second timers each call `getDeviceInfo` via Platform Channel (2 calls/second), causing excessive main thread work
3. `deactivate()` disposes the AnimationController and releases the cubit, forcing a full re-initialization on every tab switch

Output: Smooth tab switching with no visible jank on the device info page.
</objective>

<execution_context>
@/Users/tonynowater/.claude/get-shit-done/workflows/execute-plan.md
@/Users/tonynowater/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@lib/main.dart
@lib/view/androiddeviceinfo/android_device_info_page.dart
@lib/view/androiddeviceinfo/android_device_info_cubit.dart
@lib/view/androiddeviceinfo/android_device_info_state.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Consolidate timers and add lifecycle-aware pause/resume in Cubit</name>
  <files>lib/view/androiddeviceinfo/android_device_info_cubit.dart</files>
  <action>
Merge the two separate timers (`_timerUpdateMemory` and `_timerUpdateBattery`) into a single timer that calls `getDeviceInfo` once and updates both memory and battery from the same result. This cuts Platform Channel calls from 2/sec to 1 every 3 seconds.

Specific changes:
1. Replace `_timerUpdateMemory` and `_timerUpdateBattery` with a single `_updateTimer`.
2. Create `_updateDynamicInfo()` that calls `channel.invokeMethod("getDeviceInfo")` once, then parses both `AndroidCpuInfoModel` and `AndroidBatteryInfoModel` from the same map. Compare both against current state and only emit if either changed.
3. Change timer interval from `Duration(seconds: 1)` to `Duration(seconds: 3)` — battery and memory don't change fast enough to warrant 1-second polling.
4. Add `pauseTimers()` method that cancels the timer (called when page is not visible / tab switched away).
5. Add `resumeTimers()` method that restarts the timer (called when page becomes visible again). This should also trigger one immediate update.
6. Keep existing `pauseUpdates()` / `resumeUpdates()` for scroll-based pausing (sets `_isScrolling` flag).
7. Update `release()` to only cancel the timer (do NOT close the cubit — it will be reused).
8. Remove `_startMemoryUpdateTimer()`, `_startBatteryUpdateTimer()`, `_updateMemoryInfo()`, `_updateBatteryInfo()` methods.
9. In `load()`, after the initial data fetch, call the new `_startUpdateTimer()` method.
  </action>
  <verify>Run `dart analyze lib/view/androiddeviceinfo/android_device_info_cubit.dart` with no errors.</verify>
  <done>Single timer makes one Platform Channel call every 3 seconds for both memory and battery updates. Cubit has pauseTimers/resumeTimers for tab lifecycle.</done>
</task>

<task type="auto">
  <name>Task 2: Fix page lifecycle and hoist BlocProvider out of build()</name>
  <files>lib/view/androiddeviceinfo/android_device_info_page.dart, lib/main.dart</files>
  <action>
**In `android_device_info_page.dart`:**
1. Move AnimationController disposal and overlay cleanup from `deactivate()` to `dispose()`. The current code disposes the AnimationController in `deactivate()`, which fires on every tab switch, not just when the widget is truly removed.
2. Replace the `deactivate()` override entirely:
   - Remove `_animationController?.dispose()` from deactivate
   - Remove `context.read<AndroidDeviceInfoCubit>().release()` from deactivate
   - Add a proper `dispose()` method that: cancels `_scrollEndTimer`, removes status listener, disposes `_animationController`, removes `_overlayEntry`, calls `super.dispose()`
3. Make the page lifecycle-aware with `AutomaticKeepAliveClientMixin`:
   - Add `AutomaticKeepAliveClientMixin` to the State class (keep existing `SingleTickerProviderStateMixin`)
   - Override `wantKeepAlive => true`
   - Add `super.build(context)` as first line of `build()` method
   This prevents the widget from being destroyed when switching tabs in TabBarView.

**In `main.dart`:**
1. Move `androidDeviceInfoScreen` creation from inside `build()` to `initState()`. Store it as a field `late Widget _androidDeviceInfoScreen`.
   - In `initState()`, set: `_androidDeviceInfoScreen = BlocProvider(create: (context) => AndroidDeviceInfoCubit(), child: const AndroidDeviceInfoPage());`
   - In `build()`, reference `_androidDeviceInfoScreen` instead of creating a new one.
   - This prevents BlocProvider from being recreated on every drawer navigation `setState`.

Note: The BlocProvider must be created using a context that has access to the RepositoryProviders. Since `initState` doesn't have that context yet, instead move it to a `late final` field initialized in `build()` with a null check pattern:
   ```dart
   Widget? _androidDeviceInfoScreen;
   ```
   Then in build():
   ```dart
   _androidDeviceInfoScreen ??= BlocProvider(
       create: (context) => AndroidDeviceInfoCubit(),
       child: const AndroidDeviceInfoPage());
   ```
   And use `_androidDeviceInfoScreen!` in the screens list.
  </action>
  <verify>Run `flutter analyze` from project root. No errors. Then build with `flutter build apk --debug` to verify compilation.</verify>
  <done>Tab switching no longer recreates the BlocProvider or re-triggers load(). AnimationController survives tab switches. Page state is preserved via AutomaticKeepAliveClientMixin.</done>
</task>

</tasks>

<verification>
1. `flutter analyze` passes with no errors related to modified files
2. `flutter build apk --debug` compiles successfully
3. Manual test: switch between device info tab and other tabs repeatedly — no loading spinner on return, no visible jank
4. Manual test: memory and battery values still update every ~3 seconds when on device info page
</verification>

<success_criteria>
- Switching to/from device info page is smooth with no frame drops
- Device info page shows cached data immediately on tab return (no loading spinner)
- Memory/battery still update periodically (every 3 seconds instead of every 1 second)
- No Dart analysis errors
</success_criteria>

<output>
After completion, create `.planning/quick/4-fix-device-info-page-stuttering-jank/4-SUMMARY.md`
</output>
