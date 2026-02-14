---
phase: quick
plan: 1
type: execute
wave: 1
depends_on: []
files_modified:
  - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
  - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/MainActivity.kt
  - android/app/src/main/AndroidManifest.xml
autonomous: true
must_haves:
  truths:
    - "Android 16 裝置上呼叫 getCodecStatus 不會拋出 SecurityException"
    - "Android 15 及以下裝置行為不受影響（無 CDM 流程）"
    - "CDM association 失敗時，codec 資訊顯示為 Unknown 而非錯誤"
  artifacts:
    - path: "android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt"
      provides: "CDM association 邏輯 + 優雅降級"
    - path: "android/app/src/main/AndroidManifest.xml"
      provides: "COMPANION_DEVICE feature 宣告"
  key_links:
    - from: "BluetoothAudioHandler.kt"
      to: "CompanionDeviceManager"
      via: "associateDevice before getCodecStatus on API 36+"
---

<objective>
修復 Android 16 (API 36) 上 BluetoothA2dp.getCodecStatus() 因缺少 CDM association 而拋出 SecurityException 的問題。

Purpose: 讓 Pixel 8 等 Android 16 裝置能正常顯示藍牙音訊 codec 資訊。
Output: 修改後的 BluetoothAudioHandler.kt，在 Android 16+ 上先建立 CDM association 再呼叫 codec API，並在 association 失敗時優雅降級。
</objective>

<execution_context>
@/Users/tonynowater/.claude/get-shit-done/workflows/execute-plan.md
@/Users/tonynowater/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
@android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/MainActivity.kt
@android/app/src/main/AndroidManifest.xml
@android/app/build.gradle
</context>

<tasks>

<task type="auto">
  <name>Task 1: AndroidManifest 新增 companion device feature</name>
  <files>android/app/src/main/AndroidManifest.xml</files>
  <action>
在 AndroidManifest.xml 中新增 companion device 相關宣告：

1. 在 `<manifest>` 內、`<application>` 之前新增：
   ```xml
   <uses-feature android:name="android.software.companion_device_setup" android:required="false" />
   ```
   `required="false"` 確保不具備 CDM 的裝置仍可安裝此 app。

注意：不需要額外的 `<uses-permission>`，因為 `CompanionDeviceManager.associate()` 本身不需要特殊權限，只需要 BLUETOOTH_CONNECT（已有）。
  </action>
  <verify>確認 AndroidManifest.xml 格式正確，uses-feature 在 application 標籤之前</verify>
  <done>AndroidManifest.xml 包含 companion_device_setup feature 宣告</done>
</task>

<task type="auto">
  <name>Task 2: BluetoothAudioHandler 加入 CDM association 與優雅降級</name>
  <files>
    android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
    android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/MainActivity.kt
  </files>
  <action>
修改 BluetoothAudioHandler.kt，在 Android 16+ (Build.VERSION.SDK_INT >= 36) 上，於呼叫 getCodecStatus 前先嘗試建立 CDM association。

**策略：優雅降級（非阻塞式）**

因為 CDM association 需要用戶互動（系統會彈出配對對話框），而且 `getCodecStatus` 只是顯示資訊而非核心功能，採用以下策略：

1. **在 `getCodecInfo()` 方法中**，修改 `InvocationTargetException` catch block（第 190-194 行）：
   - 檢查 cause 是否為 `SecurityException`
   - 若是且包含 "CDM association" 關鍵字，返回裝置基本資訊但 codec 欄位填入 "需要配對授權" 的提示
   - 具體做法：設定 `result["codecType"] = "Unknown (需要裝置配對)"`，並同時設定其他 codec 欄位為 "Unknown"，**不要**設定 `error` key，這樣前端會當作成功回應但 codec 值為 Unknown

