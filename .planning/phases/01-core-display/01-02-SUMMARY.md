---
phase: 01-core-display
plan: 02
subsystem: data-layer
tags: [flutter, bloc, permission-handler, device-info-plus, bluetooth, state-management]

# Dependency graph
requires:
  - phase: 01-core-display
    provides: "Plan 01 provided Android native Bluetooth audio implementation"
provides:
  - "Flutter data models for Bluetooth audio info (device, codec, bitrate)"
  - "State management with BluetoothAudioCubit handling permissions and errors"
  - "Permission handling for Android 12+ Bluetooth permissions"
  - "Platform channel integration ready for native method calls"
affects: [01-03, ui-implementation, bluetooth-display]

# Tech tracking
tech-stack:
  added:
    - permission_handler ^11.0.0
  patterns:
    - "Cubit pattern for state management (consistent with existing AndroidDeviceInfoCubit)"
    - "Platform channel invocation with error handling"
    - "Android version checking with device_info_plus"
    - "Comprehensive state modeling for all edge cases"

key-files:
  created:
    - lib/data/model/bluetooth_audio_model.dart
    - lib/view/bluetoothaudio/bluetooth_audio_state.dart
    - lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
  modified:
    - pubspec.yaml

key-decisions:
  - "使用專案現有的 device_info_plus 進行版本檢查（無需額外依賴）"
  - "藍牙版本欄位固定為「不支援」（Android API 限制，參考 RESEARCH.md）"
  - "完整的狀態建模涵蓋所有錯誤情況（權限、版本、藍牙關閉、無裝置）"

patterns-established:
  - "part of pattern: State 類別作為 Cubit 的 part（符合專案慣例）"
  - "Error response handling: 檢查 Map 中的 'error' key 來判斷原生端錯誤類型"
  - "Permission flow: 檢查狀態 → 請求（如需要）→ 處理拒絕/永久拒絕"

# Metrics
duration: 2min
completed: 2026-02-08
---

# Phase 01 Plan 02: Flutter 資料層與狀態管理 Summary

**Flutter 端完整資料模型（包含 bitrate 和 bluetoothVersion）與 Cubit 狀態管理，處理 Android 12+ 權限與所有錯誤情況**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-08T11:04:05Z
- **Completed:** 2026-02-08T11:06:51Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments
- 建立完整的藍牙音訊資料模型（BluetoothDeviceInfo、BluetoothCodecInfo、BluetoothAudioInfo），包含必要的 bitrate 和 bluetoothVersion 欄位
- 實作 BluetoothAudioCubit 狀態管理，涵蓋 10 種狀態（初始、載入、權限、錯誤、成功等）
- 整合 permission_handler 處理 Android 12+ 的藍牙連接權限
- 使用專案現有的 device_info_plus 進行 Android 版本檢查（避免重複依賴）

## Task Commits

Each task was committed atomically:

1. **Task 1: 新增 permission_handler 依賴** - `55c08e9` (chore)
2. **Task 2: 建立 BluetoothAudioModel 資料模型** - `a75802f` (feat)
3. **Task 3: 建立 BluetoothAudioState 與 BluetoothAudioCubit** - `d52aa64` (feat)

## Files Created/Modified
- `pubspec.yaml` - 新增 permission_handler ^11.0.0 依賴
- `lib/data/model/bluetooth_audio_model.dart` - 三層資料模型（DeviceInfo、CodecInfo、AudioInfo），包含 fromMap factory constructors 和格式化輔助方法
- `lib/view/bluetoothaudio/bluetooth_audio_state.dart` - 10 種狀態類別定義（Initial、Loading、PermissionRequired、PermissionDenied、NotSupported、BluetoothDisabled、NoDevice、Loaded、Error）
- `lib/view/bluetoothaudio/bluetooth_audio_cubit.dart` - 狀態管理邏輯，包含 load()、openSettings()、retry() 方法

## Decisions Made

**1. 使用專案現有的 device_info_plus**
- 專案已包含此依賴用於其他功能，直接使用避免重複
- 用於檢查 Android 版本（SDK 26+ 支援，SDK 31+ 需要權限）

**2. 藍牙版本欄位固定為「不支援」**
- 根據 RESEARCH.md："Android 沒有公開 API 取得藍牙版本號"
- 在模型中保留此欄位供未來可能的實作，但目前固定返回「不支援」

**3. 完整的錯誤狀態建模**
- 參考現有 AndroidDeviceInfoCubit 模式
- 涵蓋所有可能的錯誤情況：平台不支援、版本過低、權限拒絕/永久拒絕、藍牙關閉、無連接裝置、其他錯誤

## Deviations from Plan

None - 計劃執行完全符合規格。

## Issues Encountered

None - 所有任務順利完成，無阻礙問題。

## User Setup Required

None - 無需外部服務配置。

注意：權限設定已在 Plan 01 的 AndroidManifest.xml 中完成，此計劃僅處理執行時權限請求。

## Next Phase Readiness

**已完成：**
- Flutter 端資料結構完整建立
- 狀態管理邏輯已實作並通過分析
- Platform Channel 整合已準備好（awaiting native implementation from Plan 01）

**下一步準備：**
- 等待 Plan 01 的原生端實作完成後，可進行整合測試
- 準備建立 UI 層（BluetoothAudioPage）顯示資料

**無阻礙因素** - 一切準備就緒進入 UI 實作階段

## Self-Check: PASSED

All created files verified:
- lib/data/model/bluetooth_audio_model.dart
- lib/view/bluetoothaudio/bluetooth_audio_state.dart
- lib/view/bluetoothaudio/bluetooth_audio_cubit.dart

All commits verified:
- 55c08e9 (Task 1)
- a75802f (Task 2)
- d52aa64 (Task 3)

---
*Phase: 01-core-display*
*Completed: 2026-02-08*
