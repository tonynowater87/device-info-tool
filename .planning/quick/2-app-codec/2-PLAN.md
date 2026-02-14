---
phase: quick
plan: 2-app-codec
type: execute
wave: 1
depends_on: []
files_modified:
  - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
  - lib/data/model/bluetooth_audio_model.dart
  - lib/view/bluetoothaudio/bluetooth_audio_state.dart
  - lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
  - lib/view/bluetoothaudio/bluetooth_audio_page.dart
autonomous: false

must_haves:
  truths:
    - "使用者可以看到目前 codec 參數（取樣率/位元深度/聲道模式）的下拉選單，顯示裝置支援的選項"
    - "使用者選擇不同的參數值後，codec 設定會即時套用到藍牙連線"
    - "套用後頁面會重新載入並顯示更新後的 codec 資訊"
    - "LDAC codec 時顯示額外的品質模式選擇器（990/660/330/ABR）"
  artifacts:
    - path: "android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt"
      provides: "getCodecCapabilities 和 setBluetoothCodecConfig 原生方法"
      contains: "setCodecConfigPreference"
    - path: "lib/data/model/bluetooth_audio_model.dart"
      provides: "CodecCapabilities 模型，包含可選取的取樣率/位元深度/聲道模式清單"
    - path: "lib/view/bluetoothaudio/bluetooth_audio_page.dart"
      provides: "互動式下拉選單取代靜態文字顯示"
  key_links:
    - from: "bluetooth_audio_page.dart"
      to: "bluetooth_audio_cubit.dart"
      via: "cubit.setCodecConfig() 呼叫"
      pattern: "setCodecConfig"
    - from: "bluetooth_audio_cubit.dart"
      to: "BluetoothAudioHandler.kt"
      via: "MethodChannel invokeMethod('setBluetoothCodecConfig')"
      pattern: "setBluetoothCodecConfig"
    - from: "BluetoothAudioHandler.kt"
      to: "BluetoothA2dp"
      via: "reflection setCodecConfigPreference"
      pattern: "setCodecConfigPreference"
---

<objective>
實作 App 內直接切換藍牙 codec 參數功能，包含取樣率、位元深度、聲道模式及 LDAC 品質模式的選擇。

Purpose: 讓使用者不需進入系統開發者選項，即可在 App 內調整藍牙音訊 codec 參數。
Output: 可互動的 codec 參數選擇 UI，透過 Android hidden API 即時套用設定。
</objective>

<context>
@android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
@lib/data/model/bluetooth_audio_model.dart
@lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
@lib/view/bluetoothaudio/bluetooth_audio_state.dart
@lib/view/bluetoothaudio/bluetooth_audio_page.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Android 原生端 - 新增取得 codec capabilities 與設定 codec config 方法</name>
  <files>android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt</files>
  <action>
在 BluetoothAudioHandler 中新增兩個功能：

1. **擴充 getCodecInfo 回傳 selectable capabilities：**
   - 在現有 `getCodecInfo()` 方法中，取得 `codecStatus` 後，額外呼叫：
     - `codecStatus.getCodecsSelectableCapabilities()` (透過 reflection) 取得可選取的 codec 能力清單
   - 對每個 selectable capability，取出其 codecType、sampleRate、bitsPerSample、channelMode（這些是 bitmask，代表該 codec 支援的所有值）
   - 找出與當前 codecType 相同的 selectable capability，解析 bitmask 為個別值清單
   - 在回傳的 result map 中加入：
     - `selectableSampleRates`: List<Map> 每項含 `value`(int bitmask) 和 `label`(String)
     - `selectableBitsPerSample`: List<Map> 每項含 `value`(int) 和 `label`(String)
     - `selectableChannelModes`: List<Map> 每項含 `value`(int) 和 `label`(String)
     - `currentCodecType`: Int (當前 codec type 的原始 int 值，用於建構 BluetoothCodecConfig)
     - `currentSampleRate`: Int (當前取樣率原始 int 值)
     - `currentBitsPerSample`: Int (當前位元深度原始 int 值)
     - `currentChannelMode`: Int (當前聲道模式原始 int 值)
     - `currentCodecSpecific1`: Long (當前 codecSpecific1 值，用於 LDAC bitrate)
   - Bitmask 解析邏輯：使用 BluetoothCodecConstants 中已定義的常數，例如 sampleRate bitmask 0x03 表示同時支援 44100(0x01) 和 48000(0x02)
   - 如果取得 selectable capabilities 失敗，不影響原有功能，只是不回傳 selectable 欄位

