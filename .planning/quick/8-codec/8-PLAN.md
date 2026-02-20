---
phase: quick-8
plan: 8
type: execute
wave: 1
depends_on: []
files_modified:
  - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
  - lib/data/model/bluetooth_audio_model.dart
  - lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
  - lib/view/bluetoothaudio/bluetooth_audio_page.dart
autonomous: true

must_haves:
  truths:
    - "Codec Type 行顯示為 DropdownButton（當裝置支援 >1 種 codec 時）"
    - "使用者選擇不同 codec 後，系統即時切換並重新載入顯示新 codec 及其對應參數"
    - "僅支援 1 種 codec 時，Codec Type 維持靜態文字顯示"
    - "切換 codec type 後，該 codec 對應的 capabilities（sampleRate/bitsPerSample/channelMode）正確更新"
  artifacts:
    - path: "android/app/src/main/kotlin/.../BluetoothAudioHandler.kt"
      provides: "selectableCodecTypes 清單回傳"
    - path: "lib/data/model/bluetooth_audio_model.dart"
      provides: "CodecCapabilities 新增 codecTypes 欄位"
    - path: "lib/view/bluetoothaudio/bluetooth_audio_cubit.dart"
      provides: "setCodecConfig 支援 codecType 參數"
    - path: "lib/view/bluetoothaudio/bluetooth_audio_page.dart"
      provides: "Codec Type DropdownButton UI"
  key_links:
    - from: "BluetoothAudioHandler.getCodecInfo"
      to: "Flutter BluetoothAudioInfo.fromMap"
      via: "selectableCodecTypes 欄位透過 method channel 傳遞"
    - from: "bluetooth_audio_page.dart codecType dropdown onChanged"
      to: "cubit.setCodecConfig(codecType: newValue)"
      via: "呼叫 setCodecConfig 傳入新 codecType"
---

<objective>
讓使用者可在藍牙音訊詳情頁面切換 Codec 類型（SBC/AAC/aptX/aptX HD/LDAC 等），裝置支援哪些 Codec 就顯示哪些選項。

Purpose: 目前只能切換同一 codec 內的參數（取樣率、位元深度等），但無法切換 codec 本身。此功能讓使用者能在裝置支援的 codec 之間自由切換。
Output: Codec Type 從靜態文字變為可互動 DropdownButton，選擇後即時切換。
</objective>

<context>
@android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
@lib/data/model/bluetooth_audio_model.dart
@lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
@lib/view/bluetoothaudio/bluetooth_audio_page.dart
@lib/view/bluetoothaudio/bluetooth_audio_state.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Android native 回傳所有可選 codec types + Flutter model/cubit 擴充</name>
  <files>
    android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
    lib/data/model/bluetooth_audio_model.dart
    lib/view/bluetoothaudio/bluetooth_audio_cubit.dart
  </files>
  <action>
    **Android native (BluetoothAudioHandler.kt - getCodecInfo method):**

    目前 `getCodecsSelectableCapabilities` 迴圈只找出與 currentCodecType 相同的 capability。改為：
    1. 遍歷所有 selectableCapabilities，收集每個 capability 的 codecType
    2. 建立 `selectableCodecTypes` 清單，格式與其他 selectable 欄位一致：`List<Map<String, Any>>`，每項包含 `{"value": codecTypeInt, "label": codecTypeString}`
    3. 使用已有的 `BluetoothCodecConstants.codecTypeToString()` 產生 label
    4. 將 `selectableCodecTypes` 加入 result map 回傳（key: `"selectableCodecTypes"`）
    5. 保持現有的 sampleRate/bitsPerSample/channelMode selectable 邏輯不變（仍基於 currentCodecType 的 capability）

    具體修改位置：在 `getCodecInfo` 的 `try` 區塊中，`getCodecsSelectableCapabilities` 取得後：
    ```kotlin
    // 收集所有可選 codec types
    val selectableCodecTypes = mutableListOf<Map<String, Any>>()
    for (cap in selectableCapabilities) {
        if (cap == null) continue
        val capCodecType = cap.javaClass.getMethod("getCodecType").invoke(cap) as Int
        selectableCodecTypes.add(mapOf(
            "value" to capCodecType,
            "label" to BluetoothCodecConstants.codecTypeToString(capCodecType)
        ))
    }
    result["selectableCodecTypes"] = selectableCodecTypes
    ```
    注意：capCodecType 的取得可以提到迴圈開頭共用，避免重複 reflection 呼叫。

    **Flutter model (bluetooth_audio_model.dart):**

    1. `CodecCapabilities` 新增 `codecTypes` 欄位：`final List<CodecOption> codecTypes;`
    2. 更新 constructor 加入 `required this.codecTypes`
    3. 更新 `fromMap`：如果 map 包含 `selectableCodecTypes` 則解析，否則給空 list
    4. 更新 `BluetoothAudioInfo.fromMap`：判斷 capabilities 是否存在時，也檢查 `selectableCodecTypes`（即 `selectableSampleRates` 或 `selectableCodecTypes` 任一存在即建立 capabilities）

    **Flutter cubit (bluetooth_audio_cubit.dart):**

    1. `setCodecConfig` method 新增可選參數 `int? codecType`
    2. 在呼叫 method channel 時，如果 `codecType` 不為 null 則使用傳入的值，否則使用 `currentAudioInfo.rawValues!.codecType`（向後相容）
    3. 當切換 codec type 時，其他參數（sampleRate, bitsPerSample, channelMode, codecSpecific1）不需要特別處理，因為 Android 系統會自動選擇新 codec 的預設參數，且 load() 重新載入後會取得新的 capabilities
  </action>
  <verify>
    在專案根目錄執行：
    1. `cd android && ./gradlew assembleDebug` 驗證 Android 編譯通過
    2. `flutter analyze lib/data/model/bluetooth_audio_model.dart lib/view/bluetoothaudio/bluetooth_audio_cubit.dart` 驗證 Dart 靜態分析通過
  </verify>
  <done>
    - Android native 回傳 selectableCodecTypes 清單
    - Flutter CodecCapabilities 包含 codecTypes 欄位
    - cubit.setCodecConfig 接受可選 codecType 參數
    - 編譯與靜態分析均通過
  </done>
