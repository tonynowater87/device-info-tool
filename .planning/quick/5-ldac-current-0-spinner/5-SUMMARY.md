---
phase: quick-5
plan: 01
subsystem: bluetooth-audio
tags: [ldac, codec, dropdown, flutter, android, bugfix]
dependency_graph:
  requires: []
  provides: [ldac-bitrate-display-fix, ldac-spinner-selectable]
  affects: [bluetooth_audio_page, BluetoothAudioHandler]
tech_stack:
  added: []
  patterns: [value-normalization-at-ui-layer]
key_files:
  created: []
  modified:
    - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
    - lib/view/bluetoothaudio/bluetooth_audio_page.dart
decisions:
  - "Normalize codecSpecific1==0 to 1003 at UI layer so DropdownButton always matches, and selecting ABR always sends 1003 (explicit constant)"
  - "Keep 0L as explicit case in bitrateToString() for clarity even though else branch also covers it"
metrics:
  duration: "< 1 min"
  completed: "2026-02-19"
  tasks_completed: 1
  files_modified: 2
---

# Phase quick-5 Plan 01: Fix LDAC Current (0) Display and Spinner Summary

**One-liner:** Normalize Android's ABR default `codecSpecific1=0` to explicit ABR constant `1003` at UI layer, fixing "Current (0)" display and unselectable dropdown items.

## What Was Done

Fixed two related bugs caused by the same root cause: Android returns `codecSpecific1 = 0` when LDAC is in default ABR (adaptive bitrate) mode, but the Flutter dropdown only listed values 1000-1003, causing a mismatch.

### Root Cause

- `getCodecSpecific1()` returns `0` as the default (unset) value when LDAC uses ABR mode automatically
- The Flutter `DropdownButton` had no item with value `0`, so it fell back to showing "Current (0)"
- The mismatch between the current value and available items also made the spinner unresponsive

### Fix Applied

**1. `BluetoothAudioHandler.kt` - `bitrateToString()`**

Added explicit `0L` case to the `when` block for clarity:

```kotlin
when (codecSpecific1) {
    0L -> "ABR (自適應)"      // Android returns 0 for ABR/Best Effort mode
    1000L -> "990 kbps (最高品質)"
    1001L -> "660 kbps (標準)"
    1002L -> "330 kbps (連接優先)"
    1003L -> "ABR (自適應)"
    else -> "ABR (自適應)"
}
```

**2. `bluetooth_audio_page.dart` - LDAC dropdown**

Normalize `codecSpecific1 == 0` to `1003` before passing to DropdownButton:

```dart
rawValues.codecSpecific1 == 0 ? 1003 : rawValues.codecSpecific1,
```

This keeps 4 clean options (no duplicates), ensures DropdownButton always finds a match, and selecting ABR always sends the explicit ABR constant `1003`.

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | 8dfc471 | fix(quick-5): fix LDAC codecSpecific1=0 showing 'Current (0)' and unselectable spinner |

## Deviations from Plan

None - plan executed exactly as written.

## Verification

- `flutter analyze` passes with no new errors (pre-existing errors in `test/db_test.dart` are unrelated)
- No errors in modified files (`bluetooth_audio_page.dart`, `BluetoothAudioHandler.kt`)
- LDAC dropdown contains exactly 4 entries (990 kbps / 660 kbps / 330 kbps / ABR)
- `codecSpecific1 == 0` is normalized to `1003` before dropdown rendering
- `bitrateToString()` handles `0L` explicitly

## Self-Check: PASSED

- `android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt` - FOUND, contains `0L ->`
- `lib/view/bluetoothaudio/bluetooth_audio_page.dart` - FOUND, contains `codecSpecific1 == 0 ? 1003 : rawValues.codecSpecific1`
- Commit `8dfc471` - FOUND
