---
phase: quick-6
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
  - lib/data/model/bluetooth_audio_model.dart
  - lib/view/bluetoothaudio/bluetooth_audio_page.dart
  - lib/l10n/app_localizations.dart
autonomous: true
must_haves:
  truths:
    - "TWS 耳機連線時，裝置資訊顯示左耳、右耳、充電盒各自電量"
    - "非 TWS 裝置（或 API < 28）仍顯示單一電量值，不會出錯"
    - "任一電量不可用時顯示 '--' 而非錯誤"
  artifacts:
    - path: "android/app/src/main/kotlin/.../BluetoothAudioHandler.kt"
      provides: "getUntetheredBatteryLevels 方法，回傳 left/right/case 電量"
    - path: "lib/data/model/bluetooth_audio_model.dart"
      provides: "BluetoothDeviceInfo 新增 batteryLeft/batteryRight/batteryCase 欄位"
    - path: "lib/view/bluetoothaudio/bluetooth_audio_page.dart"
      provides: "條件式顯示拆分電量或單一電量"
  key_links:
    - from: "BluetoothAudioHandler.kt"
      to: "BluetoothDeviceInfo.fromMap"
      via: "platform channel Map keys: batteryLeft, batteryRight, batteryCase"
      pattern: "batteryLeft|batteryRight|batteryCase"
---

<objective>
將藍牙音訊裝置的電量顯示從單一數值拆分為左耳/右耳/充電盒三個獨立電量值。

Purpose: TWS (True Wireless Stereo) 耳機使用者需要分別查看左右耳及充電盒的電量狀態。
Output: Android 端讀取 METADATA_UNTETHERED_*_BATTERY，Flutter 端條件式顯示拆分電量。
</objective>

<execution_context>
@/Users/tonynowater/.claude/get-shit-done/workflows/execute-plan.md
@/Users/tonynowater/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt
@lib/data/model/bluetooth_audio_model.dart
@lib/view/bluetoothaudio/bluetooth_audio_page.dart
@lib/l10n/app_localizations.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Android 端讀取 TWS 耳機分離電量</name>
  <files>android/app/src/main/kotlin/com/tonynowater/mobileosversions/mobile_os_versions/BluetoothAudioHandler.kt</files>
  <action>
在 BluetoothAudioHandler.kt 中新增 `getUntetheredBatteryLevels` 方法：

1. 使用 reflection 呼叫 `BluetoothDevice.getMetadata(int key)` (API 28+, hidden API)。
   - key 值: METADATA_UNTETHERED_LEFT_BATTERY = 6, METADATA_UNTETHERED_RIGHT_BATTERY = 7, METADATA_UNTETHERED_CASE_BATTERY = 8
   - `getMetadata` 回傳 `ByteArray?`，需要轉為 String 再 `toIntOrNull()`
   - 注意: 這些常數值可在 Android source 確認，但 key 是 int 型別

2. 在 `getBluetoothAudioInfo` 中，除了現有的 `getBatteryLevel` 之外，額外呼叫 `getUntetheredBatteryLevels`。回傳 Map 新增三個 key：
   - `"batteryLeft"`: Int (-1 表示不可用)
   - `"batteryRight"`: Int (-1 表示不可用)
   - `"batteryCase"`: Int (-1 表示不可用)

3. 實作方式：
```kotlin
private fun getUntetheredBatteryLevels(device: BluetoothDevice): Map<String, Int> {
    val result = mutableMapOf<String, Int>()
    if (Build.VERSION.SDK_INT < 28) {
        result["batteryLeft"] = -1
        result["batteryRight"] = -1
        result["batteryCase"] = -1
        return result
    }
    try {
        val getMetadata = BluetoothDevice::class.java.getMethod("getMetadata", Int::class.java)
        // METADATA_UNTETHERED_LEFT_BATTERY = 6
        // METADATA_UNTETHERED_RIGHT_BATTERY = 7
        // METADATA_UNTETHERED_CASE_BATTERY = 8
        result["batteryLeft"] = (getMetadata.invoke(device, 6) as? ByteArray)
            ?.let { String(it).toIntOrNull() } ?: -1
        result["batteryRight"] = (getMetadata.invoke(device, 7) as? ByteArray)
            ?.let { String(it).toIntOrNull() } ?: -1
        result["batteryCase"] = (getMetadata.invoke(device, 8) as? ByteArray)
            ?.let { String(it).toIntOrNull() } ?: -1
    } catch (e: Exception) {
        Log.w(TAG, "getUntetheredBatteryLevels failed: ${e.message}")
        result["batteryLeft"] = -1
        result["batteryRight"] = -1
        result["batteryCase"] = -1
    }
    return result
}
```

4. 在 `getBluetoothAudioInfo` 的 deviceInfo Map 建構處，加入：
```kotlin
deviceInfo.putAll(getUntetheredBatteryLevels(device))
```
  </action>
  <verify>專案可正常編譯：在專案根目錄執行 `cd android && ./gradlew assembleDebug --quiet` 無 Kotlin 編譯錯誤</verify>
  <done>BluetoothAudioHandler 透過 platform channel 回傳 batteryLeft, batteryRight, batteryCase 三個 int 值</done>