2. **新增 `setBluetoothCodecConfig` method channel handler：**
   - 在 `handle()` 的 when 中加入 `"setBluetoothCodecConfig"` case
   - 接收參數：`codecType`(int), `sampleRate`(int), `bitsPerSample`(int), `channelMode`(int), `codecSpecific1`(long)
   - 取得已連接的 A2DP 裝置（同 getBluetoothAudioInfo 邏輯）
   - 使用 reflection 建構 BluetoothCodecConfig：
     - API 33+: 使用 `BluetoothCodecConfig.Builder` 類別（公開 API）
       ```kotlin
       val builderClass = Class.forName("android.bluetooth.BluetoothCodecConfig\$Builder")
       val builder = builderClass.getConstructor().newInstance()
       builderClass.getMethod("setCodecType", Int::class.java).invoke(builder, codecType)
       builderClass.getMethod("setSampleRate", Int::class.java).invoke(builder, sampleRate)
       builderClass.getMethod("setBitsPerSample", Int::class.java).invoke(builder, bitsPerSample)
       builderClass.getMethod("setChannelMode", Int::class.java).invoke(builder, channelMode)
       builderClass.getMethod("setCodecSpecific1", Long::class.java).invoke(builder, codecSpecific1)
       val codecConfig = builderClass.getMethod("build").invoke(builder)
       ```
     - API 26-32: 使用 BluetoothCodecConfig 建構子（透過 reflection）
       ```kotlin
       val configClass = Class.forName("android.bluetooth.BluetoothCodecConfig")
       val constructor = configClass.getConstructor(
           Int::class.java, Int::class.java, Int::class.java, Int::class.java, Int::class.java,
           Long::class.java, Long::class.java, Long::class.java, Long::class.java
       )
       val codecConfig = constructor.newInstance(codecType, 1000000/*CODEC_PRIORITY_HIGHEST*/, sampleRate, bitsPerSample, channelMode, codecSpecific1, 0L, 0L, 0L)
       ```
   - 透過 reflection 呼叫 `bluetoothA2dp.setCodecConfigPreference(device, codecConfig)`：
     ```kotlin
     val setMethod = BluetoothA2dp::class.java.getMethod(
         "setCodecConfigPreference",
         BluetoothDevice::class.java,
         Class.forName("android.bluetooth.BluetoothCodecConfig")
     )
     setMethod.invoke(bluetoothA2dp, device, codecConfig)
     ```
   - 成功時回傳 `mapOf("success" to true)`
   - 失敗時回傳 `mapOf("success" to false, "error" to errorMessage)`
   - 注意：Android 16+ 需要 CDM association，呼叫前同樣執行 ensureCdmAssociation

3. **在 BluetoothCodecConstants 新增輔助方法：**
   - `fun parseSampleRateBitmask(bitmask: Int): List<Map<String, Any>>` - 將 bitmask 拆解為個別取樣率值和標籤的清單
   - `fun parseBitsPerSampleBitmask(bitmask: Int): List<Map<String, Any>>` - 同上
   - `fun parseChannelModeBitmask(bitmask: Int): List<Map<String, Any>>` - 同上
   - 每個方法檢查 bitmask 中的每個 bit，如果設定了就加入對應的值和標籤
  </action>
  <verify>
  專案可成功編譯：在專案根目錄執行 `cd android && ./gradlew assembleDebug` 確認無編譯錯誤
  </verify>
  <done>
  BluetoothAudioHandler 能透過 reflection 取得 selectable codec capabilities 並回傳給 Flutter 端，也能接收 setBluetoothCodecConfig 呼叫透過 reflection 設定 codec 參數
  </done>
</task>

<task type="auto">
  <name>Task 2: Flutter 端 - Model/State/Cubit 擴充與 UI 互動化</name>
  <files>
    lib/data/model/bluetooth_audio_model.dart
    lib/view/bluetoothaudio/bluetooth_audio_state.dart
    lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
    lib/view/bluetoothaudio/bluetooth_audio_page.dart
  </files>
  <action>
**Model 擴充 (`bluetooth_audio_model.dart`)：**
- 新增 `CodecOption` 類別：含 `int value` 和 `String label`，有 `fromMap` factory
- 新增 `CodecCapabilities` 類別：含 `List<CodecOption> sampleRates`、`List<CodecOption> bitsPerSample`、`List<CodecOption> channelModes`，有 `fromMap` factory
- 新增 `CodecRawValues` 類別：含 `int codecType`、`int sampleRate`、`int bitsPerSample`、`int channelMode`、`int codecSpecific1`，有 `fromMap` factory
- 擴充 `BluetoothAudioInfo`：新增可選欄位 `CodecCapabilities? capabilities` 和 `CodecRawValues? rawValues`
- 在 `BluetoothAudioInfo.fromMap` 中解析新欄位（判斷 map 中是否有 `selectableSampleRates` key）

**State 擴充 (`bluetooth_audio_state.dart`)：**
- 新增 `BluetoothAudioSettingCodec extends BluetoothAudioState`：表示正在套用 codec 設定中，含 `BluetoothAudioInfo audioInfo` 以保持 UI 顯示
- 新增 `BluetoothAudioCodecSetError extends BluetoothAudioState`：設定失敗，含 `String message` 和 `BluetoothAudioInfo audioInfo`

