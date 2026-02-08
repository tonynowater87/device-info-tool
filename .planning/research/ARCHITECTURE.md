# 架構模式：Flutter Bluetooth Audio 整合

**領域：** Flutter 應用程式與 Android Bluetooth A2DP 原生整合
**研究日期：** 2026-02-08
**信心等級：** MEDIUM-HIGH

## 推薦架構

Flutter Bluetooth Audio 功能應該使用 **三層架構**，遵循專案現有的 BLoC pattern，透過 Platform Channel 與 Android 原生 Bluetooth API 溝通。

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Layer (Dart)                      │
├─────────────────────────────────────────────────────────────┤
│  BluetoothAudioPage (UI)                                     │
│       ↓↑ BlocBuilder/BlocConsumer                            │
│  BluetoothAudioCubit (State Management)                      │
│       ↓↑ emit states                                         │
│  BluetoothAudioState (Initial/Loading/Success/Error)         │
├─────────────────────────────────────────────────────────────┤
│                 Platform Channel Bridge                      │
│  MethodChannel("com.tonynowater.mobileosversions")          │
│       ↓↑ invokeMethod / MethodCallHandler                   │
├─────────────────────────────────────────────────────────────┤
│               Android Native Layer (Kotlin)                  │
├─────────────────────────────────────────────────────────────┤
│  MainActivity.kt                                             │
│       ↓ creates                                              │
│  BluetoothAudioHandler.kt                                    │
│       ↓ uses                                                 │
│  BluetoothA2dp / BluetoothCodecConfig API                   │
└─────────────────────────────────────────────────────────────┘
```

### 元件邊界

| 元件 | 職責 | 溝通對象 |
|------|------|----------|
| **BluetoothAudioPage** | UI 顯示、使用者互動 | BluetoothAudioCubit（透過 BlocBuilder） |
| **BluetoothAudioCubit** | 業務邏輯、狀態管理、Platform Channel 呼叫 | BluetoothAudioPage（emit states）、Platform Channel（invokeMethod） |
| **BluetoothAudioState** | 狀態資料模型（Initial/Loading/Success/Error） | BluetoothAudioCubit（被創建和 emit） |
| **MainActivity** | Flutter 引擎設定、註冊 MethodChannel handler | BluetoothAudioHandler（method routing） |
| **BluetoothAudioHandler** | Platform Channel 請求處理、呼叫 Android Bluetooth API | BluetoothA2dp、BluetoothCodecConfig、BluetoothProfile |
| **Android Bluetooth APIs** | 系統級藍牙功能（codec 查詢、切換） | BluetoothAudioHandler（被呼叫） |

### 資料流向

#### 1. 查詢藍牙裝置資訊流程

```
[User 開啟頁面]
    ↓
BluetoothAudioPage.initState()
    ↓
cubit.loadBluetoothInfo()
    ↓
emit(BluetoothAudioLoading())
    ↓
MethodChannel.invokeMethod("getBluetoothInfo")
    ↓
[Platform Channel Bridge]
    ↓
BluetoothAudioHandler.handle(call, result)
    ↓
BluetoothA2dp.getCodecStatus(device)
    ↓
返回 Map<String, dynamic> {
    "deviceName": "...",
    "deviceAddress": "...",
    "currentCodec": "LDAC",
    "sampleRate": "96000",
    "bitsPerSample": "24",
    "supportedCodecs": ["SBC", "AAC", "LDAC"],
    ...
}
    ↓
[Platform Channel Bridge]
    ↓
cubit 接收結果
    ↓
emit(BluetoothAudioSuccess(data: info))
    ↓
BlocBuilder 重建 UI
    ↓
[畫面顯示藍牙資訊]
```

#### 2. 切換 Codec 流程

```
[User 點擊 Codec 選項]
    ↓
cubit.changeCodec("LDAC")
    ↓
emit(BluetoothAudioLoading())
    ↓
MethodChannel.invokeMethod("setCodec", {"codec": "LDAC"})
    ↓
[Platform Channel Bridge]
    ↓
BluetoothAudioHandler.handle(call, result)
    ↓
BluetoothCodecConfig.Builder()
    .setCodecType(SOURCE_CODEC_TYPE_LDAC)
    .build()
    ↓
BluetoothA2dp.setCodecConfigPreference(device, config)
    ↓
返回 success: true
    ↓
[Platform Channel Bridge]
    ↓
cubit 接收結果
    ↓