</task>

<task type="auto">
  <name>Task 2: UI Codec Type DropdownButton 及完整驗證</name>
  <files>
    lib/view/bluetoothaudio/bluetooth_audio_page.dart
  </files>
  <action>
    **bluetooth_audio_page.dart - _buildLoadedView method:**

    將 codecType 行從靜態顯示改為條件式 dropdown，遵循既有的 sampleRate/bitsPerSample/channelMode 相同模式：

    1. 將現有的 `_buildInfoRow(l10n.codecType, audioInfo.codecInfo.codecType)` 替換為條件判斷：
       - 如果 `hasCapabilities && capabilities.codecTypes.length > 1`：顯示 `_buildDropdownRow`
       - 否則：維持原本的 `_buildInfoRow` 靜態顯示

    2. DropdownButton 的參數：
       - label: `l10n.codecType`
       - currentValue: `rawValues.codecType`（這是 int 原始值）
       - options: `capabilities.codecTypes`
       - onChanged: 切換 codec type 時，呼叫 `cubit.setCodecConfig(codecType: value, sampleRate: rawValues.sampleRate, bitsPerSample: rawValues.bitsPerSample, channelMode: rawValues.channelMode, codecSpecific1: rawValues.codecSpecific1)`
       - isSettingCodec 時 onChanged 設為 null（與其他 dropdown 一致，防止重複點擊）

    3. 注意：切換 codec type 後 load() 會重新取得資料，新 codec 的 capabilities（sampleRate 等選項）會自動更新，不需要額外處理。

    具體程式碼位置（約第 279 行）：
    ```dart
    // codecType - 可切換（當有多個可選 codec 時）
    if (hasCapabilities && capabilities.codecTypes.length > 1)
      _buildDropdownRow(
        l10n.codecType,
        rawValues.codecType,
        capabilities.codecTypes,
        isSettingCodec ? null : (value) {
          if (value != null) {
            cubit.setCodecConfig(
              codecType: value,
              sampleRate: rawValues.sampleRate,
              bitsPerSample: rawValues.bitsPerSample,
              channelMode: rawValues.channelMode,
              codecSpecific1: rawValues.codecSpecific1,
            );
          }
        },
      )
    else
      _buildInfoRow(l10n.codecType, audioInfo.codecInfo.codecType),
    ```
  </action>
  <verify>
    1. `flutter analyze lib/view/bluetoothaudio/bluetooth_audio_page.dart` 通過
    2. `flutter build apk --debug` 完整建置通過
  </verify>
  <done>
    - Codec Type 行在有多個可選 codec 時顯示為 DropdownButton
    - 選擇不同 codec 後觸發切換並重新載入
    - 僅 1 種 codec 時維持靜態文字
    - 完整 debug APK 建置通過
  </done>
</task>

</tasks>

<verification>
1. Android assembleDebug 通過
2. Flutter analyze 全部修改檔案通過
3. Flutter build apk --debug 通過
4. 程式碼邏輯檢查：selectableCodecTypes 從 native -> model -> cubit -> UI 完整串連
</verification>

<success_criteria>
- Codec Type 在裝置支援多種 codec 時顯示為 DropdownButton
- 選擇不同 codec 後即時切換並重新載入頁面顯示新 codec 資訊
- 僅支援 1 種 codec 時維持靜態顯示
- 所有建置與靜態分析通過
</success_criteria>

<output>
After completion, create `.planning/quick/8-codec/8-SUMMARY.md`
</output>
