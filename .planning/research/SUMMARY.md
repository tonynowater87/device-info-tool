# 專案研究總結

**專案：** Mobile OS Versions - 藍牙音訊編解碼器資訊與控制
**領域：** Android 藍牙 A2DP 音訊裝置整合
**研究日期：** 2026-02-08
**信心度：** MEDIUM-HIGH

## 執行摘要

本專案旨在為現有 Flutter 應用程式新增藍牙音訊裝置資訊顯示與編解碼器切換功能。經過深入研究發現，**Android 官方 API 對藍牙編解碼器的程式化控制支援非常有限**。關鍵 API（如 `setCodecConfigPreference()`）被標記為 `@hide`，僅供系統 Settings 應用使用，第三方應用無法可靠地直接呼叫這些 API 而不違反 Google Play 政策。

**推薦實作策略：** 採用「唯讀資訊展示 + 引導式使用者體驗」模式。透過公開 API（`BluetoothA2dp.getCodecStatus()`）取得完整的藍牙裝置資訊與編解碼器狀態（類型、取樣率、位元深度），並透過 Intent 引導使用者至系統開發者選項進行編解碼器切換。這種方式完全符合 Google Play 政策，避免使用 Hidden API 帶來的未來相容性風險，同時仍能提供有價值的資訊展示功能。

**主要風險與緩解：** 最大的陷阱是 Android 12+ 全新的藍牙權限模型（需 runtime 請求 `BLUETOOTH_CONNECT` 權限）、null pointer 處理（`getCodecStatus()` 在無連接時返回 null）、以及某些裝置（特別是 Samsung）的 A2DP Hardware Offload 可能干擾編解碼器切換。緩解措施包括：完整的權限請求流程（支援 API 31 前後的雙重權限模型）、嚴格的 null 檢查、裝置特定警告、以及多廠商裝置測試策略。

## 關鍵發現

### 推薦技術堆疊

基於現有專案架構與 Android 藍牙 API 限制，推薦採用 **Platform Channel 模式**整合原生藍牙功能，完全復用專案現有的 BLoC 狀態管理與 Handler 分離模式。

**核心技術：**
- **Flutter** — 既有專案框架，無需更換
- **Kotlin（API 31+）** — Android 原生層實作，與現有 DeviceInfoHandler 一致
- **Platform Channel（MethodChannel）** — Flutter ↔ Kotlin 通訊橋樑，已在專案廣泛使用
- **BluetoothA2dp API（公開 API）** — 取得編解碼器狀態（唯讀），完全合規且穩定
- **BluetoothCodecConfig API（公開 API）** — 解析編解碼器詳細參數（類型/取樣率/位元深度）
- **Intent to Developer Options** — 引導式編解碼器切換方案，無需 Hidden API

**版本相依性：**
- 最低支援 **API 26（Android 8.0）** — BluetoothCodecConfig API 引入版本，但可透過版本檢查在 API 23-25 提供降級體驗
- 建議目標 **API 31（Android 12）** — 新藍牙權限模型導入，需特別處理 `BLUETOOTH_CONNECT` runtime 權限
- 目標 **API 35（Android 15）** — 符合專案當前設定與 Google Play 2025 要求

**為何避免 Hidden API：**
- 違反 Google Play 政策，審核可能被拒
- Android 9+ 持續收緊限制，Android 12+ reflection 直接失效
- 廠商客製化差異（Samsung/Xiaomi/OnePlus）導致不穩定
- 每次 Android 大版本更新需重新驗證，維護成本極高

### 預期功能

基於藍牙音訊控制應用程式的市場研究與使用者期望，以下為功能分類：

**必備功能（Table Stakes）：**
- **顯示連接狀態** — 使用者需知道是否有藍牙裝置已連接
- **顯示裝置基本資訊** — 裝置名稱、MAC 位址
- **顯示當前使用的編解碼器** — 核心價值（SBC/AAC/APTX/LDAC 等）
- **顯示編解碼器參數** — 取樣率（44.1k/48k/96k Hz）、位元深度（16/24 bit）、bitrate
- **顯示支援的編解碼器清單** — 手機與裝置各自支援的 codec
- **藍牙權限處理** — Android 12+ 強制要求 BLUETOOTH_CONNECT runtime 權限
- **無連接時的空狀態提示** — 良好 UX，避免使用者困惑