cubit.loadBluetoothInfo() // 重新讀取最新狀態
    ↓
emit(BluetoothAudioSuccess(data: updatedInfo))
    ↓
[畫面更新為新 codec]
```

#### 3. 錯誤處理流程

```
任何環節錯誤
    ↓
PlatformException thrown
    ↓
cubit catch 區塊
    ↓
emit(BluetoothAudioError(message: "..."))
    ↓
BlocBuilder 重建 UI
    ↓
[顯示錯誤訊息與重試按鈕]
```

### 建議建構順序（依賴關係）

基於元件間依賴，建議建構順序：

1. **Phase 1: 資料模型與狀態** (無依賴)
   - `BluetoothAudioState` classes (Initial/Loading/Success/Error)
   - `BluetoothDeviceInfo` data model

2. **Phase 2: Android 原生層** (依賴 Phase 1 的資料結構定義)
   - `BluetoothAudioHandler.kt` 基本架構
   - 實作 `getBluetoothInfo()` method（唯讀操作，風險低）
   - 測試 Platform Channel 通訊

3. **Phase 3: Flutter 狀態管理** (依賴 Phase 2 的 Platform Channel)
   - `BluetoothAudioCubit` 基本架構
   - 實作 `loadBluetoothInfo()` method
   - 測試 cubit 狀態轉換

4. **Phase 4: Flutter UI** (依賴 Phase 3 的 Cubit)
   - `BluetoothAudioPage` 基本 UI
   - 實作唯讀顯示（裝置名稱、MAC、目前 codec）
   - BlocBuilder 整合

5. **Phase 5: Codec 切換功能** (依賴 Phase 4 的完整堆疊)
   - 在 `BluetoothAudioHandler.kt` 新增 `setCodec()` method
   - 在 `BluetoothAudioCubit` 新增 `changeCodec()` method
   - UI 新增互動元件（DropdownButton 或 SegmentedButton）

6. **Phase 6: 進階參數調整** (依賴 Phase 5)
   - 取樣率切換
   - 位元深度切換
   - Bitrate 切換

**依賴圖：**
```
Phase 1 (資料模型)
    ↓
Phase 2 (Android 原生層) → Phase 3 (Flutter 狀態管理)
    ↓                             ↓
    └─────────→ Phase 4 (Flutter UI)
                      ↓
                Phase 5 (Codec 切換)
                      ↓
                Phase 6 (進階參數)
```

**為什麼這個順序？**
- 由下而上（Native → Cubit → UI）確保每一層都可以獨立測試
- 先建構唯讀功能降低風險（讀取不會改變系統狀態）
- Codec 切換需要完整堆疊測試，放在中後期
- 進階參數是 codec 切換的延伸，放在最後

## 遵循的模式

### 模式 1：Cubit 用於簡單狀態流

**定義：** 使用 Cubit 而非完整 Bloc，因為藍牙音訊功能是簡單的 CRUD 操作（查詢/設定），不需要複雜的事件流。

**何時使用：** 當狀態轉換簡單、不需要 event replay 或進階除錯時。

**範例：**
```dart
class BluetoothAudioCubit extends Cubit<BluetoothAudioState> {
  final MethodChannel _channel;

  BluetoothAudioCubit(this._channel) : super(BluetoothAudioInitial());

  Future<void> loadBluetoothInfo() async {
    emit(BluetoothAudioLoading());
    try {
      final result = await _channel.invokeMethod('getBluetoothInfo');
      final info = BluetoothDeviceInfo.fromMap(result);
      emit(BluetoothAudioSuccess(info: info));
    } on PlatformException catch (e) {
      emit(BluetoothAudioError(message: e.message ?? 'Unknown error'));
    }
  }

