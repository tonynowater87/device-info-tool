---
phase: quick-8
plan: 8
subsystem: bluetooth-audio-codec-switching
tags: [bluetooth, codec, dropdown, android, flutter, ux]
dependency_graph:
  requires: [quick-2-app-codec, quick-3-getcodecsselectablecapabilities]
  provides: [codec-type-dropdown-ui, selectable-codec-types]
  affects: [BluetoothAudioHandler, bluetooth_audio_model, bluetooth_audio_cubit, bluetooth_audio_page]
tech_stack:
  added: []
  patterns: [reflection-hidden-api, method-channel, cubit-bloc, conditional-dropdown-ui]
key_files:
  created: []
  modified:
    - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
    - lib/data/model/bluetooth_audio_model.dart
    - lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
    - lib/view/bluetoothaudio/bluetooth_audio_page.dart
decisions:
  - "selectableCodecTypes 收集邏輯放在同一迴圈中，避免重複 reflection 呼叫"
  - "CodecCapabilities.fromMap 改為各欄位可選（containsKey 判斷），向後相容無 selectableCodecTypes 的舊裝置"
  - "BluetoothAudioInfo.fromMap 判斷邏輯改為 selectableSampleRates OR selectableCodecTypes 任一存在即建立 capabilities"
  - "setCodecConfig 新增 int? codecType 可選參數，null 時使用既有 rawValues.codecType（向後相容）"
metrics:
  duration: "~8 min"
  completed: "2026-02-19"
  tasks_completed: 2
  files_modified: 4
---

# Quick Task 8: Codec Type 切換功能 Summary

**一行摘要:** 藍牙音訊頁面 Codec Type 從靜態文字改為 DropdownButton，透過遍歷 selectableCapabilities 收集所有可切換 codec，串連 native -> model -> cubit -> UI 完整鏈路。

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Android native 回傳所有可選 codec types + Flutter model/cubit 擴充 | 6c008fa | BluetoothAudioHandler.kt, bluetooth_audio_model.dart, bluetooth_audio_cubit.dart |
| 2 | UI Codec Type DropdownButton 及完整驗證 | edf9274 | bluetooth_audio_page.dart |

## What Was Built

### Android Native (BluetoothAudioHandler.kt)

在 `getCodecInfo` 的 selectable capabilities 迴圈中，同時收集所有 codec types：

```kotlin
val selectableCodecTypes = mutableListOf<Map<String, Any>>()
for (cap in selectableCapabilities) {
    if (cap == null) continue
    val capCodecType = cap.javaClass.getMethod("getCodecType").invoke(cap) as Int
    selectableCodecTypes.add(mapOf(
        "value" to capCodecType,
        "label" to BluetoothCodecConstants.codecTypeToString(capCodecType)
    ))
    // 同時取得當前 codecType 的 sampleRate/bitsPerSample/channelMode capabilities
    if (capCodecType == codecType) { ... }
}
result["selectableCodecTypes"] = selectableCodecTypes
```

### Flutter Model (bluetooth_audio_model.dart)

`CodecCapabilities` 新增 `codecTypes` 欄位，`fromMap` 改為各欄位可選（使用 `containsKey` 判斷）。`BluetoothAudioInfo.fromMap` 的 capabilities 建立條件改為 `selectableSampleRates OR selectableCodecTypes` 任一存在。

### Flutter Cubit (bluetooth_audio_cubit.dart)

`setCodecConfig` 新增可選參數 `int? codecType`，呼叫 method channel 時使用 `codecType ?? currentAudioInfo.rawValues!.codecType`。

### Flutter UI (bluetooth_audio_page.dart)

Codec Type 行改為條件式：

```dart
if (hasCapabilities && capabilities.codecTypes.length > 1)
  _buildDropdownRow(l10n.codecType, rawValues.codecType, capabilities.codecTypes,
    isSettingCodec ? null : (value) {
      if (value != null) {
        cubit.setCodecConfig(codecType: value, sampleRate: ..., ...);
      }
    },
  )
else
  _buildInfoRow(l10n.codecType, audioInfo.codecInfo.codecType),
```

## Decisions Made

1. **同一迴圈收集 selectableCodecTypes**: 避免對每個 capability 重複 reflection 呼叫，與現有 sampleRate/bitsPerSample/channelMode 邏輯合併在同一迴圈。

2. **CodecCapabilities 各欄位改為可選**: 舊裝置（或 API 不支援）可能只有部分欄位，改用 `containsKey` 判斷後回傳空 list，避免 NPE。

3. **OR 條件建立 capabilities**: 有些裝置可能支援 codec 切換但 sampleRate 只有一個選項，反之亦然，兩者任一存在都應建立 capabilities 物件。

4. **向後相容 setCodecConfig**: `codecType` 設為可選參數，現有所有呼叫點不需修改，新增的 codec type dropdown 才傳入新值。

## Deviations from Plan

None - 計劃執行完全按照設計。

## Verification Results

- flutter analyze bluetooth_audio_page.dart: No issues found
- flutter analyze bluetooth_audio_model.dart + bluetooth_audio_cubit.dart: No errors (1 pre-existing info)
- flutter build apk --debug: Built successfully

## Self-Check: PASSED

Files exist:
- FOUND: android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
- FOUND: lib/data/model/bluetooth_audio_model.dart
- FOUND: lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
- FOUND: lib/view/bluetoothaudio/bluetooth_audio_page.dart

Commits:
- FOUND: 6c008fa (Task 1)
- FOUND: edf9274 (Task 2)
