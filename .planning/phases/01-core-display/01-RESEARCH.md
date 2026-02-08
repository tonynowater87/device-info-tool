# Phase 1: 核心顯示功能 - Research

**Researched:** 2026-02-08
**Domain:** Android Bluetooth A2DP API / Flutter Platform Channel
**Confidence:** MEDIUM

## Summary

本階段研究聚焦於在 Flutter 應用中透過 Platform Channel 存取 Android 藍牙音訊 codec 資訊。研究涵蓋了 BluetoothA2dp API 的使用模式、權限處理機制（特別是 Android 12+ 的 BLUETOOTH_CONNECT 權限），以及 BluetoothCodecConfig 的資料結構。

核心發現：
- Android 8.0 (API 26) 以上才支援 BluetoothCodecConfig API
- `BluetoothA2dp.getCodecStatus()` 是獲取 codec 資訊的主要方法，但此為 hidden API
- Android 12+ 需要在執行時請求 `BLUETOOTH_CONNECT` 權限
- 無法透過標準 API 取得藍牙版本（如 5.0/5.1/5.2），需改為顯示其他可用資訊

**Primary recommendation:** 使用 Platform Channel 直接呼叫 Android BluetoothA2dp API，遵循現有專案的 Handler 模式（如 DeviceInfoHandler），並使用 permission_handler 套件處理 Android 12+ 權限。

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_bloc | 8.1.2 | 狀態管理 | 專案現有架構，保持一致性 |
| permission_handler | ^11.0.0 | 權限請求處理 | Flutter 生態系統標準套件，支援 Android 12 藍牙權限 |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| android.bluetooth.BluetoothA2dp | API 11+ | 存取 A2DP profile | 取得已連接裝置與 codec 狀態 |
| android.bluetooth.BluetoothCodecConfig | API 26+ | Codec 設定資訊 | 取得 codec 類型、取樣率、位元深度 |
| android.bluetooth.BluetoothCodecStatus | API 26+ | Codec 狀態 | 包含當前設定與支援的 codec 清單 |
| android.bluetooth.BluetoothAdapter | API 5+ | 藍牙適配器 | 檢查藍牙狀態、取得已配對裝置 |
| android.bluetooth.BluetoothDevice | API 5+ | 藍牙裝置資訊 | 取得裝置名稱、MAC 位址 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| permission_handler | 原生 Flutter 權限 API | permission_handler 提供更統一的 API 且支援更多權限類型 |
| Hidden API (getCodecStatus) | 公開 API 只能取得連接狀態 | Hidden API 是取得 codec 資訊的唯一途徑 |

**Installation:**
```bash
flutter pub add permission_handler
```

**AndroidManifest.xml 設定:**
```xml
<!-- Android 11 及以下 -->
<uses-permission android:name="android.permission.BLUETOOTH"
    android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"
    android:maxSdkVersion="30" />

<!-- Android 12+ -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── view/
│   └── bluetoothaudio/
│       ├── bluetooth_audio_page.dart       # UI 頁面
│       ├── bluetooth_audio_cubit.dart      # 狀態管理
│       └── bluetooth_audio_state.dart      # 狀態定義
└── data/
    └── model/
        └── bluetooth_audio_model.dart      # 資料模型

android/app/src/main/kotlin/.../
├── MainActivity.kt                          # 註冊 Handler
└── BluetoothAudioHandler.kt                # Platform Channel 處理器
```

### Pattern 1: Platform Channel Handler 模式
**What:** 遵循專案現有的 Handler 模式，將原生藍牙邏輯封裝在獨立的 Handler 類別中
**When to use:** 所有需要存取原生 API 的功能
**Example:**
```kotlin
// Source: 專案現有模式 (DeviceInfoHandler.kt)
class BluetoothAudioHandler(private val activity: Activity) {
    private var bluetoothA2dp: BluetoothA2dp? = null

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBluetoothAudioInfo" -> getBluetoothAudioInfo(result)
            else -> result.notImplemented()
        }
    }

    private fun getBluetoothAudioInfo(result: MethodChannel.Result) {
        // 實作邏輯
    }
}
```

### Pattern 2: BLoC 狀態管理模式
**What:** 使用 flutter_bloc 管理頁面狀態，遵循專案現有模式
**When to use:** 所有有狀態的頁面
**Example:**
```dart
// Source: 專案現有模式 (android_device_info_cubit.dart)
abstract class BluetoothAudioState {}

class BluetoothAudioInitial extends BluetoothAudioState {}

class BluetoothAudioPermissionRequired extends BluetoothAudioState {}

class BluetoothAudioNotSupported extends BluetoothAudioState {
  final String reason;  // "Android 8.0 以下不支援"
}

class BluetoothAudioNoDevice extends BluetoothAudioState {}

class BluetoothAudioLoaded extends BluetoothAudioState {
  final BluetoothDeviceInfo deviceInfo;
  final BluetoothCodecInfo codecInfo;
}
```