**Cubit 擴充 (`bluetooth_audio_cubit.dart`)：**
- 新增 `Future<void> setCodecConfig({required int sampleRate, required int bitsPerSample, required int channelMode, required int codecSpecific1})` 方法：
  - 從當前 state 取得 audioInfo（必須是 BluetoothAudioLoaded 或 BluetoothAudioSettingCodec）
  - emit BluetoothAudioSettingCodec(audioInfo: currentAudioInfo)
  - 呼叫 `_channel.invokeMethod('setBluetoothCodecConfig', { 'codecType': audioInfo.rawValues!.codecType, 'sampleRate': sampleRate, 'bitsPerSample': bitsPerSample, 'channelMode': channelMode, 'codecSpecific1': codecSpecific1 })`
  - 成功後等待 500ms（讓系統套用設定），再呼叫 `load()` 重新載入顯示最新狀態
  - 失敗時 emit BluetoothAudioCodecSetError

**UI 改造 (`bluetooth_audio_page.dart`)：**
- 修改 `_buildLoadedView`，在 codec 區塊中：
  - 保留 codecType 為靜態顯示（不可更改）
  - 如果 `audioInfo.capabilities != null && audioInfo.rawValues != null`：
    - sampleRate：改為 `DropdownButton<int>`，items 來自 `capabilities.sampleRates`，selectedValue 為 `rawValues.sampleRate`
    - bitsPerSample：同上，改為 DropdownButton
    - channelMode：同上，改為 DropdownButton
    - bitrate/LDAC quality：如果 `rawValues.codecType == 4`(LDAC)，顯示 DropdownButton 讓使用者選擇品質模式：
      - 選項：`{value: 1000, label: "990 kbps (最高品質)"}`、`{value: 660, label: "660 kbps (標準)"}`、`{value: 330, label: "330 kbps (連接優先)"}`、`{value: 0, label: "ABR (自適應)"}`
      - selectedValue 為 `rawValues.codecSpecific1`
    - 如果不是 LDAC，bitrate 維持靜態文字
  - 如果 `capabilities == null`，維持全部靜態顯示（向下相容）
  - 每個 DropdownButton onChanged 時呼叫 `cubit.setCodecConfig()`，傳入所有參數（變更的用新值，其他維持當前 rawValues）
- 新增 `_buildDropdownRow(String label, int currentValue, List<CodecOption> options, ValueChanged<int?> onChanged)` 方法：
  - 與 `_buildInfoRow` 類似的排版
  - 使用 `DropdownButton<int>` 或 `DropdownButtonFormField<int>`
  - 下拉選項用 options 的 label 顯示，value 為 int 值
  - 設定 `isExpanded: true`，`underline: SizedBox.shrink()` 保持簡潔風格
- 處理 BluetoothAudioSettingCodec state：顯示載入中的 overlay 或在 card 上方顯示 LinearProgressIndicator
- 處理 BluetoothAudioCodecSetError state：顯示錯誤 SnackBar 後恢復顯示
  </action>
  <verify>
  執行 `flutter analyze` 確認無靜態分析錯誤；執行 `flutter build apk --debug` 確認可成功建置
  </verify>
  <done>
  Codec 資訊區塊中的取樣率、位元深度、聲道模式顯示為可互動的下拉選單，LDAC 時額外顯示品質模式選擇器。選擇後透過 method channel 呼叫原生端設定 codec 參數，設定完成後自動重新載入顯示最新狀態。
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 3: 驗證 codec 切換功能</name>
  <what-built>App 內藍牙 codec 參數切換功能，包含取樣率/位元深度/聲道模式下拉選單及 LDAC 品質模式選擇器</what-built>
  <how-to-verify>
    1. 連接一個藍牙音訊裝置（建議使用支援 LDAC 的裝置以測試完整功能）
    2. 開啟 App 進入藍牙音訊頁面
    3. 確認 codec 區塊中取樣率、位元深度、聲道模式顯示為下拉選單
    4. 確認下拉選單中的選項是該裝置實際支援的值（非全部列出）
    5. 切換取樣率為不同值，確認短暫載入後頁面更新顯示新值
    6. 如果是 LDAC 裝置，確認可以切換品質模式（990/660/330/ABR）
    7. 如果連接的是 SBC/AAC 裝置，確認 bitrate 欄位維持靜態文字（不可調整）
    8. 確認無 capabilities 資訊時（取得失敗），所有欄位維持靜態顯示不壞掉
  </how-to-verify>
  <resume-signal>輸入 "approved" 或描述需要修正的問題</resume-signal>
</task>

</tasks>

<verification>
- Android 專案編譯成功
- Flutter analyze 無錯誤
- 下拉選單正確顯示裝置支援的 codec 選項
- 切換參數後 codec 設定實際被套用
- 無 capabilities 時 graceful degradation 為靜態顯示
</verification>

<success_criteria>
使用者可在 App 內透過下拉選單切換藍牙 codec 的取樣率、位元深度、聲道模式，以及 LDAC 的品質模式，設定即時套用並反映在 UI 上。
</success_criteria>
