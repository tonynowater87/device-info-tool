# 功能特性研究：藍牙音訊控制應用程式

**領域：** Android 藍牙音訊裝置控制
**研究日期：** 2026-02-08
**信心等級：** MEDIUM（基於 WebSearch 和官方文件驗證）

## 研究背景

本研究針對 Android 平台上的藍牙音訊裝置控制功能進行調查，特別聚焦於：
- 顯示已連接藍牙音訊裝置的詳細資訊
- 即時切換音訊編碼參數（codec、取樣率、位元深度、bitrate）
- 使用者期望的核心功能與差異化功能

## 必備功能（Table Stakes）

這些功能是用戶的基本期望。缺少任何一項，用戶會認為 App 功能不完整。

| 功能 | 期望原因 | 複雜度 | 備註 |
|------|---------|--------|------|
| **顯示當前連接狀態** | 使用者需要知道是否有藍牙裝置已連接 | Low | 透過 BluetoothA2dp API 可輕鬆取得 |
| **顯示裝置基本資訊** | 確認正在控制的是哪個裝置 | Low | 包含：裝置名稱、MAC 位址 |
| **顯示當前使用的 Codec** | 這是 codec 控制 App 的核心價值 | Low | BluetoothCodecStatus 提供當前 codec 資訊 |
| **顯示當前 Codec 參數** | 使用者需要知道目前的音質設定 | Low | 包含：取樣率、位元深度、bitrate |
| **顯示裝置支援的 Codec 清單** | 使用者需要知道可以切換到哪些 codec | Medium | 需要解析 BluetoothCodecStatus.getCodecsSelectableCapabilities() |
| **顯示手機支援的 Codec 清單** | 避免使用者嘗試不相容的 codec | Medium | 需要查詢本地藍牙能力 |
| **切換 Codec** | 這是 App 的主要功能訴求 | High | 需要呼叫 setCodecConfigPreference()，處理切換失敗 |
| **無連接時的空狀態提示** | 良好的 UX，避免使用者困惑 | Low | 顯示「請先連接藍牙音訊裝置」提示 |
| **藍牙權限處理** | Android 12+ 強制要求 BLUETOOTH_CONNECT 執行階段權限 | Medium | 需要處理權限請求、拒絕情境、不同 Android 版本 |

## 差異化功能（Differentiators）

這些功能可讓產品脫穎而出，雖非必備但能提供額外價值。

| 功能 | 價值主張 | 複雜度 | 備註 |
|------|---------|--------|------|
| **即時切換取樣率** | 讓使用者在音質與穩定性間平衡 | High | 44.1kHz / 48kHz，部分 codec 支援 96kHz |
| **即時切換位元深度** | 進階使用者追求更高音質 | High | 16bit / 24bit，需確認裝置支援 |
| **即時切換 Bitrate** | LDAC/aptX Adaptive 等 codec 的關鍵調校參數 | High | LDAC: 330/660/990kbps，需處理連線品質影響 |
| **顯示藍牙版本資訊** | 幫助使用者了解裝置能力上限 | Low | 手機的藍牙版本（5.0/5.1/5.2/6.0 等） |
| **顯示連接品質指標** | 讓使用者了解為何需要降低 bitrate | Medium | 訊號強度、連線穩定度（如果 API 有提供） |
| **Codec 預設設定儲存** | 解決「設定不會保留」的使用者痛點 | Medium | 儲存每個裝置的偏好 codec 設定 |
| **自動套用儲存的設定** | 連接時自動切換到使用者偏好設定 | High | 需監聽藍牙連接事件並自動切換 |
| **Codec 建議模式** | 幫助不熟悉的使用者選擇最佳設定 | Medium | 根據裝置能力推薦最佳 codec 組合 |
| **快速切換預設組合** | 音樂/遊戲/通話等場景的快速切換 | Medium | 預定義的 codec 組合（如：遊戲＝低延遲、音樂＝高音質） |

## 反功能（Anti-Features）

這些是應該刻意「不」開發的功能，在此領域中常見的錯誤做法。

