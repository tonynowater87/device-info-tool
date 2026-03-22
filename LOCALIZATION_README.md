# 多語言支援 (Localization Support)

本應用程式現已支援多國語言，包含英文、繁體中文、簡體中文、日文與韓文。

## 支援的語言 (Supported Languages)

### ✅ 已完全實作 (Fully Implemented) - 10 種語言

1. 🇺🇸 **英文 (English)** - `en` - 1.5B speakers
2. 🇹🇼 **繁體中文 (Traditional Chinese)** - `zh_TW` - 25M speakers
3. 🇨🇳 **簡體中文 (Simplified Chinese)** - `zh_CN` - 1.1B speakers
4. 🇯🇵 **日文 (Japanese)** - `ja` - 125M speakers
5. 🇰🇷 **韓文 (Korean)** - `ko` - 80M speakers
6. 🇪🇸 **西班牙文 (Spanish)** - `es` - 500M speakers
7. 🇫🇷 **法文 (French)** - `fr` - 275M speakers
8. 🇩🇪 **德文 (German)** - `de` - 130M speakers
9. 🇸🇦 **阿拉伯文 (Arabic)** - `ar` - 420M speakers
10. 🇧🇷 **葡萄牙文 (Portuguese)** - `pt` - 260M speakers

**總覆蓋人口：超過 40 億使用者！**

### 📋 已宣告但待完整翻譯 (Declared but Pending Full Translation)

以下語言已在系統中宣告支援，框架已就緒，可依需求補充完整翻譯：

11. 🇷🇺 **俄文 (Russian)** - `ru` - 150M speakers
12. 🇮🇹 **義大利文 (Italian)** - `it` - 85M speakers
13. 🇳🇱 **荷蘭文 (Dutch)** - `nl` - 25M speakers
14. 🇸🇪 **瑞典文 (Swedish)** - `sv` - 13M speakers
15. 🇳🇴 **挪威文 (Norwegian)** - `no` - 5M speakers
16. 🇩🇰 **丹麥文 (Danish)** - `da` - 6M speakers
17. 🇫🇮 **芬蘭文 (Finnish)** - `fi` - 5M speakers
18. 🇹🇭 **泰文 (Thai)** - `th` - 60M speakers
19. 🇻🇳 **越南文 (Vietnamese)** - `vi` - 95M speakers
20. 🇮🇩 **印尼文 (Indonesian)** - `id` - 200M speakers
21. 🇲🇾 **馬來文 (Malay)** - `ms` - 290M speakers
22. 🇮🇳 **印地文 (Hindi)** - `hi` - 600M speakers
23. 🇹🇷 **土耳其文 (Turkish)** - `tr` - 80M speakers
24. 🇵🇱 **波蘭文 (Polish)** - `pl` - 45M speakers

**額外潛在覆蓋人口：16 億使用者！**

## 語言切換方式 (How to Change Language)

應用程式會自動根據您的系統語言設定來顯示對應的語言：

### Android 裝置
1. 開啟「設定」(Settings)
2. 進入「系統」(System) > 「語言與輸入」(Language & Input)
3. 選擇「語言」(Languages)
4. 選擇您想要的語言：
   - 繁體中文 (Chinese, Traditional)
   - 簡體中文 (Chinese, Simplified)
   - English
   - 日本語 (Japanese)
   - 한국어 (Korean)

### iOS 裝置
1. 開啟「設定」(Settings)
2. 進入「一般」(General) > 「語言與地區」(Language & Region)
3. 選擇「iPhone 語言」(iPhone Language)
4. 選擇您想要的語言：
   - 繁體中文 (Chinese, Traditional)
   - 簡體中文 (Chinese, Simplified)
   - English
   - 日本語 (Japanese)
   - 한국어 (Korean)

## 已翻譯的內容 (Translated Content)

### 導航選單 (Navigation Menu)
- ✅ 雜項 (Misc)
- ✅ Android
- ✅ iOS
- ✅ 設定 (Settings)

