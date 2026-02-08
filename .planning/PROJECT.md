# Mobile OS Versions - Bluetooth Audio Device Feature

## What This Is

在現有的 Mobile OS Versions Flutter App 中新增藍牙音訊裝置頁面功能。這個頁面讓用戶可以查看目前連接的藍牙音訊裝置詳細資訊，並即時切換音訊編碼參數。頁面從左側選單進入，僅支援 Android 平台。

## Core Value

讓用戶能夠查看並即時調整藍牙音訊裝置的編碼參數（codec、取樣率、位元深度、bitrate），以獲得最佳音質體驗。

## Requirements

### Validated

- ✓ OS 版本資訊顯示（Android/iOS） — existing
- ✓ 裝置資訊查詢 — existing
- ✓ BLoC 狀態管理架構 — existing
- ✓ Platform Channel 原生呼叫模式 — existing
- ✓ 左側抽屜選單導航 — existing

### Active

- [ ] 顯示藍牙裝置基本資訊（版本、名稱、MAC）
- [ ] 顯示耳機支援的 codec 清單
- [ ] 顯示手機支援的 codec 清單
- [ ] 顯示目前使用的 codec 及其參數
- [ ] 即時切換 codec
- [ ] 即時切換取樣率（44.1kHz / 48kHz）
- [ ] 即時切換位元深度（16bit / 24bit）
- [ ] 即時切換 bitrate（400kbps / 600kbps / 900kbps / ABR）
- [ ] 無連接時顯示空狀態提示

### Out of Scope

- iOS 平台支援 — 藍牙音訊控制 API 在 iOS 上限制較多
- 藍牙裝置配對/連接管理 — 使用系統設定處理
- 音訊播放功能 — 這不是播放器 App
- 歷史連接記錄 — 保持簡單，只顯示當前連接裝置

## Context

**現有架構：**
- Flutter App 使用 BLoC pattern 管理狀態
- 已有 Platform Channel 原生呼叫經驗（DeviceVersionProvider）
- 左側抽屜選單已有多個頁面入口
- Android 特定功能已有條件判斷模式

**技術背景：**
- Android Bluetooth A2DP API 可取得 codec 資訊
- BluetoothCodecConfig 類別包含 codec 類型、取樣率、位元深度等
- 需要 BLUETOOTH_CONNECT 權限（Android 12+）
- 部分 codec 切換可能需要開發者選項開啟

**藍牙 Codec 參考：**
- SBC：標準 codec，所有裝置都支援
- AAC：Apple 生態系常用
- aptX / aptX HD：高通晶片組
- LDAC：Sony 高解析度 codec
- LHDC：華為/榮耀高解析度 codec

## Constraints

- **Platform**: 僅限 Android — iOS 不開放藍牙音訊 codec 控制 API
- **Tech stack**: 維持現有架構 — 使用 BLoC、Platform Channel、現有 UI 模式
- **Permissions**: 需處理藍牙權限請求 — Android 12+ 需要 BLUETOOTH_CONNECT

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 僅支援 Android | iOS 不開放 codec 控制 API | — Pending |
| 使用 Platform Channel | 維持現有架構一致性 | — Pending |
| 即時切換（非確認後切換） | 用戶期望的直覺操作 | — Pending |

---
*Last updated: 2026-02-08 after initialization*