2. **新增 `ensureCdmAssociation()` 方法**：
   - 接收 `BluetoothDevice` 參數和一個 callback `(Boolean) -> Unit`
   - 僅在 `Build.VERSION.SDK_INT >= 36` 時執行 CDM 流程
   - 使用 `CompanionDeviceManager` 的 `associate()` API：
     ```kotlin
     val deviceFilter = BluetoothDeviceFilter.Builder()
         .setAddress(device.address)
         .build()
     val pairingRequest = AssociationRequest.Builder()
         .addDeviceFilter(deviceFilter)
         .setSingleDevice(true)
         .build()
     val companionDeviceManager = activity.getSystemService(Context.COMPANION_DEVICE_SERVICE) as CompanionDeviceManager
     ```
   - 先檢查是否已有 association（`companionDeviceManager.associations` 是否包含 device.address），若已有則直接 callback(true)
   - 若無 association，呼叫 `companionDeviceManager.associate(pairingRequest, callback, handler)`
   - Callback 實作：
     - `onDeviceFound`: 取得 IntentSender，透過 `activity.startIntentSenderForResult()` 啟動配對 UI
     - `onFailure`: callback(false)，不阻塞流程
   - 需要注意 API level 差異：API 33+ 使用新的 `Executor` callback 版本

3. **修改 `getBluetoothAudioInfo()` 流程**：
   - 在取得 `connectedDevices[0]` 後、呼叫 `getCodecInfo()` 前
   - 若 `Build.VERSION.SDK_INT >= 36`，先呼叫 `ensureCdmAssociation(device)`
   - 但由於 association 是非同步的（需要用戶互動），第一次呼叫可能還沒有 association
   - 所以主要的防護是在 `getCodecInfo()` 的 catch block：捕獲到 CDM SecurityException 時返回 Unknown 值而非 error

4. **修改 MainActivity.kt**：
   - 新增 `onActivityResult()` override 以處理 CDM association 的 `startIntentSenderForResult` 回調
   - 將 result 轉發給 `BluetoothAudioHandler`
   - 使用 request code 常數（例如 `REQUEST_CODE_CDM_ASSOCIATION = 1001`）

**關鍵實作細節：**
- import 需要新增：`android.companion.CompanionDeviceManager`, `android.companion.AssociationRequest`, `android.companion.BluetoothDeviceFilter`, `android.content.Context`, `android.content.IntentSender`, `android.os.Handler`, `android.os.Looper`
- CDM API 是 API 26+ 可用，但我們只在 API 36+ 才使用（因為只有 Android 16 才有這個限制）
- `companionDeviceManager.associations` 返回的是 `List<String>`（MAC 地址），直接比較 `device.address`
- 若 CDM association 成功後用戶再次查詢，codec 資訊就能正常顯示

**最重要的修改（最小可行修復）：**
即使 CDM association 流程較複雜，最關鍵的是 `getCodecInfo()` 第 190-194 行的 catch block 修改。確保 CDM SecurityException 不會導致顯示錯誤頁面，而是顯示裝置名稱 + "codec 資訊不可用" 的友善訊息。這是保底邏輯，無論 CDM association 是否成功都能確保 app 不會崩潰或顯示錯誤。
  </action>
  <verify>
1. `cd /Users/tonynowater/Documents/my-project/front-end-app/flutter/mobile-os-versions && flutter build apk --debug 2>&1 | tail -20` 確認編譯通過
2. 確認 BluetoothAudioHandler.kt 中 InvocationTargetException catch block 有處理 CDM SecurityException
3. 確認 ensureCdmAssociation 方法存在且有 API level 檢查
  </verify>
  <done>
- Android 16 上 SecurityException (CDM) 被捕獲並優雅降級為 "Unknown" codec 值
- CDM association 流程可在背景建立，成功後下次查詢即可顯示 codec 資訊
- Android 15 及以下不受任何影響（CDM 流程被 API level check 跳過）
- App 編譯通過無錯誤
  </done>
</task>

</tasks>

<verification>
1. `flutter build apk --debug` 編譯通過
2. BluetoothAudioHandler.kt 包含 CDM association 邏輯（API 36+ guard）
3. InvocationTargetException catch block 能識別 CDM SecurityException 並優雅降級
4. AndroidManifest.xml 包含 companion_device_setup feature
</verification>

<success_criteria>
- Android 16 裝置上藍牙音訊頁面不再顯示錯誤，而是顯示裝置名稱 + codec 為 Unknown（首次）或正常 codec 值（CDM association 成功後）
- Android 15 及以下裝置行為完全不變
- Debug APK 建置成功
</success_criteria>

<output>
After completion, create `.planning/quick/1-android-16-cdm-association-securityexcep/1-SUMMARY.md`
</output>
