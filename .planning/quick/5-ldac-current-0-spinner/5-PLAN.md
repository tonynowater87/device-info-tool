---
phase: quick-5
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
  - lib/view/bluetoothaudio/bluetooth_audio_page.dart
autonomous: true
must_haves:
  truths:
    - "LDAC bitrate 顯示正確的品質標籤（如 990 kbps、ABR）而非 Current (0)"
    - "LDAC bitrate spinner 下拉可正常選取並切換品質等級"
  artifacts:
    - path: "android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt"
      provides: "LDAC codecSpecific1 value 0 mapped to ABR"
      contains: "0L ->"
    - path: "lib/view/bluetoothaudio/bluetooth_audio_page.dart"
      provides: "LDAC dropdown with value 0 as valid ABR option"
      contains: "CodecOption(value: 0"
  key_links:
    - from: "BluetoothAudioHandler.kt bitrateToString()"
      to: "bluetooth_audio_page.dart LDAC dropdown options"
      via: "codecSpecific1 value mapping must be consistent"
      pattern: "value.*0.*ABR"
---

<objective>
Fix LDAC bitrate displaying "Current (0)" and spinner items being unselectable.

Purpose: When LDAC is in ABR (adaptive bitrate) mode, Android's getCodecSpecific1() returns 0 (not 1003). The Flutter dropdown options only list 1000-1003, so value 0 has no match, triggering the fallback "Current (0)" label. This also causes spinner selection issues because the dropdown value/options mismatch confuses Flutter's DropdownButton.

Output: LDAC bitrate correctly shows "ABR" when codecSpecific1 is 0, and all quality levels are selectable from the spinner.
</objective>

<context>
@android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
@lib/view/bluetoothaudio/bluetooth_audio_page.dart
@lib/data/model/bluetooth_audio_model.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Fix LDAC codecSpecific1=0 mapping and dropdown options</name>
  <files>
    android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
    lib/view/bluetoothaudio/bluetooth_audio_page.dart
  </files>
  <action>
Two changes needed to fix both bugs (same root cause):

1. **BluetoothAudioHandler.kt** - In `bitrateToString()` (around line 613), the `else` branch already maps unknown values to "ABR". This is correct but implicit. Make it explicit by adding `0L ->` as a case:

```kotlin
when (codecSpecific1) {
    0L -> "ABR (自適應)"      // <-- ADD: Android returns 0 for ABR/Best Effort mode
    1000L -> "990 kbps (最高品質)"
    1001L -> "660 kbps (標準)"
    1002L -> "330 kbps (連接優先)"
    1003L -> "ABR (自適應)"
    else -> "ABR (自適應)"
}
```

2. **bluetooth_audio_page.dart** - In `_buildLoadedView()` around line 339-358, the LDAC dropdown section has hardcoded options [1000, 1001, 1002, 1003]. Add value `0` as ABR option AND reorder so the current-value matching works:

```dart
if (hasCapabilities && rawValues.codecType == 4) // LDAC
  _buildDropdownRow(
    l10n.bitrate,
    rawValues.codecSpecific1,
    [
      CodecOption(value: 1000, label: '990 kbps'),
      CodecOption(value: 1001, label: '660 kbps'),
      CodecOption(value: 1002, label: '330 kbps'),
      CodecOption(value: 1003, label: 'ABR'),
      CodecOption(value: 0, label: 'ABR'),  // <-- ADD: Android returns 0 for default ABR
    ],
    ...
```

Note: Both value 0 and 1003 map to ABR because:
- Android returns 0 when LDAC is in default/ABR mode (getCodecSpecific1 default)
- Android returns 1003 when ABR was explicitly set via setCodecConfigPreference
- When user selects ABR from dropdown, send value 1003 (the explicit ABR constant)

To handle this cleanly, we should keep value 0 in the list for matching but when the user taps ABR, always send 1003. So the dropdown should only show ONE ABR entry. The fix: if codecSpecific1 is 0, treat it as 1003 before passing to the dropdown. Modify the LDAC dropdown block:

```dart
if (hasCapabilities && rawValues.codecType == 4) // LDAC
  _buildDropdownRow(
    l10n.bitrate,
    // Normalize: Android returns 0 for ABR default, map to 1003 (explicit ABR constant)
    rawValues.codecSpecific1 == 0 ? 1003 : rawValues.codecSpecific1,
    [
      CodecOption(value: 1000, label: '990 kbps'),
      CodecOption(value: 1001, label: '660 kbps'),
      CodecOption(value: 1002, label: '330 kbps'),
      CodecOption(value: 1003, label: 'ABR'),
    ],
    isSettingCodec ? null : (value) { ... same callback ... },
  )
```

This is the CLEANEST fix: normalize `0 -> 1003` at the UI layer so DropdownButton always finds a match, and selecting ABR always sends 1003. No duplicate entries, no fallback "Current" needed.
  </action>
  <verify>
    1. Run `cd /Users/tonynowater/Documents/my-project/front-end-app/flutter/mobile-os-versions && flutter analyze` - no errors
    2. Verify the LDAC dropdown options list contains exactly 4 entries (990/660/330/ABR)
    3. Verify codecSpecific1==0 is normalized to 1003 before dropdown rendering
    4. Verify bitrateToString handles 0L explicitly
  </verify>
  <done>
    - LDAC bitrate shows "ABR" (not "Current (0)") when codecSpecific1 is 0
    - Dropdown contains 4 selectable options with no duplicate values
    - Selecting any quality level from spinner triggers setCodecConfig correctly
  </done>
</task>

</tasks>

<verification>
1. `flutter analyze` passes with no errors
2. Connect to LDAC device, verify bitrate shows proper label (not "Current (0)")
3. Tap bitrate spinner, verify all 4 options appear and are selectable
4. Select different quality levels, verify codec switches successfully
</verification>

<success_criteria>
- LDAC bitrate row displays correct quality label (990 kbps / 660 kbps / 330 kbps / ABR)
- Bitrate spinner dropdown shows 4 options and each is selectable
- Selecting a quality level triggers codec config change and refreshes display
</success_criteria>

<output>
After completion, create `.planning/quick/5-ldac-current-0-spinner/5-SUMMARY.md`
</output>