**差異化功能（Differentiators）：**
- **引導至開發者選項切換編解碼器** — 解決「編解碼器切換無法程式化」問題的 UX 方案
- **顯示藍牙版本資訊** — 手機的藍牙版本（5.0/5.1/5.2 等）
- **編解碼器建議模式** — 根據裝置能力推薦最佳 codec 組合
- **連接品質指標** — 訊號強度、連線穩定度（若 API 有提供）

**明確排除（Anti-Features）：**
- **藍牙裝置配對管理** — 系統設定的職責，不重複開發
- **音訊播放器功能** — 功能範疇蔓延，市面上已有專業播放器
- **程式化編解碼器切換** — 依賴 Hidden API，違反政策且不穩定
- **iOS 平台支援** — iOS 不開放 codec 控制 API，投資無法實現功能
- **需要 root 權限的功能** — 限制使用者群體，增加安全風險

### 架構方案

推薦採用 **三層架構**，完全遵循專案現有的 BLoC pattern 與 Platform Channel 整合模式：

```
Flutter Layer (Dart)
├─ BluetoothAudioPage (UI)
│   ↓↑ BlocBuilder/BlocConsumer
├─ BluetoothAudioCubit (State Management)
│   ↓↑ emit states
└─ BluetoothAudioState (Initial/Loading/Success/Error)

Platform Channel Bridge
└─ MethodChannel("com.tonynowater.mobileosversions")

Android Native Layer (Kotlin)
├─ MainActivity.kt (註冊 handler)
├─ BluetoothAudioHandler.kt (處理 Platform Channel)
└─ BluetoothA2dp / BluetoothCodecConfig API
```

**主要元件與職責：**
1. **BluetoothAudioPage** — UI 顯示、使用者互動（只負責 UI，不直接呼叫 Platform Channel）
2. **BluetoothAudioCubit** — 業務邏輯、狀態管理、Platform Channel 呼叫（遵循專案既有 Cubit 模式）
3. **BluetoothAudioHandler** — Platform Channel 請求處理、呼叫 Android Bluetooth API（分離模式，遵循 DeviceInfoHandler 設計）

**資料流向：**
```
[使用者開啟頁面]
→ cubit.loadBluetoothInfo()
→ MethodChannel.invokeMethod("getBluetoothInfo")
→ BluetoothAudioHandler.handle()
→ BluetoothA2dp.getCodecStatus()
→ 返回 Map<String, dynamic>
→ cubit emit(BluetoothAudioSuccess)
→ UI 更新
```

**為何採用 Cubit 而非完整 Bloc：**
- 專案現有 `AndroidVersionPageCubit` 已使用 Cubit pattern
- 藍牙音訊是簡單的請求-回應流程，不需要複雜的事件追蹤
- 減少 boilerplate code

**為何使用 MethodChannel 而非 EventChannel：**
- 功能是「點擊後查詢」而非「持續監聽」
- 藍牙 codec 資訊不是高頻率變化的資料
- MethodChannel pull 模式更符合使用案例

### 關鍵陷阱

基於深入研究，以下為最嚴重的 4 個陷阱與預防策略：

1. **Hidden API 依賴導致功能失效（CRITICAL）**
   - **問題：** 使用 `setCodecConfigPreference()` 等 `@hide` API，在 Android 9+ 持續收緊限制，Android 12+ reflection 直接失效
   - **後果：** Google Play 審核被拒、新版 Android 功能失效、需完全重寫架構
   - **避免方式：** 採用「唯讀資訊 + Intent 引導至開發者選項」策略，完全避免 Hidden API