| 反功能 | 避免原因 | 應該做什麼 |
|--------|---------|-----------|
| **藍牙裝置配對管理** | 這是系統設定的職責，重複開發會增加複雜度且用戶體驗不如系統設定 | 引導使用者到系統設定進行配對 |
| **音訊播放器功能** | 功能範疇蔓延，市面上已有專業播放器 App | 專注於 codec 控制，讓使用者用他們喜歡的播放器 |
| **歷史連接記錄** | 增加資料儲存複雜度，價值有限 | 只顯示當前連接的裝置 |
| **多裝置同時控制** | A2DP 協定一次只能連接一個音訊裝置 | 只處理當前連接的音訊裝置 |
| **嘗試修改不相容的 Codec** | 會導致切換失敗，造成使用者困惑 | 只顯示雙方都支援的 codec |
| **強制推送設定到裝置** | 違反使用者預期，有些使用者希望讓系統自動選擇 | 提供「系統自動選擇」選項 |
| **背景持續監控並自動調整** | 耗電且可能干擾使用者的手動設定 | 只在使用者明確要求時切換 |
| **iOS 平台支援** | iOS 不開放 codec 控制 API，投資開發無法實現功能 | 明確標示為 Android 專用功能 |
| **需要 root 權限的功能** | 限制使用者群體，增加安全風險 | 只使用公開的 Android API |
| **完整的開發者選項替代品** | 範疇過大，維護成本高 | 專注於 codec 控制核心功能 |

## 功能依賴關係

```
藍牙權限請求 (BLUETOOTH_CONNECT)
    ↓
偵測藍牙裝置連接狀態
    ↓
├─ 已連接 → 顯示裝置基本資訊
│   ↓
│   查詢 Codec 支援能力
│       ↓
│       ├─ 顯示手機支援的 Codec
│       ├─ 顯示裝置支援的 Codec
│       └─ 顯示當前使用的 Codec + 參數
│           ↓
│           提供 Codec 切換功能
│               ↓
│               ├─ 切換 Codec 類型
│               ├─ 切換取樣率
│               ├─ 切換位元深度
│               └─ 切換 Bitrate
│
└─ 未連接 → 顯示空狀態提示
```

### 依賴說明

1. **前置依賴：藍牙權限**
   - Android 12+ 必須先取得 BLUETOOTH_CONNECT 執行階段權限
   - 所有功能都依賴此權限

2. **核心依賴：裝置連接狀態**
   - 必須有藍牙音訊裝置連接才能存取 codec 資訊
   - 未連接時只能顯示空狀態

3. **資訊依賴：Codec 支援能力**
   - 必須先知道雙方支援哪些 codec，才能提供切換選項
   - 避免嘗試切換不相容的 codec

4. **進階功能依賴：**
   - **自動套用設定** 依賴 **儲存預設設定**
   - **快速切換預設組合** 依賴 **基本 Codec 切換**

## MVP 建議

### 第一階段 MVP（核心功能）

優先實作這些功能，建立基本可用的產品：

1. **藍牙權限處理** — 必備的前置作業
2. **顯示連接狀態** — 讓使用者知道是否有裝置連接
3. **顯示裝置基本資訊** — 名稱、MAC 位址
4. **顯示當前 Codec 和參數** — 核心資訊展示
5. **顯示支援的 Codec 清單** — 手機和裝置各自支援的 codec
6. **切換 Codec** — 核心功能，讓使用者可以切換 codec 類型
7. **空狀態提示** — 良好的 UX

### 延後至 Post-MVP

這些功能可在核心功能穩定後再加入：

- **即時切換取樣率/位元深度/Bitrate** — 進階參數調整，需要更複雜的 UI
  - 延後原因：核心價值在於 codec 切換，參數微調是進階需求

- **Codec 預設設定儲存與自動套用** — 需要本地儲存和背景監聽
  - 延後原因：需要額外的資料持久化機制和藍牙事件監聽

- **顯示藍牙版本資訊** — 有助於理解但非必要
  - 延後原因：資訊性功能，對核心操作無影響

- **連接品質指標** — 需確認 API 是否提供此資訊
  - 延後原因：API 可用性不確定，需額外研究

- **Codec 建議模式** — 需要領域知識決策邏輯
  - 延後原因：需要更多使用者回饋來定義「最佳」建議

- **快速切換預設組合** — 需要預先定義和儲存機制
  - 延後原因：屬於進階便利性功能

## 技術考量

### Codec 支援矩陣（2026）

| Codec | Bitrate 範圍 | 取樣率 | 位元深度 | 備註 |
|-------|-------------|--------|---------|------|
| **SBC** | 240-345 kbps | 44.1/48 kHz | 16-bit | 所有裝置都支援，基準 codec |
| **AAC** | 最高 320 kbps | 最高 48 kHz | 24-bit | iOS 和 Android 廣泛支援 |
| **aptX** | 352 kbps | 44.1/48 kHz | 16-bit | Qualcomm，標準品質 |
| **aptX HD** | 最高 576 kbps | 48 kHz | 24-bit | 高品質，Qualcomm |
| **aptX Adaptive** | 279-420 kbps（動態） | 最高 96 kHz | 24-bit | 自適應，低延遲模式 |
| **LDAC** | 330/660/990 kbps | 最高 96 kHz | 24-bit | Sony，Android 8.0+ 內建 |
| **LHDC** | 400/560/900 kbps | 最高 96 kHz | 24-bit | 華為/榮耀 |
| **SSC** | 88-512 kbps | 48 kHz | 24-bit | Samsung Seamless Codec |
| **LC3** | 最高 345 kbps | 最高 48 kHz | — | Bluetooth LE Audio 新標準 |