  Future<void> changeCodec(String codecType) async {
    emit(BluetoothAudioLoading());
    try {
      await _channel.invokeMethod('setCodec', {'codec': codecType});
      await loadBluetoothInfo(); // 重新載入狀態
    } on PlatformException catch (e) {
      emit(BluetoothAudioError(message: e.message ?? 'Failed to change codec'));
    }
  }
}
```

**理由：**
- 專案現有的 `AndroidVersionPageCubit` 已使用 Cubit pattern
- 藍牙音訊是簡單的請求-回應流程，不需要複雜的事件追蹤
- 減少 boilerplate code

**來源：**
- [Flutter BLoC Tutorial: Mastering State Management in 2026](https://www.zignuts.com/blog/flutter-bloc-tutorial)
- [Bloc vs Cubit in Flutter: When Should You Use Each?](https://medium.com/@wassimsakri/bloc-vs-cubit-in-flutter-when-should-you-use-each-5dc21c20c053)

### 模式 2：Handler 類別分離原生程式碼

**定義：** 將 Platform Channel 處理邏輯從 MainActivity 抽離到專用的 Handler 類別（如 `BluetoothAudioHandler`），遵循專案現有的 `DeviceInfoHandler`、`BatteryInfoHandler` 模式。

**何時使用：** 當原生功能複雜度超過 30 行程式碼時。

**範例：**
```kotlin
class BluetoothAudioHandler(private val activity: Activity) {
    private var bluetoothA2dp: BluetoothA2dp? = null

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBluetoothInfo" -> getBluetoothInfo(result)
            "setCodec" -> setCodec(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getBluetoothInfo(result: MethodChannel.Result) {
        // 實作細節
    }
}
```

**為什麼好：**
- 單一職責原則（SRP）— MainActivity 只負責 routing
- 可測試性 — Handler 可以獨立單元測試
- 可維護性 — 藍牙相關邏輯集中管理

**來源：** 專案現有程式碼分析（DeviceInfoHandler.kt）

### 模式 3：MethodChannel 統一命名規範

**定義：** 使用專案現有的 channel name `"com.tonynowater.mobileosversions"`，所有原生功能透過同一個 MethodChannel，以 method name 區分功能。

**何時使用：** 在中小型專案中，多個原生功能可以共用一個 channel。

**範例：**
```kotlin
// MainActivity.kt
MethodChannel(
    flutterEngine.dartExecutor.binaryMessenger,
    "com.tonynowater.mobileosversions"
).setMethodCallHandler { call, result ->
    when (call.method) {
        "getDeviceInfo" -> deviceInfoHandler.handle(call, result)
        "getBatteryInfo" -> batteryInfoHandler.handle(call, result)
        "getBluetoothInfo" -> bluetoothAudioHandler.handle(call, result)
        "setCodec" -> bluetoothAudioHandler.handle(call, result)
        else -> result.notImplemented()
    }
}
```

```dart
// Flutter side
final _channel = MethodChannel('com.tonynowater.mobileosversions');
final info = await _channel.invokeMethod('getBluetoothInfo');
```

**理由：**
- 維持專案一致性
- 減少 channel 註冊數量（每個 channel 都有記憶體成本）
- 方便在 MainActivity 統一管理所有 Platform Channel routing

### 模式 4：錯誤處理三層防護

**定義：** 在 Native、Platform Channel、Cubit 三層都實作錯誤處理，確保任何層級的錯誤都能優雅降級。

**實作：**

**Layer 1: Native (Kotlin)**
```kotlin
private fun getBluetoothInfo(result: MethodChannel.Result) {
    try {
        val info = mutableMapOf<String, Any>()
        // ... Bluetooth API calls
        result.success(info)
    } catch (e: SecurityException) {
        result.error("PERMISSION_DENIED", "Bluetooth permission not granted", null)
    } catch (e: Exception) {
        result.error("BLUETOOTH_ERROR", e.message, null)
    }
}
```

**Layer 2: Platform Channel (透過 PlatformException)**
```dart
try {
    final result = await _channel.invokeMethod('getBluetoothInfo');
    // ...
} on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
        emit(BluetoothAudioError(message: '需要藍牙權限'));
    } else {
        emit(BluetoothAudioError(message: e.message ?? 'Unknown error'));
    }
}
```

**Layer 3: UI (Flutter)**
```dart
BlocBuilder<BluetoothAudioCubit, BluetoothAudioState>(
  builder: (context, state) {
    if (state is BluetoothAudioError) {
      return ErrorWidget(
        message: state.message,
        onRetry: () => context.read<BluetoothAudioCubit>().loadBluetoothInfo(),
      );
    }
    // ...
  },
)
```

**來源：**
- [Error handling in Flutter plugins – Corner Software](https://csdcorp.com/blog/coding/error-handling-in-flutter-plugins/)
- [Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)

### 模式 5：狀態機模式（State Machine）

**定義：** 使用清晰的狀態定義，避免中間狀態混亂。

**狀態定義：**
```dart
abstract class BluetoothAudioState {}

class BluetoothAudioInitial extends BluetoothAudioState {}

class BluetoothAudioLoading extends BluetoothAudioState {}

class BluetoothAudioSuccess extends BluetoothAudioState {
  final BluetoothDeviceInfo info;
  BluetoothAudioSuccess({required this.info});
}