2. **Android 12+ 藍牙權限處理錯誤（CRITICAL）**
   - **問題：** Android 12 引入新權限模型，`BLUETOOTH_CONNECT` 是 runtime permission，需動態請求
   - **後果：** Android 12+ 裝置上功能完全無法運作，SecurityException 導致 crash
   - **避免方式：** 正確的 Manifest 配置（區分 API 30 前後）+ runtime 權限請求流程 + 權限拒絕處理

3. **Codec 狀態 Null Pointer Exception（CRITICAL）**
   - **問題：** `getCodecStatus()` 在無連接、剛連接、連接中斷時返回 null，未檢查直接訪問導致 crash
   - **後果：** 藍牙裝置連接/斷線時應用崩潰，難以復現（與時序有關）
   - **避免方式：** 所有 Bluetooth API 呼叫都加嚴格 null 檢查 + 監聽連接狀態變化 + 設計 "codec unavailable" state

4. **A2DP Hardware Offload 干擾 Codec 控制（MODERATE）**
   - **問題：** 某些裝置（特別是 Samsung、OnePlus）的 hardware offload 會覆蓋 codec 設定
   - **後果：** 使用者看到的 codec 資訊與實際不符，某些裝置完全無法切換 codec
   - **避免方式：** 偵測 hardware offload 狀態 + 提供裝置特定警告 + 引導停用 offload 的說明

## 路線圖建議

基於研究發現的依賴關係、架構模式與陷阱，建議以下分階段結構：

### 階段 1：基礎架構與唯讀資訊展示

**理由：** 由下而上建構，先實作唯讀功能降低風險（讀取不會改變系統狀態），同時建立完整的權限處理機制。

**交付成果：**
- Android 原生層 BluetoothAudioHandler（處理 getBluetoothInfo method）
- Flutter Cubit 狀態管理（Initial/Loading/Success/Error states）
- 完整的藍牙權限處理流程（支援 API 31 前後雙重模型）
- 基本 UI 顯示（裝置名稱、MAC 位址、當前 codec）

**實作功能（來自 FEATURES.md）：**
- 顯示連接狀態
- 顯示裝置基本資訊（名稱、MAC）
- 顯示當前編解碼器類型（SBC/AAC/APTX/LDAC 等）
- 顯示編解碼器參數（取樣率、位元深度）
- 無連接時的空狀態提示
- 藍牙權限請求與拒絕處理

**避免陷阱：**
- 陷阱 2：完整實作 Android 12+ 權限處理
- 陷阱 3：所有 Bluetooth API 呼叫都加 null 檢查
- 陷阱 9：API 26 以下顯示「需要 Android 8.0+」降級提示

**技術依賴（來自 STACK.md）：**
- BluetoothA2dp.getCodecStatus()（公開 API）
- BluetoothCodecConfig.getCodecType/getSampleRate/getBitsPerSample()（公開 API）
- Platform Channel（MethodChannel）
- permission_handler package

**預估複雜度：** Medium（3-5 天）

---

### 階段 2：進階資訊展示與錯誤處理強化

**理由：** 在核心功能穩定後，新增差異化資訊展示與裝置特定警告，提升使用者體驗。

**交付成果：**
- 顯示支援的編解碼器清單（手機與裝置各自支援）
- 顯示藍牙版本資訊
- Hardware Offload 狀態偵測與警告
- 完整的錯誤處理與重試機制
- Codec negotiation 時序處理（監聽 CODEC_CONFIG_CHANGED）

**實作功能：**
- 顯示手機支援的 Codec 清單
- 顯示裝置支援的 Codec 清單
- 顯示藍牙版本（5.0/5.1/5.2 等）
- 裝置特定警告（Samsung hardware offload 提示）
- 連接狀態監聽與自動更新

**避免陷阱：**
- 陷阱 4：偵測 A2DP Hardware Offload 並顯示警告
- 陷阱 7：等待 codec negotiation 完成再查詢
- 陷阱 11：使用標準化 codec 名稱映射

**技術依賴：**
- BluetoothCodecStatus.getCodecsSelectableCapabilities()（需驗證是否為 hidden API）
- BroadcastReceiver 監聽 ACTION_CODEC_CONFIG_CHANGED
- Settings.Global 查詢 hardware offload 狀態