### 常見使用者痛點（需在設計中避免）

根據研究發現的使用者問題：

1. **Codec 設定不會保留**
   - 症狀：斷線重連後設定回到預設值
   - 影響：使用者每次都要重新設定
   - 建議：提供「記住此裝置的設定」功能

2. **高 bitrate 連線不穩定**
   - 症狀：LDAC 990kbps 在某些手機（如 Google Pixel Tensor 晶片）會斷線
   - 影響：使用者追求高音質反而得到糟糕體驗
   - 建議：提供穩定性建議（如「建議使用 660kbps」）

3. **雙方支援度不明確**
   - 症狀：使用者不知道為什麼某些 codec 無法選擇
   - 影響：困惑和挫折感
   - 建議：清楚標示「手機支援」、「裝置支援」、「雙方支援（可用）」

4. **隱藏在開發者選項中**
   - 症狀：一般使用者不知道如何開啟開發者選項
   - 影響：功能難以被發現
   - 建議：我們的 App 就是解決這個問題，提供易用介面

## 複雜度評估

### Low 複雜度（1-2 天）
- 顯示連接狀態
- 顯示裝置基本資訊（名稱、MAC）
- 顯示當前 Codec
- 空狀態提示

### Medium 複雜度（3-5 天）
- 顯示支援的 Codec 清單（需解析 capabilities）
- 藍牙權限處理（需處理多版本 Android）
- Codec 預設設定儲存
- 連接品質指標（如果 API 支援）

### High 複雜度（5-10 天）
- 切換 Codec（需處理各種失敗情境）
- 即時切換取樣率/位元深度/Bitrate（需要複雜 UI 和參數驗證）
- 自動套用儲存的設定（需背景監聽和自動化邏輯）
- Codec 建議模式（需要決策邏輯）

## 資料來源

**市場研究：**
- [Bluetooth Codec Changer - Google Play](https://play.google.com/store/apps/details?id=com.amrg.bluetooth_codec_converter&hl=en_US)
- [TechRadar: Bluetooth Codec Changer app review](https://www.techradar.com/computing/websites-apps/bluetooth-codec-changer)
- [Android Audio Fix 2026: Hidden Bluetooth Codec Settings](https://phonetechwiki.com/android-fix-hidden-bluetooth-codec-settings/)

**技術規格：**
- [Android Developers: BluetoothCodecConfig](https://developer.android.com/reference/android/bluetooth/BluetoothCodecConfig)
- [Android Open Source Project: Bluetooth services](https://source.android.com/docs/core/connect/bluetooth/services)
- [Bluetooth Codecs Guide 2026](https://en.androidayuda.com/android/is/bluetooth-codecs-guide-ldac-vs-aptx-vs-aac/)
- [Best Bluetooth Audio Codecs 2026](https://vintagevinylnews.com/bluetooth-audio-codecs/)
- [Understanding Bluetooth codecs - SoundGuys](https://www.soundguys.com/understanding-bluetooth-codecs-15352/)

**使用者體驗問題：**
- [XDA Forums: Can't change Bluetooth audio codecs](https://xdaforums.com/t/cant-change-bluetooth-audio-codecs-or.3764422/)
- [Android Police: How to change Bluetooth codec](https://www.androidpolice.com/change-bluetooth-codec-android/)
- [Medium: Permanently change Bluetooth device codec](https://medium.com/@amr2018xo/permanently-change-your-bluetooth-device-codec-android-e288ee982756)

**權限處理：**
- [Android Developers: Bluetooth permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions)
- [Punch Through: Mastering Android BLE Permissions](https://punchthrough.com/mastering-permissions-for-bluetooth-low-energy-android/)

**信心等級說明：**
- 功能分類和 codec 技術規格：MEDIUM（基於多個來源交叉驗證的 WebSearch 結果）
- Codec 參數範圍：MEDIUM（來自多個藍牙技術網站和開發者論壇）
- 使用者痛點：HIGH（來自真實使用者回報和論壇討論）
- Android API 能力：MEDIUM（官方文件摘要，需進一步驗證具體方法）

---

*研究完成：2026-02-08*
*下一步：根據此功能分類定義詳細需求和 UI 設計*
