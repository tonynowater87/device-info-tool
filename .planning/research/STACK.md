# 技術堆疊：Android 藍牙 A2DP 編解碼器資訊與切換

**專案：** Mobile OS Versions (後續功能追加)
**研究日期：** 2026-02-08
**功能範圍：** Android 藍牙音訊設備資訊與編解碼器切換
**iOS 狀態：** 超出範圍（僅 Android）

---

## 執行摘要

本專案需要在現有 Flutter App 中增加藍牙音訊設備資訊顯示與編解碼器切換功能。經過研究發現，**Android 官方 API 對藍牙編解碼器的程式化控制支援有限**，關鍵 API（如 `setCodecConfigPreference`）被標記為 `@hide`，不屬於公開 SDK。

**建議策略：**
- 使用公開 API 獲取**唯讀資訊**（設備資訊、編解碼器狀態）
- 編解碼器**切換功能**需透過引導使用者至開發者選項來實現
- 避免使用 Hidden API 繞過方案（違反 Google Play 政策，且穩定性無保證）

---

## 核心框架與平台

| 技術 | 版本 | 用途 | 為何採用 |
|------|------|------|---------|
| Flutter | 當前版本 | 跨平台 UI 框架 | **既有專案使用**，無需更換 |
| Kotlin | 1.8.10+ | Android 原生實作 | **既有專案標準**，與現有 DeviceInfoHandler 一致 |
| Android SDK | API 31+ (目標 35) | Android 平台 API | **符合專案現狀**（minSdk=23, targetSdk=35）|
| Platform Channels | MethodChannel | Flutter ↔ Kotlin 通訊 | **既有模式**（已用於 DeviceInfoHandler） |

**版本相依性理由：**
- **最低 API 26（Android 8.0）** - BluetoothCodecConfig/Status 類別引入版本
- **建議 API 31（Android 12）** - 新藍牙權限模型（BLUETOOTH_CONNECT）
- **目標 API 35（Android 15）** - 符合專案當前目標，符合 Google Play 2025 要求

---

## Android 藍牙 API（核心技術）

### 1. BluetoothA2dp（公開 API）

| API | 最低版本 | 用途 | 信心度 |
|-----|----------|------|--------|
| `getConnectedDevices()` | API 11 | 取得已連接的 A2DP 設備清單 | **HIGH** |
| `getCodecStatus(BluetoothDevice)` | API 26 | 取得編解碼器狀態（當前 + 支援清單） | **HIGH** |
| ~~`setCodecConfigPreference()`~~ | API 26 | **設定編解碼器偏好** | **N/A（隱藏 API）** |