**預估複雜度：** Medium（3-5 天）

---

### 階段 3：引導式編解碼器切換體驗

**理由：** 在資訊展示完整後，新增引導使用者至開發者選項的 UX 流程，解決「無法程式化切換」的限制。

**交付成果：**
- 偵測開發者選項啟用狀態
- Intent 引導至開發者選項
- 編解碼器切換說明與教學流程
- 「開發者選項未啟用」警告與啟用指南
- 高耗電編解碼器警告（LDAC 990kbps 等）

**實作功能：**
- 引導至開發者選項切換編解碼器
- 編解碼器建議模式（音質優先/穩定性優先/省電優先）
- 高位元率 codec 耗電警告

**避免陷阱：**
- 陷阱 1：明確避免 Hidden API，採用 Intent 引導方案
- 陷阱 6：偵測開發者選項狀態並提供啟用指南
- 陷阱 8：顯示高位元率 codec 耗電警告
- 陷阱 10：說明「部分裝置重開機後設定會重置」

**技術依賴：**
- Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
- Settings.Global.DEVELOPMENT_SETTINGS_ENABLED

**預估複雜度：** Low-Medium（2-4 天）

---

### 階段 4：多裝置測試與優化

**理由：** 藍牙功能的裝置相容性差異極大，需在多個廠商裝置上驗證。

**交付成果：**
- 在 Pixel、Samsung、Xiaomi、OnePlus 裝置測試
- 驗證 hardware offload 行為
- 不同 Android 版本（API 26/31/33/35）測試
- 效能優化與記憶體洩漏檢查
- BroadcastReceiver lifecycle 管理

**測試矩陣：**
- Google Pixel（Android 13/14） — 基準測試
- Samsung Galaxy（Android 12/13） — Hardware Offload 驗證
- Xiaomi、OnePlus — 廠商客製化驗證
- API 26 裝置 — 最低版本驗證

**避免陷阱：**
- 陷阱 12：正確處理 Activity lifecycle，避免 memory leak
- 裝置特定問題（Samsung AAC 破音、Pixel LDAC 990kbps 不穩定）

**預估複雜度：** Medium（3-5 天）

---

### 階段排序理由

1. **由下而上建構** — 先建構 Native 層（風險最高），再建構 Cubit 層，最後建構 UI 層，確保每一層可獨立測試
2. **先唯讀後控制** — 唯讀資訊展示不會改變系統狀態，風險低且價值高，優先實作
3. **引導式 UX 作為替代方案** — 避免 Hidden API 依賴，採用合規且穩定的 Intent 引導方式
4. **測試驗證放在最後** — 在功能完整後進行多裝置測試，避免過早優化

### 研究標記

**需要在規劃階段深入研究的階段：**
- **階段 2** — `getCodecsSelectableCapabilities()` 是否為 hidden API 需驗證，若是則需調整實作方式
- **階段 4** — 需實際裝置測試才能確認 hardware offload 行為與廠商差異

**有標準模式可跳過深入研究的階段：**
- **階段 1** — Platform Channel 整合與權限處理有成熟模式，專案已有多個實作案例
- **階段 3** — Intent 引導至系統設定是標準 Android 開發模式

## 信心度評估

| 領域 | 信心度 | 說明 |
|------|--------|------|
| **Stack** | **HIGH** | 基於 Android 官方文件與專案現有架構，BluetoothA2dp/CodecConfig API 為公開且穩定的 API |
| **Features** | **MEDIUM-HIGH** | 基於市場研究與使用者回饋，功能分類清晰，但編解碼器切換限制需透過引導式 UX 解決 |
| **Architecture** | **HIGH** | 完全復用專案既有的 Platform Channel + BLoC 模式，有成熟實作案例（DeviceInfoHandler、AndroidVersionPageCubit） |
| **Pitfalls** | **MEDIUM-HIGH** | Hidden API 與 Android 12+ 權限陷阱有官方文件支持，Hardware Offload 陷阱基於社群回報（缺乏官方文件） |

**整體信心度：** MEDIUM-HIGH

### 需要解決的知識缺口