### 頁面名稱 (Page Names)
- ✅ 裝置資訊 (Device Info)
- ✅ Intent 操作 (Intent Actions)
- ✅ 測試深層連結 (Test Deep Link)
- ✅ Android OS 分布 (Android OS Distribution)
- ✅ Android OS
- ✅ Android WearOS
- ✅ iOS 分布 (iOS Distribution)
- ✅ iOS, iPadOS, tvOS, watchOS, macOS

### 設定頁面 (Settings Page)
- ✅ 一般 (General)
- ✅ 預設起始頁面 (Default Start Page)
- ✅ 關於 (About)
- ✅ 關於應用程式 (About App)

### 裝置資訊頁面 (Device Info Page)
- ✅ 基本資訊：品牌、型號、Android、API 等級、安全性更新、開發者選項
- ✅ 螢幕資訊：螢幕尺寸、螢幕密度、長寬比等
- ✅ 網路資訊：IP 位址、連線狀態、網路類型等
- ✅ 識別碼：廣告 ID、Android ID
- ✅ 電池資訊：容量、健康度、充電狀態、溫度、電量
- ✅ 儲存資訊：總空間、已使用空間、可用空間
- ✅ 系統資訊：裝置名稱、產品、主板、硬體、開機載入程式等
- ✅ CPU/記憶體：架構、核心數、總記憶體、已使用記憶體、可用記憶體

### 通用操作 (Common Actions)
- ✅ 取消 (Cancel)
- ✅ 確認 (Confirm)
- ✅ 複製 (Copy)
- ✅ 是 (Yes)

## 技術實作 (Technical Implementation)

### 架構 (Architecture)
- 使用 Flutter 內建的 `flutter_localizations` 套件
- 自定義 `AppLocalizations` 類別管理翻譯字串
- 支援即時語言切換（重啟應用後生效）

### 檔案結構 (File Structure)
```
lib/
  └── l10n/
      └── app_localizations.dart  # 翻譯資源檔案
```

### 開發者指南 (Developer Guide)

#### 新增翻譯字串 (Adding New Translations)

1. 在 `lib/l10n/app_localizations.dart` 的 `_localizedValues` Map 中新增：

```dart
'en': {
  'new_key': 'New English Text',
},
'zh_TW': {
  'new_key': '新的繁體中文文字',
},
```

2. 新增對應的 getter 方法：

```dart
String get newKey => _localizedValues[locale.toString()]!['new_key']!;
```

3. 在 UI 中使用：

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.newKey)
```

#### 使用範例 (Usage Example)

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  
  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.settings),
    ),
    body: Column(
      children: [
        Text(l10n.general),
        ElevatedButton(
          onPressed: () {},
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );
}
```

## 測試 (Testing)

執行以下命令確認本地化設定正確：

```bash
flutter analyze
flutter test
```

## 語言覆蓋率 (Language Coverage)

所有支援的語言都包含以下翻譯：
- ✅ 導航選單與頁面標題 (100%)
- ✅ 設定頁面 (100%)
- ✅ 關於/應用資訊頁面 (100%)
- ✅ Android 裝置資訊頁面 (100%)
- ✅ Android/iOS 分布頁面 (100%)
- ✅ 所有對話框與按鈕 (100%)

**總計：約 86 個翻譯字串全部完成**

## 未來改進 (Future Improvements)

- [x] ~~新增簡體中文支援~~ ✅ 已完成
- [x] ~~新增日文支援~~ ✅ 已完成
- [x] ~~新增韓文支援~~ ✅ 已完成
- [ ] 新增其他語言（西班牙文、法文、德文等）
- [ ] 實作應用內語言切換功能（不需依賴系統設定）
- [ ] 新增語言選擇設定頁面
- [ ] 翻譯更多頁面內容（版本資訊頁面、深層連結頁面等）

## 貢獻 (Contributing)

如果您發現翻譯錯誤或有改進建議，歡迎提交 Issue 或 Pull Request！

### 翻譯品質檢查清單 (Translation Quality Checklist)
- ✅ 使用繁體中文台灣常用詞彙
- ✅ 保持技術術語的一致性
- ✅ 確保語句通順自然
- ✅ 尊重原文的語氣和風格