class BluetoothAudioNoDevice extends BluetoothAudioState {}

class BluetoothAudioError extends BluetoothAudioState {
  final String message;
  BluetoothAudioError({required this.message});
}
```

**狀態轉換：**
```
Initial → Loading → Success
                 → NoDevice
                 → Error

Success → Loading → Success (refresh)
                 → NoDevice
                 → Error

Error → Loading → Success (retry)
```

**為什麼好：**
- 清晰的狀態轉換，容易除錯
- 每個狀態都有對應的 UI
- 避免「loading 時又收到新資料」的 race condition

## 反模式（避免）

### 反模式 1：直接在 MainActivity 寫藍牙邏輯

**問題：**
```kotlin
// ❌ 不好
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MethodChannel(...).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBluetoothInfo" -> {
                    // 200 行藍牙程式碼直接寫在這裡
                    val adapter = BluetoothAdapter.getDefaultAdapter()
                    // ...
                }
            }
        }
    }
}
```

**為什麼不好：**
- MainActivity 變成 God Object（上千行）
- 無法單獨測試藍牙功能
- 違反專案既有的 Handler 模式

**應該這樣：**
```kotlin
// ✓ 好
class MainActivity : FlutterActivity() {
    private lateinit var bluetoothAudioHandler: BluetoothAudioHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        bluetoothAudioHandler = BluetoothAudioHandler(this)

        MethodChannel(...).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBluetoothInfo", "setCodec" ->
                    bluetoothAudioHandler.handle(call, result)
            }
        }
    }
}
```

### 反模式 2：使用 EventChannel 串流藍牙狀態

**問題：**
```dart
// ❌ 不需要
EventChannel('bluetooth_stream').receiveBroadcastStream().listen((event) {
  // 監聽藍牙狀態變化
});
```

**為什麼不好（針對這個使用案例）：**
- 藍牙 codec 資訊不是高頻率變化的資料（不像電池電量每秒變化）
- EventChannel 增加複雜度（需要處理 stream lifecycle、backpressure）
- 使用者期望是「點擊後查詢」，不是「持續監聽」

**應該這樣：**
```dart
// ✓ 好 - 使用 MethodChannel pull 模式
Future<void> loadBluetoothInfo() async {
  final result = await _channel.invokeMethod('getBluetoothInfo');
  // ...
}
```

**例外情況：** 如果未來要實作「藍牙裝置斷線自動提示」，才考慮 EventChannel。

**來源：**
- [The Ultimate Guide to Utilizing Flutter Platform Channels](https://www.dhiwise.com/post/leveraging-flutter-platform-channels-for-interactive-app)
- [Building Custom Platform Channels in Flutter](https://dev.to/anurag_dev/building-custom-platform-channels-in-flutter-a-complete-guide-to-native-integration-2m5g)

### 反模式 3：在 UI 層直接呼叫 Platform Channel

**問題：**
```dart
// ❌ 不好
class BluetoothAudioPage extends StatelessWidget {
  final _channel = MethodChannel('...');

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await _channel.invokeMethod('setCodec', {'codec': 'AAC'});
        // 直接在 UI 處理結果
      },
    );
  }
}
```

**為什麼不好：**
- 違反 BLoC 架構（業務邏輯應該在 Cubit）
- 無法測試業務邏輯（UI 測試困難）
- 狀態管理混亂（UI 同時處理顯示和資料獲取）

**應該這樣：**
```dart
// ✓ 好
class BluetoothAudioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<BluetoothAudioCubit>().changeCodec('AAC');
      },
    );
  }
}
```

### 反模式 4：過早優化 - 快取 Codec 狀態

**問題：**
```dart
// ❌ 不需要
class BluetoothAudioCubit extends Cubit<BluetoothAudioState> {
  BluetoothDeviceInfo? _cachedInfo;
  DateTime? _lastFetchTime;