**來源：**
- [BluetoothA2dp - Android Developers](https://developer.android.com/reference/android/bluetooth/BluetoothA2dp)
- [Bluetooth services - AOSP](https://source.android.com/docs/core/connect/bluetooth/services)

**使用模式（ServiceListener）：**
```kotlin
BluetoothAdapter.getDefaultAdapter().getProfileProxy(
    context,
    serviceListener,
    BluetoothProfile.A2DP
)
```

**為何採用：** 官方公開 API，穩定且符合 Google Play 政策。

**限制：** `setCodecConfigPreference()` 被標記為 `@hide`，無法在第三方應用中可靠使用。

---

### 2. BluetoothCodecConfig（編解碼器配置）

| 常數/方法 | 最低版本 | 用途 | 信心度 |
|-----------|----------|------|--------|
| `getCodecType()` | API 26 | 取得編解碼器類型（SBC/AAC/APTX/LDAC 等） | **HIGH** |
| `getSampleRate()` | API 26 | 取得取樣率（44100/48000/96000 等） | **HIGH** |
| `getBitsPerSample()` | API 26 | 取得位元深度（16/24/32 bits） | **HIGH** |
| `getChannelMode()` | API 26 | 取得聲道模式（立體聲/單聲道） | **HIGH** |
| `Builder` | API 33 | 建構自訂編解碼器配置 | **MEDIUM** |

**支援的編解碼器常數：**
- `SOURCE_CODEC_TYPE_SBC` (0) - 基本編解碼器，必支援
- `SOURCE_CODEC_TYPE_AAC` (1) - 高品質，廣泛支援
- `SOURCE_CODEC_TYPE_APTX` (2) - Qualcomm 專利
- `SOURCE_CODEC_TYPE_APTX_HD` (3) - APTX 高清版本
- `SOURCE_CODEC_TYPE_LDAC` (4) - Sony 高解析度編解碼器
- `SOURCE_CODEC_TYPE_LC3` (6) - LE Audio 新編解碼器（API 33+）

**來源：**
- [BluetoothCodecConfig - Android Developers](https://developer.android.com/reference/android/bluetooth/BluetoothCodecConfig)

**為何採用：** 唯一官方途徑取得編解碼器詳細參數。

**限制：** Builder 僅在 API 33+ 可用，但僅用於構建配置物件，無法直接應用（需依賴隱藏 API）。

---

### 3. BluetoothCodecStatus（狀態查詢）

| 方法 | 最低版本 | 用途 | 信心度 |
|------|----------|------|--------|
| `getCodecConfig()` | API 26 | 取得當前使用的編解碼器配置 | **HIGH** |
| ~~`getCodecsLocalCapabilities()`~~ | API 26 | 取得本機支援的編解碼器（隱藏 API） | **LOW** |
| ~~`getCodecsSelectableCapabilities()`~~ | API 26 | 取得可選的編解碼器（隱藏 API） | **LOW** |

**來源：**
- Android AOSP 原始碼（`BluetoothCodecStatus.java`）
- [Microsoft Learn - BluetoothCodecStatus](https://learn.microsoft.com/en-us/dotnet/api/android.bluetooth.bluetoothcodecstatus.codecconfig)

**為何不使用隱藏 API：**
1. **Google Play 政策違反** - 使用 `@hide` 或 `@UnsupportedAppUsage` 標記的 API 會導致審核失敗
2. **不穩定性** - Google 可在任何版本中更改或移除隱藏 API
3. **相容性問題** - 不同廠商（Samsung/Xiaomi/OnePlus）可能有不同實作

**替代方案：** 透過 `getCodecStatus().getCodecConfig()` 取得當前編解碼器，利用 Intent 引導使用者至開發者選項手動切換。

---

### 4. BluetoothDevice（設備資訊）

| 方法 | 最低版本 | 用途 | 信心度 |
|------|----------|------|--------|
| `getName()` | API 5 | 取得藍牙設備名稱 | **HIGH** |
| `getAddress()` | API 5 | 取得 MAC 位址（例：00:11:22:AA:BB:CC） | **HIGH** |
| `getBluetoothClass()` | API 5 | 取得設備類別（耳機/喇叭等） | **HIGH** |
| `getType()` | API 18 | 取得設備類型（Classic/LE/Dual） | **HIGH** |

**來源：**
- [BluetoothDevice - Android Developers](https://developer.android.com/reference/android/bluetooth/BluetoothDevice)
- [Find Bluetooth devices - Android Developers](https://developer.android.com/develop/connectivity/bluetooth/find-bluetooth-devices)

**為何採用：** 基礎公開 API，取得設備基本資訊完全足夠。

---

## Android 權限需求

### API Level 31（Android 12）以上

| 權限 | 類型 | 用途 | maxSdkVersion |
|------|------|------|---------------|
| `BLUETOOTH_CONNECT` | Runtime（危險） | 連接已配對的藍牙設備 | - |
| `BLUETOOTH_SCAN` | Runtime（危險） | 掃描藍牙設備（若需搜尋功能） | - |
| `ACCESS_FINE_LOCATION` | Runtime（危險） | 僅當需要從藍牙掃描推導物理位置時 | - |

### API Level 30 以下（向下相容）

| 權限 | 類型 | maxSdkVersion |
|------|------|---------------|
| `BLUETOOTH` | Normal | 30 |
| `BLUETOOTH_ADMIN` | Normal | 30 |
| `ACCESS_FINE_LOCATION` | Runtime（危險） | - |

**AndroidManifest.xml 配置範例：**
```xml
<!-- API 31+ 權限 -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- 向下相容（API 30 及以下） -->
<uses-permission
    android:name="android.permission.BLUETOOTH"
    android:maxSdkVersion="30" />
<uses-permission
    android:name="android.permission.BLUETOOTH_ADMIN"
    android:maxSdkVersion="30" />
```

**Runtime 權限請求（Kotlin）：**
```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    ActivityCompat.requestPermissions(
        activity,
        arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
        REQUEST_CODE
    )
}
```

**來源：**
- [Bluetooth permissions - Android Developers](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions)
- [Mastering Android BLE Permissions](https://punchthrough.com/mastering-permissions-for-bluetooth-low-energy-android/)

**為何這樣設計：**
- Android 12 重新設計藍牙權限，移除對 LOCATION 的強制依賴（僅連接已配對設備時）
- 使用 `maxSdkVersion` 避免在新系統上請求過時權限

---

## Flutter 整合架構

### Platform Channel 模式（與現有架構一致）

| 元件 | 技術 | 職責 | 為何採用 |
|------|------|------|---------|
| Dart 端 | MethodChannel | 呼叫原生方法、接收資料 | **既有模式**（DeviceVersionProvider） |
| Kotlin 端 | MethodChannel.Result | 處理藍牙 API、返回資料 | **既有模式**（DeviceInfoHandler） |
| 通道名稱 | 字串常數 | `com.tonynowater.mobileosversions/bluetooth` | **命名規範**：獨特域名前綴 |

**實作模式（參考 DeviceInfoHandler）：**

**Kotlin 端（BluetoothCodecHandler.kt）：**
```kotlin
class BluetoothCodecHandler(private val activity: Activity) {
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBluetoothDeviceInfo" -> getDeviceInfo(result)
            "getCodecInfo" -> getCodecInfo(result)
            "openDeveloperOptions" -> openDeveloperOptions(result)
            else -> result.notImplemented()
        }
    }
}
```

**Dart 端：**
```dart
class BluetoothCodecProvider {
  static const MethodChannel _channel =
      MethodChannel('com.tonynowater.mobileosversions/bluetooth');

  Future<Map<String, dynamic>> getBluetoothDeviceInfo() async {
    return await _channel.invokeMethod('getBluetoothDeviceInfo');
  }
}
```

**在 MainActivity 註冊（與現有一致）：**
```kotlin
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    val bluetoothHandler = BluetoothCodecHandler(this)

    MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "com.tonynowater.mobileosversions/bluetooth"
    ).setMethodCallHandler { call, result ->
        bluetoothHandler.handle(call, result)
    }
}
```

**來源（Flutter 最佳實踐）：**
- [Writing custom platform-specific code - Flutter](https://docs.flutter.dev/platform-integration/platform-channels)
- [Flutter Platform Channels 2025 - Medium](https://medium.com/@pv.jassim/flutter-platform-channels-how-to-call-native-android-ios-web-code-from-flutter-e59658331df8)

**為何採用 MethodChannel 而非 EventChannel：**
- **MethodChannel**：一次性請求/回應（獲取設備資訊、編解碼器狀態）✅
- **EventChannel**：連續資料流（藍牙連接狀態監聽）- 本專案暫不需要

---

## 開發者選項整合（編解碼器切換）

### 策略：引導使用者至系統設定

由於 `setCodecConfigPreference()` 為隱藏 API，建議採用**引導式 UX**：

**步驟 1：檢測開發者選項狀態（Kotlin）**
```kotlin
fun isDeveloperOptionsEnabled(): Boolean {
    return Settings.Global.getInt(
        context.contentResolver,
        Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
        0
    ) == 1
}
```

**步驟 2：開啟開發者選項設定頁（Intent）**
```kotlin
fun openDeveloperOptions() {
    val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
    context.startActivity(intent)
}
```

**步驟 3：UI 流程建議**
1. 顯示當前編解碼器資訊（透過 `getCodecStatus()`）
2. 顯示「切換編解碼器」按鈕
3. 點擊後彈出說明：「請在開發者選項 → 藍牙音訊編解碼器中手動切換」
4. 提供「開啟設定」按鈕，執行 `openDeveloperOptions()`

**替代方案評估：**

| 方案 | 可行性 | 風險 | 結論 |
|------|--------|------|------|
| Hidden API + Reflection | 技術可行 | ❌ Google Play 審核失敗 | **不推薦** |
| Hidden API Bypass 庫 | 技術可行 | ❌ 違反政策 + 未來版本可能失效 | **不推薦** |
| Root 權限 | 技術可行 | ❌ 使用者門檻極高 | **不推薦** |
| 引導至開發者選項 | ✅ 完全可行 | ✅ 無風險 | **推薦** ✅ |

**來源：**
- [How to change Bluetooth codec on Android - Android Police](https://www.androidpolice.com/change-bluetooth-codec-android/)
- [Android hidden API bypass - XDA Developers](https://www.xda-developers.com/bypass-hidden-apis/)
- [LSPosed/AndroidHiddenApiBypass](https://github.com/LSPosed/AndroidHiddenApiBypass)（參考用，不建議使用）

---

## 不建議使用的方案

### ❌ Hidden API Bypass Libraries

**範例：** `LSPosed/AndroidHiddenApiBypass`

**為何不用：**
1. **違反 Google Play 政策** - 明確禁止使用非公開 API
2. **Android 版本相容性問題** - Google 持續加強限制（Android 9+ 強化，Android 14+ 更嚴格）
3. **廠商客製化差異** - Samsung/Xiaomi 等可能有不同實作
4. **維護成本高** - 每次 Android 大版本更新需重新驗證

**來源：**
- [Advanced Android Development: Bypass hidden API blacklist - XDA](https://www.xda-developers.com/bypass-hidden-apis/)
- [Restrictions on non-SDK interfaces - Android Developers](https://developer.android.com/about/versions/pie/restrictions-non-sdk-interfaces)

### ❌ 第三方藍牙庫（不適用）

**已評估的套件：**
- `flutter_blue_plus` - 專注於 BLE（低功耗藍牙），不支援 A2DP 編解碼器
- `flutter_bluetooth_serial` - 專注於序列通訊，非音訊

**為何不用：** 沒有現成的 Flutter 套件提供 A2DP 編解碼器控制，需自行實作平台通道。

**來源：**
- [flutter_blue_plus - pub.dev](https://pub.dev/packages/flutter_blue_plus)
- [Top Flutter Bluetooth packages - Flutter Gems](https://fluttergems.dev/bluetooth-nfc-beacon/)

---

## 安裝與配置

### Gradle 配置（android/app/build.gradle）

**無需額外依賴** - Android 藍牙 API 為系統內建

**現有配置已滿足需求：**
```gradle
android {
    compileSdkVersion 36        // ✅ 支援最新 API

    defaultConfig {
        minSdkVersion 23        // ✅ 涵蓋 API 26（藍牙編解碼器 API）
        targetSdkVersion 35     // ✅ 符合 2025 Google Play 要求
    }
}

dependencies {
    // ✅ 無需額外依賴
}
```

### Flutter 依賴（pubspec.yaml）

**無需額外套件** - 使用 Platform Channel 直接整合

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ✅ 無新增依賴
```

---

## 功能範圍矩陣

| 功能 | 技術方案 | API Level | 信心度 | 備註 |
|------|----------|-----------|--------|------|
| **藍牙設備資訊** |  |  |  |  |
| - 設備名稱 | `BluetoothDevice.getName()` | API 5 | **HIGH** | ✅ 公開 API |
| - MAC 位址 | `BluetoothDevice.getAddress()` | API 5 | **HIGH** | ✅ 公開 API |
| - 設備類型 | `BluetoothDevice.getType()` | API 18 | **HIGH** | ✅ 公開 API |
| **編解碼器資訊** |  |  |  |  |
| - 當前編解碼器 | `BluetoothCodecStatus.getCodecConfig()` | API 26 | **HIGH** | ✅ 公開 API |
| - 編解碼器類型 | `BluetoothCodecConfig.getCodecType()` | API 26 | **HIGH** | ✅ 公開 API（SBC/AAC/APTX/LDAC 等） |
| - 取樣率 | `BluetoothCodecConfig.getSampleRate()` | API 26 | **HIGH** | ✅ 公開 API（44.1k/48k/96k 等） |
| - 位元深度 | `BluetoothCodecConfig.getBitsPerSample()` | API 26 | **HIGH** | ✅ 公開 API（16/24/32 bits） |
| - 位元率 | 計算或估算 | - | **MEDIUM** | ⚠️ 無直接 API，需根據編解碼器類型估算 |
| - 支援的編解碼器清單 | ~~隱藏 API~~ | API 26 | **LOW** | ❌ 需透過開發者選項查看 |
| **編解碼器切換** |  |  |  |  |
| - 程式化切換 | ~~`setCodecConfigPreference()`~~ | - | **N/A** | ❌ 隱藏 API，不可用 |
| - 引導式切換 | `Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)` | API 1 | **HIGH** | ✅ 引導使用者至開發者選項 |

---

## API Level 建議

### 最低支援版本（minSdkVersion）

**建議：保持 API 23（Android 6.0）**

**理由：**
- 專案現有最低版本為 API 23
- 藍牙編解碼器 API 需 API 26+，但可透過版本檢查提供降級體驗
- API 23 以下使用者可顯示「不支援此功能」訊息

**版本檢查範例：**
```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    // 使用 BluetoothCodecConfig API
} else {
    // 返回「需要 Android 8.0 以上版本」
}
```

### 目標版本（targetSdkVersion）

**建議：保持 API 35（Android 15）**

**理由：**
- 符合 Google Play 2025 年要求（最低 API 34，建議 API 35）
- 專案已設定為 35，無需調整

**來源：**
- [Target API level requirements - Google Play](https://support.google.com/googleplay/android-developer/answer/11926878)

---

## 風險與緩解措施

| 風險 | 影響 | 機率 | 緩解措施 | 信心度 |
|------|------|------|---------|--------|
| **無法程式化切換編解碼器** | 功能受限 | 100% | 採用引導式 UX，教育使用者手動切換 | **HIGH** |
| **廠商客製化差異** | 編解碼器資訊不一致 | 30% | 多機型測試（Samsung/Pixel/Xiaomi），提供容錯處理 | **MEDIUM** |
| **API 26 以下使用者無法使用** | 功能不可用 | 20% | 版本檢查 + 降級提示，顯示「需要 Android 8.0+」 | **HIGH** |
| **權限被拒絕** | 無法取得資料 | 40% | 提供權限說明對話框，引導使用者授權 | **HIGH** |
| **藍牙未連接設備時** | 資料為空 | 80% | UI 顯示「請連接藍牙音訊設備」提示 | **HIGH** |

---

## 測試策略

### 裝置測試矩陣

| 廠商 | 型號 | Android 版本 | API Level | 優先度 |
|------|------|--------------|-----------|--------|
| Google | Pixel 6 | Android 13 | 33 | **高** |
| Samsung | Galaxy S21 | Android 12 | 31 | **高** |
| Xiaomi | Mi 11 | Android 11 | 30 | **中** |
| OnePlus | 9 Pro | Android 12 | 31 | **中** |

### 編解碼器支援測試

| 編解碼器 | 預期支援度 | 測試裝置需求 |
|----------|-----------|--------------|
| SBC | 100%（強制） | 所有裝置 |
| AAC | 90% | 主流旗艦機 |
| APTX | 50%（Qualcomm SoC） | Snapdragon 裝置 |
| APTX HD | 30% | 高階 Snapdragon |
| LDAC | 80%（Android 8.0+） | Android 8.0+ 裝置 |
| LC3 | 20%（新裝置） | Android 13+ 支援 LE Audio 裝置 |

### 整合測試場景

1. **無藍牙連接狀態** → 顯示提示訊息
2. **連接 SBC 編解碼器耳機** → 顯示基本資訊
3. **連接 LDAC 編解碼器耳機** → 顯示高階資訊（取樣率/位元深度）
4. **權限未授予** → 請求權限並處理拒絕情境
5. **Android 7.0 裝置** → 顯示不支援訊息
6. **引導至開發者選項** → 驗證 Intent 正確開啟設定頁

---

## 參考資料與信心度評估

### HIGH 信心度來源

| 來源 | 類型 | 日期 | 用途 |
|------|------|------|------|
| [BluetoothA2dp - Android Developers](https://developer.android.com/reference/android/bluetooth/BluetoothA2dp) | 官方文檔 | 2025-02-10 | API 規格 |
| [BluetoothCodecConfig - Android Developers](https://developer.android.com/reference/android/bluetooth/BluetoothCodecConfig) | 官方文檔 | 2025 | 編解碼器配置 |
| [Bluetooth permissions - Android Developers](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions) | 官方文檔 | 2025 | 權限需求 |
| [Writing platform-specific code - Flutter](https://docs.flutter.dev/platform-integration/platform-channels) | 官方文檔 | 2025 | Platform Channel |

### MEDIUM 信心度來源

| 來源 | 類型 | 日期 | 用途 |
|------|------|------|------|
| [Flutter BLE Deep Dive - Gurzu](https://gurzu.com/blog/flutter-ble-deep-dive/) | 教學文章 | 2025-03 | Platform Channel 範例 |
| [Flutter to Android Bluetooth Scanner - Medium](https://medium.com/@web.pinkisingh/flutter-to-android-bridging-build-a-real-time-bluetooth-scanner-with-kotlin-full-code-a578b3b09e71) | 教學文章 | 2025-04 | Kotlin 整合範例 |
| [Bluetooth services - AOSP](https://source.android.com/docs/core/connect/bluetooth/services) | AOSP 文檔 | 2025 | 藍牙服務架構 |

### LOW 信心度來源（僅供參考）

| 來源 | 類型 | 原因 |
|------|------|------|
| [How to change Bluetooth codec - Android Police](https://www.androidpolice.com/change-bluetooth-codec-android/) | 教學文章 | 使用者指南，非技術文檔 |
| [GitHub - matisiekpl/bluetooth-codec-change](https://github.com/matisiekpl/bluetooth-codec-change) | 社群專案 | 使用隱藏 API，不適用於正式專案 |
| [LSPosed/AndroidHiddenApiBypass](https://github.com/LSPosed/AndroidHiddenApiBypass) | 繞過工具 | 違反政策，僅作為「不推薦」參考 |

---

## 總結與建議

### 推薦技術堆疊

```
Flutter (UI 層)
    ↓ [Platform Channel]
Kotlin Handler (Android 原生層)
    ↓ [Android Bluetooth APIs]
BluetoothA2dp + BluetoothCodecConfig (系統 API)
```

### 核心決策

1. **✅ 使用公開 API** - BluetoothA2dp.getCodecStatus() 取得編解碼器資訊（唯讀）
2. **✅ 引導式 UX** - Intent 開啟開發者選項，讓使用者手動切換
3. **❌ 避免隱藏 API** - 不使用 setCodecConfigPreference()，避免違反政策
4. **✅ 遵循現有模式** - 複用 DeviceInfoHandler 的 Platform Channel 架構
5. **✅ 版本檢查降級** - API 26 以下顯示不支援訊息

### 實作優先順序

**Phase 1（核心功能）：**
- 取得已連接藍牙設備資訊（名稱、MAC）
- 取得當前編解碼器資訊（類型、取樣率、位元深度）
- 權限請求與處理

**Phase 2（增強體驗）：**
- 引導至開發者選項功能
- 編解碼器資訊 UI 美化
- 錯誤處理與降級體驗

**Phase 3（可選功能）：**
- 連接狀態監聽（EventChannel）
- 編解碼器效能建議（基於使用情境）

---

**信心度評估：**
- **整體技術可行性：HIGH** - 唯讀功能完全基於公開 API
- **編解碼器切換限制：已知** - 清楚了解無法程式化切換，採用引導方案
- **與現有架構整合：HIGH** - 複用既有 Platform Channel 模式
- **Google Play 合規性：HIGH** - 完全避免隱藏 API 使用

**最後更新：** 2026-02-08
**研究者：** Claude (GSD Project Researcher)
