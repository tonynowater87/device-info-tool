---
phase: quick
plan: 2-app-codec
subsystem: bluetooth-audio
tags: [codec, bluetooth, a2dp, reflection, dropdown-ui]
dependency-graph:
  requires: [quick-1-cdm-association]
  provides: [codec-config-switching, codec-capabilities-query]
  affects: [bluetooth_audio_page, bluetooth_audio_cubit, BluetoothAudioHandler]
tech-stack:
  added: []
  patterns: [reflection-based-codec-config, bitmask-parsing, dropdown-selector-pattern]
key-files:
  created: []
  modified:
    - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
    - lib/data/model/bluetooth_audio_model.dart
    - lib/view/bluetoothaudio/bluetooth_audio_state.dart
    - lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
    - lib/view/bluetoothaudio/bluetooth_audio_page.dart
decisions:
  - "Use reflection for both getCodecsSelectableCapabilities and setCodecConfigPreference - consistent with existing hidden API approach"
  - "API 33+ uses BluetoothCodecConfig.Builder, API 26-32 uses constructor with 9 params via reflection"
  - "Dropdown only shown when >1 option available, otherwise static text (avoids single-item dropdowns)"
  - "LDAC quality options hardcoded (990/660/330/ABR) since these are codec-spec constants not returned by capabilities"
metrics:
  duration: "4.6 min"
  completed: "2026-02-15"
---

# Quick Task 2: App Codec Parameter Switching Summary

App 內藍牙 codec 參數即時切換，透過 Android hidden API reflection 取得可選 capabilities 並以 DropdownButton 呈現互動式選擇器

## What Was Built

### Android Native (Task 1)
- **getCodecInfo 擴充**: 透過 `getCodecsSelectableCapabilities()` reflection 取得當前 codec 支援的取樣率/位元深度/聲道模式 bitmask，解析為個別選項清單回傳給 Flutter
- **setBluetoothCodecConfig method channel**: 接收 codecType/sampleRate/bitsPerSample/channelMode/codecSpecific1 參數，透過 reflection 建構 `BluetoothCodecConfig` 並呼叫 `setCodecConfigPreference`
- **Bitmask 解析工具**: `parseSampleRateBitmask`/`parseBitsPerSampleBitmask`/`parseChannelModeBitmask` 將 capability bitmask 拆解為帶標籤的選項列表
- **原始值回傳**: currentCodecType/currentSampleRate/currentBitsPerSample/currentChannelMode/currentCodecSpecific1 供 Flutter 端建構設定請求

### Flutter Side (Task 2)
- **Model 擴充**: 新增 `CodecOption`、`CodecCapabilities`、`CodecRawValues` 類別，`BluetoothAudioInfo` 加入可選 capabilities 和 rawValues
- **State 擴充**: 新增 `BluetoothAudioSettingCodec`（套用中）和 `BluetoothAudioCodecSetError`（設定失敗）狀態
- **Cubit setCodecConfig**: 呼叫 method channel 設定 codec，成功後延遲 500ms 重新載入顯示最新狀態
- **UI 互動化**: sampleRate/bitsPerSample/channelMode 改為 `DropdownButton<int>`，LDAC 時額外顯示品質模式選擇器（990/660/330/ABR），套用中顯示半透明載入覆蓋層

## Deviations from Plan

None - plan executed exactly as written.

## Verification Results

- Android assembleDebug: PASSED
- Flutter analyze (modified files): PASSED (0 errors, 1 pre-existing info)
- Flutter build apk --debug: PASSED

## Self-Check: PASSED

- All 5 modified files verified on disk
- Commit 6f32223: feat(quick-2) native side - FOUND
- Commit a8ac325: feat(quick-2) Flutter side - FOUND
