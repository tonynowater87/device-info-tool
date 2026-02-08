# Android Bluetooth A2DP Codec 控制常見陷阱

**領域:** Android Bluetooth A2DP 音訊編碼控制
**研究日期:** 2026-02-08
**專案背景:** Flutter app 透過 Platform Channel 新增藍牙音訊裝置資訊與 codec 切換功能

---

## 關鍵陷阱(Critical Pitfalls)

會導致功能無法運作、需要大量重構或安全性問題的嚴重錯誤。

### 陷阱 1: Hidden API 依賴導致功能失效

**錯誤行為:**
使用 `BluetoothA2dp.setCodecConfigPreference()` 這個被標記為 `@hide` 的非公開 API 來切換 codec,導致在不同 Android 版本上行為不一致或完全失效。

**發生原因:**
- Android Bluetooth A2DP 的 codec 控制 API 大部分被標記為 `@hide`
- 這些 API 僅供系統 Settings app 使用
- Google 從 Android 9 (API 28) 開始嚴格限制 hidden API 訪問
- Android 12+ 更進一步收緊限制,reflection 訪問會直接失敗

**嚴重後果:**
- App 在新版 Android 上無法切換 codec
- 可能通過 Google Play 審查時被拒絕
- 未來 Android 版本可能完全移除這些 API
- 需要完全重寫功能架構

**預防策略:**
1. **不要使用 hidden API** — 即使現在能用,未來一定會出問題
2. **使用系統 Developer Options 作為替代方案:**
   - 透過 Intent 引導用戶到 Developer Options 的 Bluetooth codec 設定
   - 使用 `Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)`
3. **只讀取 codec 狀態,不嘗試控制:**
   - `BluetoothA2dp.getCodecStatus()` 是公開 API (API 26+)
   - 顯示當前 codec 資訊供用戶參考
   - 引導用戶手動到 Developer Options 切換

**偵測警訊:**
- 編譯時需要修改 android.jar 才能訪問方法
- 使用 reflection 繞過編譯檢查
- 在新版 Android 上功能突然失效
- Logcat 出現 "Accessing hidden method/field" 警告

**建議處理階段:**
- **Phase 1 (架構設計):** 必須明確定義是「唯讀資訊顯示」還是「控制切換」
- **Phase 2 (API 整合):** 如果需要切換功能,設計 Intent 引導流程而非直接呼叫 hidden API

