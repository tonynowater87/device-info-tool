---
phase: quick-6
plan: 01
subsystem: bluetooth-audio
tags: [tws, battery, platform-channel, localization]
dependency_graph:
  requires: [BluetoothAudioHandler.kt, bluetooth_audio_model.dart, bluetooth_audio_page.dart]
  provides: [batteryLeft, batteryRight, batteryCase via platform channel]
  affects: [bluetooth_audio_page.dart UI, app_localizations.dart]
tech_stack:
  added: []
  patterns: [BluetoothDevice.getMetadata reflection (API 28+), conditional UI rendering]
key_files:
  created: []
  modified:
    - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
    - lib/data/model/bluetooth_audio_model.dart
    - lib/view/bluetoothaudio/bluetooth_audio_page.dart
    - lib/l10n/app_localizations.dart
decisions:
  - "使用 BluetoothDevice.getMetadata(int key) reflection 讀取 untethered battery（key 6/7/8），API 28+ 且優雅降級"
  - "hasUntetheredBattery getter 作為顯示模式切換條件，任一電量 >= 0 即切換為三行顯示"
  - "不可用電量顯示 '--' 而非隱藏，讓使用者了解資訊存在但無法取得"
metrics:
  duration: "~10 min"
  completed_date: "2026-02-19"
  tasks_completed: 2
  files_modified: 4
---

# Phase quick-6 Plan 01: TWS 耳機左耳/右耳/充電盒電量拆分顯示 Summary

**One-liner:** 透過 BluetoothDevice.getMetadata reflection 讀取 METADATA_UNTETHERED_*_BATTERY，Flutter 端條件式顯示左耳/右耳/充電盒三行電量取代單一電量行。

## What Was Built

TWS (True Wireless Stereo) 耳機連線時，裝置資訊卡片從原本的單一電量行改為分別顯示左耳、右耳、充電盒三行電量，方便使用者了解各組件的電量狀態。非 TWS 裝置（或 API < 28）維持原有單一電量顯示，完全向後相容。

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Android 端讀取 TWS 耳機分離電量 | 0dbc69a | BluetoothAudioHandler.kt |
| 2 | Flutter Model + UI 顯示拆分電量 | b5db8a4 | bluetooth_audio_model.dart, bluetooth_audio_page.dart, app_localizations.dart |

## Implementation Details

### Task 1: Android (BluetoothAudioHandler.kt)

新增 `getUntetheredBatteryLevels(device: BluetoothDevice)` 方法：
- API < 28 直接返回 -1（不支援）
- 透過 reflection 呼叫 `BluetoothDevice.getMetadata(Int)`
  - key 6 = METADATA_UNTETHERED_LEFT_BATTERY (左耳)
  - key 7 = METADATA_UNTETHERED_RIGHT_BATTERY (右耳)
  - key 8 = METADATA_UNTETHERED_CASE_BATTERY (充電盒)
- 返回值為 ByteArray，轉為 String 再 `toIntOrNull()` 取得百分比整數
- 任何例外都被捕獲並返回 -1
- 在 `getBluetoothAudioInfo` 中透過 `putAll` 加入回傳 Map

### Task 2: Flutter Model + UI + L10n

**bluetooth_audio_model.dart:**
- `BluetoothDeviceInfo` 新增 `batteryLeft?`, `batteryRight?`, `batteryCase?` 欄位
- `fromMap` 從 platform channel Map 讀取對應 key
- `hasUntetheredBattery` getter：任一電量 >= 0 則為 true
- `formattedBatteryLeft/Right/Case` getter：-1 或 null 顯示 '--'，否則顯示 '$level%'

**app_localizations.dart:**
- 10 個語系加入 `battery_left`, `battery_right`, `battery_case` 翻譯鍵：
  - en: Left Ear / Right Ear / Case
  - zh_TW: 左耳 / 右耳 / 充電盒
  - zh_CN: 左耳 / 右耳 / 充电盒
  - ja: 左耳 / 右耳 / ケース
  - ko: 왼쪽 / 오른쪽 / 케이스
  - es: Izquierdo / Derecho / Estuche
  - fr: Gauche / Droite / Boîtier
  - de: Links / Rechts / Etui
  - ar: اليسرى / اليمنى / العلبة
  - pt: Esquerdo / Direito / Estojo
- 加入 `batteryLeft`, `batteryRight`, `batteryCase` getter

**bluetooth_audio_page.dart:**
- 裝置資訊卡片條件式顯示：
  - `hasUntetheredBattery == true` → 顯示 3 行（左耳/右耳/充電盒）
  - `hasUntetheredBattery == false` → 顯示原有單一電量行

## Verification

- Android 編譯：`assembleDebug --quiet` 通過（只有 Java 8 target deprecation 警告，非 Kotlin 錯誤）
- Flutter 分析：`flutter analyze --no-fatal-infos lib/` 在 lib/ 目錄中無 error（test/ 目錄有預先存在的 db_test.dart 錯誤，與本次修改無關）

## Deviations from Plan

### Build Environment Issue (Auto-fixed - Rule 3)

- **Found during:** Task 1 Android 編譯驗證
- **Issue:** 環境變數 `JAVA_HOME` 指向舊版已刪除的 Android Studio (`Android Studio-2021.1.1.22-mac-m1-chip.app`)，且需要 Java 17+
- **Fix:** 自動尋找並使用 `/Users/tonynowater/Applications/Android Studio.app/Contents/jbr/Contents/Home`（OpenJDK 21），指定正確 JAVA_HOME 執行 Gradle 編譯
- **Impact:** 編譯成功，不影響代碼品質

## Self-Check: PASSED

Files verified:
- android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt — FOUND (includes getUntetheredBatteryLevels)
- lib/data/model/bluetooth_audio_model.dart — FOUND (includes batteryLeft/Right/Case)
- lib/view/bluetoothaudio/bluetooth_audio_page.dart — FOUND (includes hasUntetheredBattery conditional)
- lib/l10n/app_localizations.dart — FOUND (includes battery_left/right/case in 10 locales)

Commits verified:
- 0dbc69a: feat(quick-6): Android 端讀取 TWS 耳機分離電量 — FOUND
- b5db8a4: feat(quick-6): Flutter Model + UI 顯示 TWS 拆分電量 — FOUND