### Pattern 3: BluetoothProfile.ServiceListener 模式
**What:** 取得 BluetoothA2dp proxy 的標準方式
**When to use:** 存取 A2DP profile 服務
**Example:**
```kotlin
// Source: Android Bluetooth API
private val profileListener = object : BluetoothProfile.ServiceListener {
    override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
        if (profile == BluetoothProfile.A2DP) {
            bluetoothA2dp = proxy as BluetoothA2dp
        }
    }

    override fun onServiceDisconnected(profile: Int) {
        if (profile == BluetoothProfile.A2DP) {
            bluetoothA2dp = null
        }
    }
}

// 取得 proxy
bluetoothAdapter.getProfileProxy(context, profileListener, BluetoothProfile.A2DP)
```

### Anti-Patterns to Avoid
- **直接呼叫 hidden API 而不做版本檢查:** 必須檢查 API 26+ 才能使用 BluetoothCodecConfig
- **忽略權限狀態:** Android 12+ 必須在執行時請求 BLUETOOTH_CONNECT 權限
- **假設藍牙一定開啟:** 必須處理藍牙關閉的情況
- **同步呼叫 getProfileProxy:** 這是非同步操作，需要透過 ServiceListener 回調

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| 權限請求流程 | 自己實作權限邏輯 | permission_handler 套件 | 處理不同 Android 版本差異、權限狀態追蹤 |
| Codec 類型轉換 | 自己寫 switch/if | BluetoothCodecConfig 常數對照表 | 官方定義的標準值 |
| 藍牙狀態監聽 | 自己註冊 BroadcastReceiver | BluetoothAdapter 狀態檢查 | 簡化實作 |

**Key insight:** Hidden API 的使用需要謹慎，但這是取得 codec 資訊的唯一途徑。Google 允許這些 API 在 Settings 應用中使用。

## Common Pitfalls

### Pitfall 1: Hidden API 存取限制
**What goes wrong:** Android 9+ 對 hidden API 有存取限制，可能導致 SecurityException
**Why it happens:** Google 限制非系統應用存取 hidden API
**How to avoid:** 使用 reflection 存取 `getCodecStatus()`，並做好例外處理
**Warning signs:** 編譯時找不到 `getCodecStatus()` 方法

### Pitfall 2: Android 12 權限破壞性變更
**What goes wrong:** 在 Android 12+ 未請求 BLUETOOTH_CONNECT 就呼叫 BluetoothDevice.getName() 會 crash
**Why it happens:** Android 12 重構了藍牙權限模型
**How to avoid:** 在存取任何藍牙資訊前先檢查並請求權限
**Warning signs:** SecurityException 提及 BLUETOOTH_CONNECT

### Pitfall 3: A2DP Proxy 未就緒
**What goes wrong:** 在 ServiceListener 回調前嘗試使用 bluetoothA2dp 導致 NullPointerException
**Why it happens:** getProfileProxy 是非同步的
**How to avoid:** 使用 callback 或 suspend function 等待 proxy 就緒
**Warning signs:** bluetoothA2dp 為 null

### Pitfall 4: 無已連接 A2DP 裝置
**What goes wrong:** getActiveDevice() 返回 null，後續程式碼 crash
**Why it happens:** 用戶未連接任何藍牙音訊裝置
**How to avoid:** 檢查 getConnectedDevices() 清單是否為空
**Warning signs:** NullPointerException 在 getCodecStatus 呼叫時

### Pitfall 5: Codec 資訊可能為 null
**What goes wrong:** getCodecStatus() 或 getCodecConfig() 返回 null
**Why it happens:** 某些裝置或驅動程式不回報 codec 資訊
**How to avoid:** 對所有回傳值做 null 檢查，提供預設值或錯誤訊息
**Warning signs:** 特定裝置上顯示空白資訊

## Code Examples

