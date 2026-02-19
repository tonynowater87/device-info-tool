---
phase: quick-7
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
autonomous: true
must_haves:
  truths:
    - "getMetadata() 失敗時（回傳全 -1），自動 fallback 到 BroadcastReceiver 方式取得 TWS 電量"
    - "有 BLUETOOTH_PRIVILEGED 的裝置（如部分 ROM）仍可透過 getMetadata() 取得 TWS 電量"
    - "完全無法取得 TWS 電量時，gracefully 回傳 -1，UI 不顯示拆分電量（已有此邏輯）"
  artifacts:
    - path: "android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt"
      provides: "Multi-strategy TWS battery level retrieval"
      contains: "ACTION_BATTERY_LEVEL_CHANGED"
  key_links:
    - from: "BluetoothAudioHandler.getUntetheredBatteryLevels"
      to: "deviceInfo map"
      via: "putAll in getBluetoothAudioInfo"
      pattern: "deviceInfo.putAll.*getUntetheredBatteryLevels"
---

<objective>
修復 TWS 電量拆分在第三方 App 無法取得的問題。

Purpose: `BluetoothDevice.getMetadata()` 是 `@SystemApi`，需要 `BLUETOOTH_PRIVILEGED` 權限，第三方 App 無法持有此權限，導致 left/right/case 電量全部回傳 -1。需要加入 fallback 策略，嘗試從 Android Bluetooth ContentProvider 讀取 metadata。

Output: 修改後的 BluetoothAudioHandler.kt，具備多層 fallback 的 TWS 電量讀取能力。
</objective>

<execution_context>
@/Users/tonynowater/.claude/get-shit-done/workflows/execute-plan.md
@/Users/tonynowater/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
@lib/data/model/bluetooth_audio_model.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: 實作多層 fallback 的 TWS 電量讀取策略</name>
  <files>android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt</files>
  <action>
重構 `getUntetheredBatteryLevels()` 方法，加入多層 fallback 策略：

**策略 1 (保留): getMetadata() reflection**
- 保留現有的 `getMetadata(int)` reflection 呼叫（keys 6/7/8）
- 部分自訂 ROM 不強制檢查 BLUETOOTH_PRIVILEGED，仍可成功
- 加入 debug log 記錄每個值的結果（方便排查）

**策略 2 (新增): ContentProvider 查詢**
- 如果策略 1 回傳全 -1，嘗試透過 ContentResolver 查詢 `content://com.android.bluetooth/devices`
- 查詢條件: `address = ?` 使用目前連線裝置的 MAC address
- 讀取 metadata 欄位，該欄位是 byte array，其中包含 untethered battery 資訊
- 注意: 不同 Android 版本的 ContentProvider schema 可能不同，需要 try-catch 保護
- 需要在方法簽名加入 Context 參數（用 `activity` 存取 contentResolver）

**策略 3 (新增): Intent Extra 從快取讀取**
- 註冊一個 BroadcastReceiver 監聽 `android.bluetooth.device.action.BATTERY_LEVEL_CHANGED`
- 在 class 層級維護一個 `twsBatteryCache: MutableMap<String, Map<String, Int>>`，key 是 device address
- BroadcastReceiver 在 `init()` 中註冊，在 `release()` 中取消註冊
- 收到 broadcast 時解析 Intent extras:
  - `android.bluetooth.device.extra.BATTERY_LEVEL` (整體電量)
  - 嘗試讀取 extra 中的 untethered 相關資料（如果有的話）
- 注意: 標準 `ACTION_BATTERY_LEVEL_CHANGED` 只提供整體電量，不一定有 left/right/case 拆分。但部分 OEM（如 Samsung、Google Pixel）會在自定義 Intent 中包含此資訊
- 如果 cache 中有該裝置的 TWS 電量，直接使用

**整合邏輯修改:**
- `getUntetheredBatteryLevels()` 方法改為: 策略1 -> 策略2 -> 策略3(cache) -> 全回傳 -1
- 每個策略都加 Log.d 記錄嘗試結果
- 判斷「全 -1」的 helper function: `private fun allNegative(map: Map<String, Int>): Boolean`

**重要注意事項:**
- ContentProvider 查詢可能會拋出 SecurityException 或回傳 null cursor，務必 try-catch
- BroadcastReceiver 註冊需要考慮 Android 14+ 的 RECEIVER_EXPORTED / RECEIVER_NOT_EXPORTED flag
- 不修改 Flutter 端任何程式碼，回傳格式不變（batteryLeft/batteryRight/batteryCase 仍為 Int）
  </action>
  <verify>
1. `cd /Users/tonynowater/Documents/my-project/front-end-app/flutter/mobile-os-versions && ./gradlew -p android app:compileDebugKotlin 2>&1 | tail -5` 編譯成功無錯誤
2. 確認 Log.d 訊息在 getUntetheredBatteryLevels 中每個策略都有記錄
3. 確認 BroadcastReceiver 在 init() 註冊、release() 取消註冊
  </verify>
  <done>
BluetoothAudioHandler.kt 的 getUntetheredBatteryLevels() 具備三層 fallback 策略（getMetadata -> ContentProvider -> BroadcastReceiver cache），編譯通過，回傳格式與原本一致。
  </done>
</task>

</tasks>

<verification>
- Android Kotlin 編譯通過
- getUntetheredBatteryLevels 包含三個 fallback 策略
- BroadcastReceiver 生命週期正確管理（init 註冊 / release 取消）
- 所有新增程式碼都有 try-catch 保護，不會導致 crash
</verification>

<success_criteria>
- `./gradlew -p android app:compileDebugKotlin` 成功
- 程式碼中可見三個策略的嘗試邏輯與 Log 輸出
- 即使三個策略都失敗，仍 gracefully 回傳 -1（不 crash）
</success_criteria>

<output>
After completion, create `.planning/quick/7-tws-getmetadata-bluetooth-privileged/7-SUMMARY.md`
</output>