**信心等級:** HIGH
**資料來源:**
- [BluetoothA2dp Source Code](https://github.com/matisiekpl/bluetooth-codec-change)
- [Android Hidden API Restrictions](https://developer.android.com/distribute/best-practices/develop/restrictions-non-sdk-interfaces)

---

### 陷阱 2: Android 12+ 藍牙權限處理錯誤

**錯誤行為:**
僅在 AndroidManifest.xml 宣告 `BLUETOOTH_CONNECT` 權限,但沒有在 runtime 請求使用者授權,導致 `SecurityException` 或 `PlatformException` 讓 app 崩潰。

**發生原因:**
- Android 12 (API 31) 引入新的藍牙權限模型
- `BLUETOOTH_CONNECT` 是 runtime permission,不是 install-time permission
- Flutter Platform Channel 呼叫原生 Bluetooth API 時會檢查權限
- 舊版 `BLUETOOTH` 權限在 API 31+ 已不足夠

**嚴重後果:**
- App 在 Android 12+ 裝置上無法取得藍牙裝置資訊
- 使用者看到 "Permission denied" 錯誤
- 在 targetSdkVersion 33 (Google Play 2023 要求) 時功能完全無法運作
- 使用者體驗極差,無法理解為何功能失效

**預防策略:**
1. **正確的 Manifest 宣告:**
```xml
<!-- 舊版相容 -->
<uses-permission android:name="android.permission.BLUETOOTH"
                 android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"
                 android:maxSdkVersion="30" />

<!-- Android 12+ 必需 -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- 如果需要掃描藍牙裝置(本專案不需要) -->
<!-- <uses-permission android:name="android.permission.BLUETOOTH_SCAN" /> -->
```

2. **在 Flutter 端處理權限請求:**
```dart
// 使用 permission_handler package
if (Platform.isAndroid) {
  if (await Permission.bluetoothConnect.request().isGranted) {
    // 呼叫 Platform Channel
  } else {
    // 顯示權限拒絕說明
  }
}
```

3. **在 Kotlin Platform Channel handler 檢查權限:**
```kotlin
private fun checkBluetoothPermission(): Boolean {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.BLUETOOTH_CONNECT
        ) == PackageManager.PERMISSION_GRANTED
    }
    return true // API 30 以下不需要 runtime permission
}
```

**偵測警訊:**
- App 在 Android 11 能運作,Android 12 就失效
- Logcat 出現 "Need android.permission.BLUETOOTH_CONNECT" 錯誤
- Flutter Platform Channel 拋出 PlatformException
- Google Play Console 顯示大量 SecurityException crash

**建議處理階段:**
- **Phase 1 (基礎架構):** 設定 permission_handler 套件與權限檢查流程
- **Phase 2 (Platform Channel):** 在每個 Bluetooth API 呼叫前檢查權限
- **Phase 3 (UI):** 設計權限請求 UI 與被拒絕時的說明畫面

**信心等級:** HIGH
**資料來源:**
- [Android Bluetooth Permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions)
- [Flutter Permission Handler Issues](https://github.com/Baseflow/flutter-permission-handler/issues/1248)

---

### 陷阱 3: Codec 狀態 Null Pointer Exception

**錯誤行為:**
直接呼叫 `bluetoothA2dp.getCodecStatus(device)` 後,未檢查 null 就訪問 codec config,導致 `NullPointerException` 讓 app 崩潰。

**發生原因:**
- `getCodecStatus()` 在以下情況會返回 null:
  - 沒有連接任何 A2DP 裝置
  - 裝置剛連接,codec negotiation 尚未完成
  - 裝置連接中斷但狀態尚未更新
  - BluetoothDevice 參數為 null

**嚴重後果:**
- App 崩潰,使用者體驗極差
- 在藍牙裝置連接/斷線時特別容易發生
- 難以復現,因為與連接時序有關

**預防策略:**
1. **永遠檢查 null:**
```kotlin
val codecStatus = bluetoothA2dp.getCodecStatus(device)
if (codecStatus == null) {
    // 返回預設值或錯誤狀態
    result.success(mapOf("error" to "Codec status not available"))
    return
}

val codecConfig = codecStatus.codecConfig
if (codecConfig == null) {
    result.success(mapOf("error" to "Codec not configured"))
    return
}
```

2. **監聽連接狀態變化:**
```kotlin
// 註冊 BroadcastReceiver 監聽連接狀態
val filter = IntentFilter(BluetoothA2dp.ACTION_CONNECTION_STATE_CHANGED)
registerReceiver(bluetoothReceiver, filter)
```

3. **等待 codec negotiation 完成:**
```kotlin
// 監聽 ACTION_CODEC_CONFIG_CHANGED
val filter = IntentFilter(BluetoothA2dp.ACTION_CODEC_CONFIG_CHANGED)
registerReceiver(codecChangeReceiver, filter)
```

**偵測警訊:**
- Logcat 出現 "Codec status is null"
- NullPointerException 在 getCodecConfig() 或 getCodecType() 時發生
- 錯誤只在藍牙連接/斷線時發生

**建議處理階段:**
- **Phase 2 (Platform Channel 實作):** 所有 codec 存取都必須加 null check
- **Phase 3 (狀態管理):** 設計 Flutter BLoC state 來處理 "codec unavailable" 狀態

**信心等級:** HIGH
**資料來源:**
- [Android A2DP Source Code](https://github.com/mukherjeepritam/bt/blob/master/src/com/android/bluetooth/a2dp/A2dpService.java)
- [BluetoothA2dp getCodecStatus Documentation](https://developer.android.com/reference/android/bluetooth/BluetoothA2dp)

---

### 陷阱 4: A2DP Hardware Offload 干擾 Codec 控制

**錯誤行為:**
在某些裝置(特別是 Samsung、OnePlus)上,即使透過 Developer Options 或 API 設定 codec preference,實際使用的 codec 仍是 SBC,因為 A2DP Hardware Offload 覆蓋了設定。

**發生原因:**
- Android 8.0+ 支援 A2DP hardware offload,將音訊編碼工作移至硬體處理器
- 某些裝置製造商(如 Samsung)的實作會在 Bluetooth handshake 時強制注入特定 codec profile
- Hardware offload 的 codec 選擇邏輯在 BT Controller 層,繞過 Android framework 的設定
- Developer Options 的 "Disable A2DP hardware offload" 選項可能被製造商停用或無效

**嚴重後果:**
- 使用者看到的 codec 資訊與實際不符
- 在某些裝置上完全無法切換 codec
- AAC codec 可能產生破音或雜訊(特別是 Samsung One UI 6/Android 14)
- 功能在開發裝置測試通過,在使用者裝置失效

**預防策略:**
1. **偵測 Hardware Offload 狀態:**
```kotlin
// 檢查 Developer Options 的 A2DP offload 設定
// 注意:這是系統設定,無法透過 app 修改
val isOffloadDisabled = Settings.Global.getInt(
    contentResolver,
    "bluetooth_a2dp_hw_offload_disabled",
    0
) == 1
```

2. **提供替代方案引導:**
```kotlin
// 偵測到 offload 問題時,引導使用者到設定
fun guideToDisableOffload() {
    val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
    startActivity(intent)
    // 顯示說明:找到 "Disable Bluetooth A2DP hardware offload" 並啟用
}
```

3. **明確標示硬體限制:**
```dart
// Flutter UI 顯示警告
if (isHardwareOffloadEnabled) {
  Text(
    '此裝置啟用了硬體加速,部分 codec 設定可能無效。'
    '請到開發者選項停用 "Bluetooth A2DP 硬體卸載"。'
  );
}
```

4. **裝置特定的 workaround:**
```kotlin
// 偵測 Samsung 裝置
val isSamsung = Build.MANUFACTURER.equals("samsung", ignoreCase = true)
if (isSamsung && Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
    // 提供 Samsung 特定的說明或限制
}
```

**偵測警訊:**
- 使用者回報 codec 設定無效
- 測試機能切換 codec,生產機不行
- AAC codec 產生破音(Samsung 特定問題)
- Logcat 出現 "A2DP offload enabled"

**建議處理階段:**
- **Phase 2 (Platform Channel):** 實作 hardware offload 狀態偵測
- **Phase 3 (UI):** 根據裝置狀態顯示適當的警告與說明
- **Phase 4 (測試):** 在多個製造商裝置測試(Samsung、Pixel、OnePlus 等)

**信心等級:** MEDIUM (基於社群回報,缺乏官方文件)
**資料來源:**
- [Samsung Bluetooth Issues](https://eu.community.samsung.com/t5/other-galaxy-s-series/bluetooth-audio-doesn-t-work-on-some-devices/td-p/10335732)
- [XDA A2DP Hardware Offload Discussion](https://xdaforums.com/t/disable-bluetooth-a2dp-hardware-offload.3856557/page-2)

---

## 中等陷阱(Moderate Pitfalls)

會導致延遲、技術債或部分功能問題,但可修復。

### 陷阱 5: Codec 優先權設定值錯誤

**錯誤行為:**
設定 codec priority 時使用 `-1`(停用)、`0`(保留值)或重複的優先權值,導致 codec 選擇邏輯混亂。

**預防策略:**
```kotlin
// 正確的優先權設定
val codecPriorities = mapOf(
    BluetoothCodecConfig.SOURCE_CODEC_TYPE_LDAC to 1000000,  // 最高優先
    BluetoothCodecConfig.SOURCE_CODEC_TYPE_APTX_HD to 900000,
    BluetoothCodecConfig.SOURCE_CODEC_TYPE_APTX to 800000,
    BluetoothCodecConfig.SOURCE_CODEC_TYPE_AAC to 700000,
    BluetoothCodecConfig.SOURCE_CODEC_TYPE_SBC to 600000     // 最低優先
)

// 避免:
// -1 = 停用 codec
//  0 = 保留值,不可使用
// 1-999999 = 有效範圍,必須唯一
```

**建議處理階段:**
- **Phase 2 (Platform Channel):** 實作 codec priority 驗證邏輯

**信心等級:** HIGH
**資料來源:**
- [A2DP Codec Dissection](https://btcodecs.valdikss.org.ru/)

---

### 陷阱 6: Developer Options 未啟用導致功能無法測試

**錯誤行為:**
在測試裝置或使用者裝置上,Developer Options 未啟用,導致無法顯示或修改 Bluetooth codec 設定。

**預防策略:**
1. **偵測 Developer Options 狀態:**
```kotlin
val isDevOptionsEnabled = Settings.Global.getInt(
    contentResolver,
    Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
    0
) == 1
```

2. **引導啟用 Developer Options:**
```kotlin
if (!isDevOptionsEnabled) {
    // 顯示說明:設定 > 關於手機 > 連點版本號 7 次
}
```

**建議處理階段:**
- **Phase 1 (文件):** 在 README 說明測試前需啟用 Developer Options
- **Phase 3 (UI):** 在 app 內提供啟用說明

**信心等級:** HIGH
**資料來源:**
- [Configure Developer Options](https://developer.android.com/studio/debug/dev-options)

---

### 陷阱 7: Codec Negotiation 時序問題

**錯誤行為:**
在藍牙裝置剛連接時立即查詢 codec 狀態,此時 remote codec negotiation 尚未完成,得到不正確或不完整的資訊。

**預防策略:**
1. **監聽 CODEC_CONFIG_CHANGED:**
```kotlin
private val codecChangeReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == BluetoothA2dp.ACTION_CODEC_CONFIG_CHANGED) {
            // Codec negotiation 完成,現在可以安全查詢
            val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
            updateCodecInfo(device)
        }
    }
}
```

2. **延遲查詢:**
```kotlin
// 在連接後延遲 1-2 秒再查詢
Handler(Looper.getMainLooper()).postDelayed({
    queryCodecStatus()
}, 2000)
```

**建議處理階段:**
- **Phase 2 (Platform Channel):** 實作 codec change listener
- **Phase 3 (BLoC):** 設計 "negotiating" 狀態

**信心等級:** MEDIUM
**資料來源:**
- [Android Bluetooth Callback Timing Issues](https://github.com/NordicSemiconductor/Android-BLE-Library/issues/333)

---

### 陷阱 8: 高位元率 Codec 導致電池快速耗盡

**錯誤行為:**
切換到 LDAC 990kbps 或 aptX HD 等高位元率 codec 後,使用者發現電池消耗增加 20-40%,但 app 沒有提供任何警告。

**預防策略:**
```dart
// Flutter UI 顯示警告
Widget buildCodecOption(String codecName, int bitrate) {
  final isHighBitrate = bitrate > 600;

  return ListTile(
    title: Text(codecName),
    subtitle: Text(
      isHighBitrate
        ? '高音質但耗電量增加 20-40%'
        : '標準耗電'
    ),
  );
}
```

**建議處理階段:**
- **Phase 3 (UI):** 在 codec 選擇 UI 顯示耗電警告

**信心等級:** HIGH
**資料來源:**
- [Bluetooth Codec Battery Impact](https://phonetechwiki.com/android-fix-hidden-bluetooth-codec-settings/)

---

### 陷阱 9: API Level 21-25 不支援 Codec API

**錯誤行為:**
專案宣稱支援 API 21+,但 `BluetoothA2dp.getCodecStatus()` 只在 API 26+ 可用,導致舊裝置 crash。

**預防策略:**
```kotlin
fun getCodecInfo(device: BluetoothDevice): Map<String, Any?> {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
        return mapOf(
            "supported" to false,
            "message" to "Codec API requires Android 8.0+"
        )
    }

    // API 26+ 才能呼叫
    val codecStatus = bluetoothA2dp.getCodecStatus(device)
    // ...
}
```

**建議處理階段:**
- **Phase 1 (需求確認):** 決定是否將最低版本提升至 API 26
- **Phase 2 (Platform Channel):** 實作 API level 檢查

**信心等級:** HIGH
**資料來源:**
- [Android Bluetooth Services](https://source.android.com/docs/core/connect/bluetooth/services)

---

## 輕微陷阱(Minor Pitfalls)

會造成困擾但容易修復的問題。

### 陷阱 10: Codec 設定不持久(重開機後重置)

**錯誤行為:**
使用者手動在 Developer Options 設定的 codec preference 在裝置重開機後恢復成預設值。

**預防策略:**
在 UI 提供說明:「部分裝置的 Bluetooth codec 設定在重開機後會重置,屬於正常現象。」

**建議處理階段:**
- **Phase 3 (UI):** 在說明文件或 FAQ 加入此資訊

**信心等級:** MEDIUM
**資料來源:**
- [Android Codec Settings Not Persisting](https://phonetechwiki.com/android-fix-hidden-bluetooth-codec-settings/)

---

### 陷阱 11: Codec 名稱顯示不一致

**錯誤行為:**
不同裝置對同一 codec 的顯示名稱不同(如 "LDAC" vs "Hi-Res LDAC" vs "Sony LDAC")。

**預防策略:**
```kotlin
fun getStandardCodecName(codecType: Int): String {
    return when (codecType) {
        BluetoothCodecConfig.SOURCE_CODEC_TYPE_SBC -> "SBC"
        BluetoothCodecConfig.SOURCE_CODEC_TYPE_AAC -> "AAC"
        BluetoothCodecConfig.SOURCE_CODEC_TYPE_APTX -> "aptX"
        BluetoothCodecConfig.SOURCE_CODEC_TYPE_APTX_HD -> "aptX HD"
        BluetoothCodecConfig.SOURCE_CODEC_TYPE_LDAC -> "LDAC"
        else -> "Unknown"
    }
}
```

**建議處理階段:**
- **Phase 2 (Platform Channel):** 使用標準化名稱映射

**信心等級:** HIGH

---

### 陷阱 12: Flutter Platform Channel 未處理 Android Activity Lifecycle

**錯誤行為:**
Platform Channel handler 註冊 BroadcastReceiver 但在 Activity destroy 時未 unregister,導致 memory leak。

**預防策略:**
```kotlin
class BluetoothHandler(private val activity: FlutterActivity) {
    private var receiver: BroadcastReceiver? = null

    fun register() {
        receiver = object : BroadcastReceiver() { /*...*/ }
        activity.registerReceiver(receiver, IntentFilter(/*...*/))
    }

    fun unregister() {
        receiver?.let {
            activity.unregisterReceiver(it)
            receiver = null
        }
    }
}

// 在 MainActivity
override fun onDestroy() {
    bluetoothHandler.unregister()
    super.onDestroy()
}
```

**建議處理階段:**
- **Phase 2 (Platform Channel):** 實作完整的 lifecycle handling

**信心等級:** HIGH

---

## Phase-Specific 警告

| Phase 主題 | 可能陷阱 | 緩解措施 |
|------------|---------|---------|
| Phase 1: 架構設計 | 誤以為可以直接控制 codec 切換 | 研究 hidden API 限制,決定採用「引導到 Developer Options」方案 |
| Phase 2: Platform Channel | 忘記檢查 Android 12+ 權限 | 實作完整的權限檢查與請求流程 |
| Phase 2: Platform Channel | 未處理 getCodecStatus() 返回 null | 所有 Bluetooth API 呼叫都加 null check |
| Phase 3: UI 實作 | 未顯示 hardware offload 警告 | 偵測裝置狀態並顯示適當說明 |
| Phase 4: 測試 | 只在單一裝置測試 | 在多個製造商裝置測試(Samsung、Pixel、OnePlus) |

---

## 研究資料來源

### HIGH 信心等級來源
- [Android Bluetooth Permissions Official Documentation](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions) (Updated 2026-02-06)
- [BluetoothCodecConfig API Reference](https://developer.android.com/reference/android/bluetooth/BluetoothCodecConfig)
- [BluetoothA2dp API Reference](https://developer.android.com/reference/android/bluetooth/BluetoothA2dp)
- [Android Bluetooth Services AOSP](https://source.android.com/docs/core/connect/bluetooth/services)

### MEDIUM 信心等級來源
- [Flutter Permission Handler Issues](https://github.com/Baseflow/flutter-permission-handler/issues/1248)
- [Android A2DP Source Code](https://github.com/yuchuangu85/Android-system-apps/blob/master/apps/Bluetooth/src/com/android/bluetooth/a2dp/A2dpService.java)
- [Bluetooth Codec Change Project](https://github.com/matisiekpl/bluetooth-codec-change)

### LOW 信心等級來源(社群回報)
- [Samsung Bluetooth Codec Issues](https://eu.community.samsung.com/t5/other-galaxy-s-series/bluetooth-audio-doesn-t-work-on-some-devices/td-p/10335732)
- [XDA Hardware Offload Discussion](https://xdaforums.com/t/disable-bluetooth-a2dp-hardware-offload.3856557/page-2)
- [Android Codec Settings Guide 2026](https://phonetechwiki.com/android-fix-hidden-bluetooth-codec-settings/)

---

**總結:** Android Bluetooth A2DP codec 控制最大的陷阱是「Hidden API 依賴」與「Android 12+ 權限模型」。建議採用「唯讀資訊顯示 + 引導到系統設定」的架構,避免依賴非公開 API。所有 Bluetooth API 呼叫都必須檢查 null 與權限狀態。