### 取得 BluetoothA2dp Proxy
```kotlin
// Source: Android BluetoothA2dp API
class BluetoothAudioHandler(private val activity: Activity) {
    private var bluetoothA2dp: BluetoothA2dp? = null
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

    private val profileListener = object : BluetoothProfile.ServiceListener {
        override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
            if (profile == BluetoothProfile.A2DP) {
                bluetoothA2dp = proxy as BluetoothA2dp
            }
        }

        override fun onServiceDisconnected(profile: Int) {
            if (profile == BluetoothProfile.A2DP) {
                bluetoothA2dp = null
            }
        }
    }

    fun init() {
        bluetoothAdapter?.getProfileProxy(activity, profileListener, BluetoothProfile.A2DP)
    }

    fun release() {
        bluetoothAdapter?.closeProfileProxy(BluetoothProfile.A2DP, bluetoothA2dp)
    }
}
```

### 取得 Codec 資訊（使用 Reflection）
```kotlin
// Source: GitHub matisiekpl/bluetooth-codec-change
private fun getCodecInfo(device: BluetoothDevice): Map<String, Any> {
    val result = mutableMapOf<String, Any>()

    try {
        // 使用 reflection 存取 hidden API
        val getCodecStatusMethod = BluetoothA2dp::class.java.getMethod(
            "getCodecStatus",
            BluetoothDevice::class.java
        )
        val codecStatus = getCodecStatusMethod.invoke(bluetoothA2dp, device)

        if (codecStatus != null) {
            val getCodecConfigMethod = codecStatus.javaClass.getMethod("getCodecConfig")
            val codecConfig = getCodecConfigMethod.invoke(codecStatus)

            if (codecConfig != null) {
                val getCodecType = codecConfig.javaClass.getMethod("getCodecType")
                val getSampleRate = codecConfig.javaClass.getMethod("getSampleRate")
                val getBitsPerSample = codecConfig.javaClass.getMethod("getBitsPerSample")
                val getChannelMode = codecConfig.javaClass.getMethod("getChannelMode")

                result["codecType"] = getCodecType.invoke(codecConfig) as Int
                result["sampleRate"] = getSampleRate.invoke(codecConfig) as Int
                result["bitsPerSample"] = getBitsPerSample.invoke(codecConfig) as Int
                result["channelMode"] = getChannelMode.invoke(codecConfig) as Int
            }
        }
    } catch (e: Exception) {
        result["error"] = e.message ?: "Unknown error"
    }

    return result
}
```

### BluetoothCodecConfig 常數對照表
```kotlin
// Source: Android AOSP BluetoothCodecConfig.java
object BluetoothCodecConstants {
    // Codec Types
    const val SOURCE_CODEC_TYPE_SBC = 0
    const val SOURCE_CODEC_TYPE_AAC = 1
    const val SOURCE_CODEC_TYPE_APTX = 2
    const val SOURCE_CODEC_TYPE_APTX_HD = 3
    const val SOURCE_CODEC_TYPE_LDAC = 4
    const val SOURCE_CODEC_TYPE_OPUS = 5  // 較新版本
    const val SOURCE_CODEC_TYPE_LC3 = 6   // LE Audio
    const val SOURCE_CODEC_TYPE_INVALID = 1000000

    // Sample Rates (bitmask)
    const val SAMPLE_RATE_NONE = 0
    const val SAMPLE_RATE_44100 = 0x01
    const val SAMPLE_RATE_48000 = 0x02
    const val SAMPLE_RATE_88200 = 0x04
    const val SAMPLE_RATE_96000 = 0x08
    const val SAMPLE_RATE_176400 = 0x10
    const val SAMPLE_RATE_192000 = 0x20

    // Bits Per Sample (bitmask)
    const val BITS_PER_SAMPLE_NONE = 0
    const val BITS_PER_SAMPLE_16 = 0x01
    const val BITS_PER_SAMPLE_24 = 0x02
    const val BITS_PER_SAMPLE_32 = 0x04

    // Channel Mode (bitmask)
    const val CHANNEL_MODE_NONE = 0
    const val CHANNEL_MODE_MONO = 0x01
    const val CHANNEL_MODE_STEREO = 0x02

    fun codecTypeToString(type: Int): String = when (type) {
        SOURCE_CODEC_TYPE_SBC -> "SBC"
        SOURCE_CODEC_TYPE_AAC -> "AAC"
        SOURCE_CODEC_TYPE_APTX -> "aptX"
        SOURCE_CODEC_TYPE_APTX_HD -> "aptX HD"
        SOURCE_CODEC_TYPE_LDAC -> "LDAC"
        SOURCE_CODEC_TYPE_OPUS -> "Opus"
        SOURCE_CODEC_TYPE_LC3 -> "LC3"
        else -> "Unknown"
    }

    fun sampleRateToString(rate: Int): String = when (rate) {
        SAMPLE_RATE_44100 -> "44.1 kHz"
        SAMPLE_RATE_48000 -> "48 kHz"
        SAMPLE_RATE_88200 -> "88.2 kHz"
        SAMPLE_RATE_96000 -> "96 kHz"
        SAMPLE_RATE_176400 -> "176.4 kHz"
        SAMPLE_RATE_192000 -> "192 kHz"
        else -> "Unknown"
    }

    fun bitsPerSampleToString(bits: Int): String = when (bits) {
        BITS_PER_SAMPLE_16 -> "16 bit"
        BITS_PER_SAMPLE_24 -> "24 bit"
        BITS_PER_SAMPLE_32 -> "32 bit"
        else -> "Unknown"
    }

    fun channelModeToString(mode: Int): String = when (mode) {
        CHANNEL_MODE_MONO -> "Mono"
        CHANNEL_MODE_STEREO -> "Stereo"
        else -> "Unknown"
    }
}
```