</task>

<task type="auto">
  <name>Task 2: Flutter Model + UI 顯示拆分電量</name>
  <files>lib/data/model/bluetooth_audio_model.dart, lib/view/bluetoothaudio/bluetooth_audio_page.dart, lib/l10n/app_localizations.dart</files>
  <action>
**Model 修改 (bluetooth_audio_model.dart):**

1. 在 `BluetoothDeviceInfo` 類別新增三個欄位：
```dart
final int? batteryLeft;   // -1 表示不可用
final int? batteryRight;  // -1 表示不可用
final int? batteryCase;   // -1 表示不可用
```

2. 更新建構函式和 `fromMap`：
```dart
batteryLeft: map['batteryLeft'] as int?,
batteryRight: map['batteryRight'] as int?,
batteryCase: map['batteryCase'] as int?,
```

3. 新增 getter 判斷是否有拆分電量：
```dart
bool get hasUntetheredBattery =>
    (batteryLeft != null && batteryLeft! >= 0) ||
    (batteryRight != null && batteryRight! >= 0) ||
    (batteryCase != null && batteryCase! >= 0);

String _formatLevel(int? level) {
  if (level == null || level < 0) return '--';
  return '$level%';
}

String get formattedBatteryLeft => _formatLevel(batteryLeft);
String get formattedBatteryRight => _formatLevel(batteryRight);
String get formattedBatteryCase => _formatLevel(batteryCase);
```

**Localization 修改 (app_localizations.dart):**

在每個語系的 `_localizedValues` Map 中加入（放在 `battery_level` 附近）：
- `'battery_left'`: en='Left Ear', zh_TW='左耳', zh_CN='左耳', ja='左耳', ko='왼쪽', es='Izquierdo', fr='Gauche', de='Links', ar='اليسرى', pt='Esquerdo'
- `'battery_right'`: en='Right Ear', zh_TW='右耳', zh_CN='右耳', ja='右耳', ko='오른쪽', es='Derecho', fr='Droite', de='Rechts', ar='اليمنى', pt='Direito'
- `'battery_case'`: en='Case', zh_TW='充電盒', zh_CN='充电盒', ja='ケース', ko='케이스', es='Estuche', fr='Boîtier', de='Etui', ar='العلبة', pt='Estojo'

在 `AppLocalizations` 類別底部加入 getter：
```dart
String get batteryLeft => _localizedValues[locale.toString()]!['battery_left']!;
String get batteryRight => _localizedValues[locale.toString()]!['battery_right']!;
String get batteryCase => _localizedValues[locale.toString()]!['battery_case']!;
```

**UI 修改 (bluetooth_audio_page.dart):**

在 `_buildLoadedView` 的裝置資訊 `_buildInfoCard` 中，將原本的：
```dart
_buildInfoRow(l10n.batteryLevel, audioInfo.deviceInfo.formattedBatteryLevel),
```
替換為條件式顯示：
```dart
if (audioInfo.deviceInfo.hasUntetheredBattery) ...[
  _buildInfoRow(l10n.batteryLeft, audioInfo.deviceInfo.formattedBatteryLeft),
  _buildInfoRow(l10n.batteryRight, audioInfo.deviceInfo.formattedBatteryRight),
  _buildInfoRow(l10n.batteryCase, audioInfo.deviceInfo.formattedBatteryCase),
] else
  _buildInfoRow(l10n.batteryLevel, audioInfo.deviceInfo.formattedBatteryLevel),
```

這樣當裝置回傳有效的左/右/盒電量時，顯示三行；否則 fallback 到原本的單一電量。
  </action>
  <verify>在專案根目錄執行 `flutter analyze --no-fatal-infos` 無錯誤</verify>
  <done>TWS 裝置顯示左耳/右耳/充電盒三行電量；非 TWS 裝置仍顯示單一電量行</done>
</task>

</tasks>

<verification>
1. `cd android && ./gradlew assembleDebug --quiet` 編譯通過
2. `flutter analyze --no-fatal-infos` 無錯誤
3. 連接 TWS 耳機時，裝置資訊卡片顯示左耳/右耳/充電盒三行
4. 連接非 TWS 藍牙裝置時，仍顯示原本的單一電量行
5. 電量不可用時顯示 '--' 而非 crash
</verification>

<success_criteria>
- Android 端透過 BluetoothDevice.getMetadata reflection 讀取 untethered battery levels
- Flutter 端 BluetoothDeviceInfo model 包含 batteryLeft/batteryRight/batteryCase
- UI 條件式顯示拆分電量或單一電量
- 所有 10 個語系的 battery_left/battery_right/battery_case 翻譯已加入
- 向後相容：API < 28 或非 TWS 裝置不受影響
</success_criteria>

<output>
After completion, create `.planning/quick/6-bt-battery-left-right-case/6-SUMMARY.md`
</output>
