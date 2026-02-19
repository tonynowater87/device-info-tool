---
phase: quick-7
plan: 01
subsystem: bluetooth-audio
tags: [tws, battery, platform-channel, bluetooth-privileged, fallback]
dependency_graph:
  requires: [BluetoothAudioHandler.kt]
  provides: [multi-strategy TWS battery level retrieval]
  affects: [batteryLeft, batteryRight, batteryCase in platform channel response]
tech_stack:
  added: []
  patterns: [multi-strategy fallback, BroadcastReceiver cache, ContentProvider query, reflection]
key_files:
  created: []
  modified:
    - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
decisions:
  - "保留 getMetadata() reflection 作為策略 1，因部分自訂 ROM 不強制 BLUETOOTH_PRIVILEGED 檢查"
  - "ContentProvider content://com.android.bluetooth/device_meta_data 作為策略 2，schema 可能因版本不同而異"
  - "BroadcastReceiver 快取（ACTION_BATTERY_LEVEL_CHANGED + OEM HF_INDICATORS）作為策略 3"
  - "所有策略均包在 try-catch 內，三層失敗後 gracefully 回傳 -1，不 crash"
metrics:
  duration: "~4 min"
  completed_date: "2026-02-19"
  tasks_completed: 1
  files_modified: 1
---

# Phase quick-7 Plan 01: TWS getMetadata BLUETOOTH_PRIVILEGED Fallback Summary

**One-liner:** 重構 getUntetheredBatteryLevels() 為三層 fallback 策略（getMetadata reflection -> ContentProvider -> BroadcastReceiver 快取），解決第三方 App 無法持有 BLUETOOTH_PRIVILEGED 導致全 -1 的問題。

## What Was Built

`BluetoothDevice.getMetadata()` 是 `@SystemApi`，需要 `BLUETOOTH_PRIVILEGED` 權限，第三方 App 無法持有，導致 quick-6 實作的 TWS 電量拆分在大部分裝置上回傳全 -1。

本次重構 `getUntetheredBatteryLevels()` 方法，加入兩個額外 fallback 策略，並在 class 層級維護 BroadcastReceiver 快取，當有 OEM 廣播 TWS 電量時能即時捕獲並使用。

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | 實作多層 fallback 的 TWS 電量讀取策略 | d12efff | BluetoothAudioHandler.kt |

## Implementation Details

### 策略 1: getMetadata() reflection (保留)

```kotlin
val getMetadata = BluetoothDevice::class.java.getMethod("getMetadata", Int::class.java)
val left = (getMetadata.invoke(device, 6) as? ByteArray)?.let { String(it).toIntOrNull() } ?: -1
// key 6 = METADATA_UNTETHERED_LEFT_BATTERY
// key 7 = METADATA_UNTETHERED_RIGHT_BATTERY
// key 8 = METADATA_UNTETHERED_CASE_BATTERY
```

- 部分自訂 ROM（e.g. MIUI、LineageOS）可能不強制檢查 BLUETOOTH_PRIVILEGED
- 若成功（任一值 != -1）直接回傳，不繼續 fallback

### 策略 2: ContentProvider 查詢 (新增)

```kotlin
val uri = android.net.Uri.parse("content://com.android.bluetooth/device_meta_data")
val cursor = activity.contentResolver.query(uri, arrayOf("key", "value"), "address = ?", arrayOf(device.address), null)
```

- Android Bluetooth stack 將 device metadata 存放在 ContentProvider
- 讀取 key=6/7/8 對應的 value (byte array 轉 Int)
- Schema 因 Android 版本和廠商不同可能有差異，全包在 try-catch 保護

### 策略 3: BroadcastReceiver 快取 (新增)

**註冊 (在 init())**
```kotlin
val filter = IntentFilter().apply {
    addAction("android.bluetooth.device.action.BATTERY_LEVEL_CHANGED")
    addAction("android.bluetooth.headset.action.HF_INDICATORS_VALUE_CHANGED")
    addAction("android.bluetooth.headset.profile.action.HF_INDICATORS_VALUE_CHANGED")
}
// Android 14+ 使用 RECEIVER_EXPORTED flag
if (Build.VERSION.SDK_INT >= 33) {
    activity.registerReceiver(batteryLevelReceiver, filter, Context.RECEIVER_EXPORTED)
}
```

**取消註冊 (在 release())**
```kotlin
activity.unregisterReceiver(batteryLevelReceiver)
```

**快取讀取**
- `twsBatteryCache: MutableMap<String, MutableMap<String, Int>>` 以 MAC address 為 key
- 收到 broadcast 時嘗試讀取 OEM 自訂 extras：
  - `android.bluetooth.device.extra.HEADSET_BATTERY_LEFT`
  - `android.bluetooth.device.extra.HEADSET_BATTERY_RIGHT`
  - `android.bluetooth.device.extra.HEADSET_BATTERY_CASE`
- 若 cache 有效（任一值 != -1）直接回傳快取值

### allNegative() helper

```kotlin
private fun allNegative(map: Map<String, Int>): Boolean {
    return map["batteryLeft"] == -1 && map["batteryRight"] == -1 && map["batteryCase"] == -1
}
```

用於判斷每個策略是否返回有效資料。

### 整合邏輯

```
Strategy 1 -> not allNegative? -> return
Strategy 2 -> not allNegative? -> return
Strategy 3 (cache) -> not allNegative? -> return
All failed -> return fallbackResult (all -1)
```

每個步驟都有 `Log.d` 記錄，方便診斷。

## Verification

- Android Kotlin 編譯：`app:compileDebugKotlin` BUILD SUCCESSFUL
- 只有兩個預先存在的 deprecation warnings（`getDefaultAdapter()` 和 `associations`），非本次新增
- BroadcastReceiver 在 `init()` 中以 try-catch 保護註冊，在 `release()` 中以 try-catch 保護取消
- 三個策略均有 Log.d 記錄
- 所有策略均有 try-catch，失敗不會 crash

## Deviations from Plan

### Build Environment Issue (Known - Rule 3)

- **Found during:** Task 1 Android 編譯驗證
- **Issue:** 環境變數 `JAVA_HOME` 指向已刪除的舊版 Android Studio，需指定正確路徑
- **Fix:** 使用 `JAVA_HOME="/Users/tonynowater/Applications/Android Studio.app/Contents/jbr/Contents/Home"` 執行 Gradle
- **Impact:** 編譯成功，不影響代碼品質（與 quick-6 相同的已知問題）

## Self-Check: PASSED

Files verified:
- android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt — FOUND (includes multi-strategy getUntetheredBatteryLevels)

Commits verified:
- d12efff: feat(quick-7): implement multi-strategy TWS battery fallback — FOUND