### Flutter 端權限處理
```dart
// Source: permission_handler documentation
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestBluetoothPermission() async {
  // 檢查 Android 版本
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 31) {
      // Android 12+
      final status = await Permission.bluetoothConnect.request();
      return status.isGranted;
    } else {
      // Android 11 及以下不需要執行時權限
      return true;
    }
  }
  return false;
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| BLUETOOTH/BLUETOOTH_ADMIN 權限 | BLUETOOTH_CONNECT/SCAN/ADVERTISE | Android 12 (API 31) | 必須動態請求權限 |
| Classic Bluetooth Audio | LE Audio (LC3 codec) | Android 12+ | 新 codec 類型需要支援 |
| 單一 Bluetooth 權限 | 三個獨立權限 | Android 12 (2021) | 更細粒度的權限控制 |

**Deprecated/outdated:**
- `BluetoothAdapter.startDiscovery()` 在 Android 12+ 需要 BLUETOOTH_SCAN 權限
- 舊版 BLUETOOTH 權限在 Android 12+ 不再有效

## Open Questions

1. **Hidden API 在特定 OEM 裝置的相容性**
   - What we know: 大部分主流裝置支援透過 reflection 存取
   - What's unclear: 特定廠商（如華為）可能有額外限制
   - Recommendation: 做好 try-catch 處理，提供 graceful degradation

2. **Bitrate 資訊的取得方式**
   - What we know: BluetoothCodecConfig 沒有直接的 getBitrate() 方法
   - What's unclear: 可能需要從 getCodecSpecific1-4() 方法計算
   - Recommendation: 先實作基本功能，bitrate 可能需要針對各 codec 做特殊處理

3. **藍牙版本的顯示**
   - What we know: Android 沒有公開 API 取得藍牙版本號
   - What's unclear: 是否可以透過系統屬性或 hidden API 取得
   - Recommendation: 改為顯示「藍牙狀態」或略過此需求，或使用 BluetoothAdapter 的 isLeExtendedAdvertisingSupported() 等方法推斷

4. **裝置電量取得**
   - What we know: BluetoothDevice 有 getBatteryLevel() 方法 (hidden API)
   - What's unclear: 只有部分裝置支援回報電量
   - Recommendation: 嘗試取得，若失敗則顯示「不支援」

## Sources

### Primary (HIGH confidence)
- [Android BluetoothA2dp API Reference](https://developer.android.com/reference/android/bluetooth/BluetoothA2dp) - getActiveDevice, getConnectedDevices
- [Android BluetoothCodecConfig API Reference](https://developer.android.com/reference/android/bluetooth/BluetoothCodecConfig) - Codec 常數定義
- [Android Bluetooth Permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions) - 權限配置
- [AOSP BluetoothCodecConfig.java](https://android.googlesource.com/platform/frameworks/base/+/feeb9b245c7aa04ba8f729048bac78efabf9e801/core/java/android/bluetooth/BluetoothCodecConfig.java) - 常數數值

### Secondary (MEDIUM confidence)
- [GitHub matisiekpl/bluetooth-codec-change](https://github.com/matisiekpl/bluetooth-codec-change) - Hidden API 存取模式
- [permission_handler 套件](https://pub.dev/packages/permission_handler) - Flutter 權限處理

### Tertiary (LOW confidence)
- Hidden API 在不同 OEM 的相容性 - 需實際測試驗證
- Bitrate 計算方式 - 需進一步研究

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - 基於官方 Android API 文件
- Architecture: HIGH - 遵循專案現有模式
- Pitfalls: MEDIUM - 部分基於社群經驗，需實際測試

**Research date:** 2026-02-08
**Valid until:** 30 days (Android API 穩定)