以下領域在實作階段需要驗證：

1. **`setCodecConfigPreference()` 的實際可用性**
   - 文獻確認為 `@hide` API，但需實際測試在不同 Android 版本的行為
   - 處理方式：階段 1 完全避免使用，採用 Intent 引導方案

2. **`getCodecsSelectableCapabilities()` 的公開性**
   - 部分文獻指出為 hidden API，需在實作階段驗證
   - 處理方式：若為 hidden API，改為僅顯示當前 codec，不顯示完整支援清單

3. **Hardware Offload 在不同裝置的具體行為**
   - 社群回報 Samsung/OnePlus 有此問題，但缺乏官方文件
   - 處理方式：階段 4 在實際裝置上測試並記錄行為

4. **Codec negotiation 完成的時間點**
   - 連接後多久才能安全查詢 codec 狀態
   - 處理方式：監聽 ACTION_CODEC_CONFIG_CHANGED，而非依賴固定延遲

5. **連接品質指標 API 的可用性**
   - 不確定 Android API 是否提供訊號強度、連線穩定度資訊
   - 處理方式：列為「可選功能」，若 API 不可用則不實作

## 資料來源

### 主要來源（HIGH 信心度）

**官方文件：**
- [BluetoothA2dp API Reference](https://developer.android.com/reference/android/bluetooth/BluetoothA2dp) — API 規格與方法定義
- [BluetoothCodecConfig API Reference](https://developer.android.com/reference/android/bluetooth/BluetoothCodecConfig) — 編解碼器配置參數
- [Android Bluetooth Permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions) — Android 12+ 權限模型
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels) — Platform Channel 整合模式
- [Android Bluetooth Services (AOSP)](https://source.android.com/docs/core/connect/bluetooth/services) — 藍牙服務架構

**專案現有程式碼：**
- MainActivity.kt — Platform Channel 註冊模式
- DeviceInfoHandler.kt — Handler 分離模式
- AndroidVersionPageCubit.dart — Cubit 狀態管理模式

### 次要來源（MEDIUM 信心度）

**技術文章與教學：**
- [Flutter BLoC Tutorial: Mastering State Management in 2026](https://www.zignuts.com/blog/flutter-bloc-tutorial) — Cubit vs Bloc 選擇
- [Bloc vs Cubit in Flutter](https://medium.com/@wassimsakri/bloc-vs-cubit-in-flutter-when-should-you-use-each-5dc21c20c053) — 狀態管理模式比較
- [Error handling in Flutter plugins](https://csdcorp.com/blog/coding/error-handling-in-flutter-plugins/) — Platform Channel 錯誤處理
- [Bluetooth Codecs Guide 2026](https://en.androidayuda.com/android/is/bluetooth-codecs-guide-ldac-vs-aptx-vs-aac/) — 編解碼器技術規格
- [Understanding Bluetooth codecs - SoundGuys](https://www.soundguys.com/understanding-bluetooth-codecs-15352/) — 編解碼器比較

**社群專案：**
- [Bluetooth Codec Change](https://github.com/matisiekpl/bluetooth-codec-change) — Hidden API 使用範例（僅供參考，不推薦使用）

### 第三來源（LOW 信心度，需驗證）

**社群回報與論壇：**
- [Samsung Bluetooth Codec Issues](https://eu.community.samsung.com/t5/other-galaxy-s-series/bluetooth-audio-doesn-t-work-on-some-devices/td-p/10335732) — Samsung Hardware Offload 問題
- [XDA A2DP Hardware Offload Discussion](https://xdaforums.com/t/disable-bluetooth-a2dp-hardware-offload.3856557/page-2) — Hardware Offload 討論
- [XDA Forums: Can't change Bluetooth audio codecs](https://xdaforums.com/t/cant-change-bluetooth-audio-codecs-or.3764422/) — 使用者痛點
- [Android Police: How to change Bluetooth codec](https://www.androidpolice.com/change-bluetooth-codec-android/) — 使用者指南

---

*研究完成日期：2026-02-08*
*準備進行路線圖規劃：是*