  Future<void> loadBluetoothInfo() async {
    if (_cachedInfo != null &&
        DateTime.now().difference(_lastFetchTime!) < Duration(seconds: 5)) {
      emit(BluetoothAudioSuccess(info: _cachedInfo!));
      return; // 使用快取
    }
    // 否則重新查詢
  }
}
```

**為什麼不好（針對這個使用案例）：**
- 藍牙 codec 資訊查詢非常快（< 100ms）
- 增加複雜度（快取失效邏輯、記憶體管理）
- 快取可能導致 UI 顯示過時資訊（用戶剛從系統設定改了 codec）

**應該這樣：**
```dart
// ✓ 好 - 每次都重新查詢
Future<void> loadBluetoothInfo() async {
  emit(BluetoothAudioLoading());
  final result = await _channel.invokeMethod('getBluetoothInfo');
  // ...
}
```

## 擴充性考量

### 情境：未來要新增更多藍牙功能

| 目前規模 | 100 個使用者 | 10K 個使用者 | 1M 個使用者 |
|---------|-------------|-------------|-------------|
| **架構** | 單一 BluetoothAudioHandler | 拆分成多個 Handler（AudioHandler、ProfileHandler） | 考慮 plugin 模式（獨立 Flutter plugin package） |
| **Platform Channel** | 共用 channel，用 method name 區分 | 共用 channel，但在 Kotlin 層做更明確的 routing | 考慮專用 channel（"bluetooth_audio"） |
| **狀態管理** | Cubit 足夠 | Cubit 足夠 | 如果需要複雜 event tracking，考慮升級成 Bloc |
| **錯誤處理** | 基本 try-catch | 加入 Analytics 追蹤錯誤率 | 加入 Sentry 或 Crashlytics 詳細追蹤 |
| **快取策略** | 不需要 | 不需要 | 如果查詢變慢，考慮短期快取（1-2 秒） |

### 未來擴充方向

**1. 支援更多藍牙功能：**
```kotlin
// 目前
class BluetoothAudioHandler { ... }

// 未來可擴充
class BluetoothAudioHandler { ... }    // A2DP codec 控制
class BluetoothProfileHandler { ... }  // Profile 切換（A2DP/HFP/AVRCP）
class BluetoothDeviceHandler { ... }   // 裝置配對/掃描
```

**2. iOS 部分支援（唯讀）：**
- iOS 雖然不能切換 codec，但可以查詢目前連接的 AAC codec 資訊
- 可以在 Flutter 層加入 platform check，Android 顯示完整功能，iOS 只顯示唯讀資訊

**3. 整合成獨立 Flutter Plugin：**
- 如果未來其他專案也需要藍牙音訊功能，可以抽離成 `flutter_bluetooth_audio_config` plugin
- 保持 API 一致性，方便維護

## 來源

### HIGH 信心來源

- [Android BluetoothCodecConfig API reference](https://developer.android.com/reference/android/bluetooth/BluetoothCodecConfig)
- [Android BluetoothA2dp API reference](https://developer.android.com/reference/android/bluetooth/BluetoothA2dp)
- [Flutter Platform Channels 官方文件](https://docs.flutter.dev/platform-integration/platform-channels)
- 專案現有程式碼：MainActivity.kt、DeviceInfoHandler.kt、AndroidVersionPageCubit.dart

### MEDIUM 信心來源

- [Flutter BLoC Tutorial: Mastering State Management in 2026](https://www.zignuts.com/blog/flutter-bloc-tutorial)
- [Bloc vs Cubit in Flutter: When Should You Use Each?](https://medium.com/@wassimsakri/bloc-vs-cubit-in-flutter-when-should-you-use-each-5dc21c20c053)
- [Android Bluetooth permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions)
- [Error handling in Flutter plugins – Corner Software](https://csdcorp.com/blog/coding/error-handling-in-flutter-plugins/)

### LOW 信心來源（需驗證）

- [GitHub - matisiekpl/bluetooth-codec-change](https://github.com/matisiekpl/bluetooth-codec-change) — 社群實作範例，需驗證 API 正確性
- [Bluetooth® A2DP API - ESP32](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/bluetooth/esp_a2dp.html) — ESP32 文件，概念相似但 API 不同

---

**信心評估總結：**
- **架構模式：** HIGH（基於專案現有成熟架構）
- **Platform Channel 整合：** HIGH（專案已有多個實作案例）
- **Android Bluetooth API：** MEDIUM-HIGH（官方 API 文件完整，但 `setCodecConfigPreference` 可能是 hidden API）
- **BLoC/Cubit 選擇：** HIGH（社群共識明確，專案已使用 Cubit）
- **錯誤處理策略：** MEDIUM（最佳實踐來自社群經驗，非官方規範）

**需要在實作階段驗證的部分：**
- `setCodecConfigPreference` 是否需要系統權限或開發者選項
- Android 12+ 藍牙權限的實際請求流程
- Codec 切換後是否需要重新連線藍牙裝置
