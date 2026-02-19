import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('zh', 'TW'),
    Locale('zh', 'CN'),
    Locale('ja', ''),
    Locale('ko', ''),
    Locale('es', ''),      // Spanish
    Locale('fr', ''),      // French
    Locale('de', ''),      // German
    Locale('ar', ''),      // Arabic
    Locale('pt', ''),      // Portuguese
    Locale('ru', ''),      // Russian
    Locale('it', ''),      // Italian
    Locale('nl', ''),      // Dutch
    Locale('sv', ''),      // Swedish
    Locale('no', ''),      // Norwegian
    Locale('da', ''),      // Danish
    Locale('fi', ''),      // Finnish
    Locale('th', ''),      // Thai
    Locale('vi', ''),      // Vietnamese
    Locale('id', ''),      // Indonesian
    Locale('ms', ''),      // Malay
    Locale('hi', ''),      // Hindi
    Locale('tr', ''),      // Turkish
    Locale('pl', ''),      // Polish
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation & Menu
      'misc': 'Misc',
      'android': 'Android',
      'ios': 'iOS',
      'settings': 'Settings',
      
      // Page Names
      'device_info': 'Device Info',
      'intent_actions': 'Intent Actions',
      'test_deep_link': 'Test Deep Link',
      'android_os_distribution': 'Android OS Distribution',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'iOS Distribution',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': 'General',
      'default_start_page': 'Default Start Page',
      'none_first_page': 'None (First Page)',
      'about': 'About',
      'about_app': 'About App',
      'default_page_set_to': 'Default page set to',
      
      // Common Actions
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'copy': 'Copy',
      'yes': 'Yes',
      'order_reset_to_default': 'Order reset to default',
      
      // Device Info - Basic
      'brand': 'Brand',
      'model': 'Model',
      'android_os_name': 'Android',
      'api_level': 'API Level',
      'security_patch': 'Security Patch',
      'developer_options': 'Developer Options',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      
      // Device Info - Screen
      'screen_size_px': 'Screen Size (px)',
      'screen_size_dp': 'Screen Size (dp)',
      'screen_size_inch': 'Screen Size (inch)',
      'screen_aspect_ratio': 'Screen Aspect Ratio',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': 'Screen Density',
      
      // Device Info - Network
      'ip_address': 'IP Address',
      'connectivity': 'Connectivity',
      'network_type': 'Network Type',
      'network_subtype': 'Network Subtype',
      'network_state': 'Network State',
      'is_roaming': 'Is Roaming',
      
      // Device Info - IDs
      'ad_id': 'AD ID',
      'android_id': 'Android ID',
      
      // Device Info - Battery
      'capacity': 'Capacity',
      'health': 'Health',
      'charging_status': 'Charging Status',
      'temperature': 'Temperature',
      'battery_level': 'Battery Level',
      
      // Device Info - Storage
      'total_space': 'Total Space',
      'used_space': 'Used Space',
      'available_space': 'Available Space',
      
      // Device Info - System
      'device_name': 'Device Name',
      'product': 'Product',
      'board': 'Board',
      'hardware': 'Hardware',
      'bootloader': 'Bootloader',
      'device_type': 'Device Type',
      'radio_version': 'Radio Version',
      'system_locale': 'System Locale',
      'time_zone': 'Time Zone',
      'supported_abis': 'Supported ABIs',
      '64_bit_support': '64-bit Support',
      
      // Device Info - CPU/Memory
      'architecture': 'Architecture',
      'core_count': 'Core Count',
      'total_memory': 'Total Memory',
      'used_memory': 'Used Memory',
      'available_memory': 'Available Memory',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': 'Used Third-Party Packages',
      'donate': 'Donate',
      'show_interstitial_ad_confirm': 'Are you sure to show an interstitial ad?',
      'open_web_link_confirm': 'Are you sure to open the web-link?',
      'dismiss': 'Dismiss',
      
      // Distribution Pages
      'cumulative': 'Cumulative',
      'individual': 'Individual',
      'last_updated': 'Last updated',
      'data_from': 'data from',
      'oops_something_wrong': 'Oops, Something wrong!',
      'retry': 'Retry',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': 'Settings Page',
      'intent_developer_options': 'Developer Options Page',
      'intent_app_info': 'App Info & Permissions',
      'intent_usage_access': 'Usage Access Settings',
      'intent_display_over_apps': 'Display Over Other Apps',
      'intent_modify_system': 'Modify System Settings',
      'intent_install_unknown': 'Install Unknown Apps',
      'intent_do_not_disturb': 'Do Not Disturb Access',
      'intent_locale': 'Locale & Language',
      'intent_all_apps': 'All Applications',
      'intent_wifi': 'WiFi Settings',
      'intent_bluetooth': 'Bluetooth Settings',
      'intent_date_time': 'Date & Time',
      'intent_display': 'Display Settings',
      'intent_accessibility': 'Accessibility Settings',
      'intent_about_device': 'About Device',
      'intent_notifications': 'Notification Settings',
      'intent_default_apps': 'Default Apps',
      'intent_sound': 'Sound Settings',
      'intent_storage': 'Storage Settings',
      'intent_battery': 'Battery & Power Saving',
      'intent_location': 'Location Services',
      'intent_security': 'Security Settings',
      'intent_privacy': 'Privacy Settings',
      'intent_nfc': 'NFC Settings',
      'intent_accounts': 'Accounts & Sync',
      'intent_search': 'Search Settings',
      'intent_system_update': 'System Update',
      'intent_biometric': 'Biometric Enrollment',
      'intent_cast': 'Cast Settings',
      'intent_webview': 'WebView Implementation',
    },
    'zh_TW': {
      // Navigation & Menu
      'misc': '雜項',
      'android': 'Android',
      'ios': 'iOS',
      'settings': '設定',
      
      // Page Names
      'device_info': '裝置資訊',
      'intent_actions': 'Intent 操作',
      'test_deep_link': '測試深層連結',
      'android_os_distribution': 'Android OS 分布',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'iOS 分布',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': '一般',
      'default_start_page': '預設起始頁面',
      'none_first_page': '無（第一頁）',
      'about': '關於',
      'about_app': '關於應用程式',
      'default_page_set_to': '預設頁面已設定為',
      
      // Common Actions
      'cancel': '取消',
      'confirm': '確認',
      'copy': '複製',
      'yes': '是',
      'order_reset_to_default': '順序已重設為預設',
      
      // Device Info - Basic
      'brand': '品牌',
      'model': '型號',
      'android_os_name': 'Android',
      'api_level': 'API 等級',
      'security_patch': '安全性更新',
      'developer_options': '開發者選項',
      'enabled': '已啟用',
      'disabled': '已停用',
      
      // Device Info - Screen
      'screen_size_px': '螢幕尺寸 (px)',
      'screen_size_dp': '螢幕尺寸 (dp)',
      'screen_size_inch': '螢幕尺寸 (英吋)',
      'screen_aspect_ratio': '螢幕長寬比',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': '螢幕密度',
      
      // Device Info - Network
      'ip_address': 'IP 位址',
      'connectivity': '連線狀態',
      'network_type': '網路類型',
      'network_subtype': '網路子類型',
      'network_state': '網路狀態',
      'is_roaming': '是否漫遊',
      
      // Device Info - IDs
      'ad_id': '廣告 ID',
      'android_id': 'Android ID',
      
      // Device Info - Battery
      'capacity': '容量',
      'health': '健康度',
      'charging_status': '充電狀態',
      'temperature': '溫度',
      'battery_level': '電量',
      
      // Device Info - Storage
      'total_space': '總空間',
      'used_space': '已使用空間',
      'available_space': '可用空間',
      
      // Device Info - System
      'device_name': '裝置名稱',
      'product': '產品',
      'board': '主板',
      'hardware': '硬體',
      'bootloader': '開機載入程式',
      'device_type': '裝置類型',
      'radio_version': '基頻版本',
      'system_locale': '系統語言',
      'time_zone': '時區',
      'supported_abis': '支援的 ABI',
      '64_bit_support': '64 位元支援',
      
      // Device Info - CPU/Memory
      'architecture': '架構',
      'core_count': '核心數',
      'total_memory': '總記憶體',
      'used_memory': '已使用記憶體',
      'available_memory': '可用記憶體',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': '使用的第三方套件',
      'donate': '贊助',
      'show_interstitial_ad_confirm': '確定要顯示插頁式廣告嗎？',
      'open_web_link_confirm': '確定要開啟此網頁連結嗎？',
      'dismiss': '關閉',
      
      // Distribution Pages
      'cumulative': '累積',
      'individual': '個別',
      'last_updated': '最後更新',
      'data_from': '資料來源',
      'oops_something_wrong': '糟糕,發生錯誤！',
      'retry': '重試',

      // Bluetooth Audio
      'bluetooth_audio': '藍牙音訊',
      'bluetooth_not_supported': '不支援',
      'bluetooth_permission_required': '需要藍牙權限',
      'bluetooth_permission_denied': '請授予藍牙權限以查看裝置資訊。',
      'bluetooth_permission_permanently_denied': '藍牙權限已被拒絕。請前往設定開啟權限。',
      'bluetooth_disabled': '藍牙已關閉',
      'bluetooth_disabled_hint': '請開啟藍牙以查看已連接裝置資訊。',
      'no_bluetooth_device': '無藍牙音訊裝置',
      'no_bluetooth_device_hint': '請連接藍牙耳機或喇叭以查看裝置資訊。',
      'request_permission': '請求權限',
      'open_settings': '開啟設定',
      'error': '錯誤',
      'mac_address': 'MAC 位址',
      'bluetooth_version': '藍牙版本',
      'codec_info': '編碼資訊',
      'codec_type': 'Codec 類型',
      'sample_rate': '取樣率',
      'bits_per_sample': '位元深度',
      'channel_mode': '聲道模式',
      'bitrate': '位元率',

      // Intent Actions
      'intent_settings': '設定頁面',
      'intent_developer_options': '開發者選項頁面',
      'intent_app_info': '應用程式資訊與權限',
      'intent_usage_access': '使用狀況存取設定',
      'intent_display_over_apps': '顯示在其他應用程式上層',
      'intent_modify_system': '修改系統設定',
      'intent_install_unknown': '安裝未知應用程式',
      'intent_do_not_disturb': '勿擾模式存取',
      'intent_locale': '語言與地區',
      'intent_all_apps': '所有應用程式',
      'intent_wifi': 'WiFi 設定',
      'intent_bluetooth': '藍牙設定',
      'intent_date_time': '日期與時間',
      'intent_display': '顯示設定',
      'intent_accessibility': '無障礙設定',
      'intent_about_device': '關於裝置',
      'intent_notifications': '通知設定',
      'intent_default_apps': '預設應用程式',
      'intent_sound': '音效設定',
      'intent_storage': '儲存空間設定',
      'intent_battery': '電池與省電',
      'intent_location': '定位服務',
      'intent_security': '安全性設定',
      'intent_privacy': '隱私權設定',
      'intent_nfc': 'NFC 設定',
      'intent_accounts': '帳號與同步',
      'intent_search': '搜尋設定',
      'intent_system_update': '系統更新',
      'intent_biometric': '生物辨識註冊',
      'intent_cast': '投放設定',
      'intent_webview': 'WebView 實作',
    },
    'zh_CN': {
      // Navigation & Menu
      'misc': '杂项',
      'android': 'Android',
      'ios': 'iOS',
      'settings': '设置',
      
      // Page Names
      'device_info': '设备信息',
      'intent_actions': 'Intent 操作',
      'test_deep_link': '测试深层链接',
      'android_os_distribution': 'Android OS 分布',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'iOS 分布',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': '常规',
      'default_start_page': '默认起始页面',
      'none_first_page': '无（第一页）',
      'about': '关于',
      'about_app': '关于应用',
      'default_page_set_to': '默认页面已设置为',
      
      // Common Actions
      'cancel': '取消',
      'confirm': '确认',
      'copy': '复制',
      'yes': '是',
      'order_reset_to_default': '顺序已重置为默认',
      
      // Device Info - Basic
      'brand': '品牌',
      'model': '型号',
      'android_os_name': 'Android',
      'api_level': 'API 级别',
      'security_patch': '安全更新',
      'developer_options': '开发者选项',
      'enabled': '已启用',
      'disabled': '已禁用',
      
      // Device Info - Screen
      'screen_size_px': '屏幕尺寸 (px)',
      'screen_size_dp': '屏幕尺寸 (dp)',
      'screen_size_inch': '屏幕尺寸 (英寸)',
      'screen_aspect_ratio': '屏幕宽高比',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': '屏幕密度',
      
      // Device Info - Network
      'ip_address': 'IP 地址',
      'connectivity': '连接状态',
      'network_type': '网络类型',
      'network_subtype': '网络子类型',
      'network_state': '网络状态',
      'is_roaming': '是否漫游',
      
      // Device Info - IDs
      'ad_id': '广告 ID',
      'android_id': 'Android ID',
      
      // Device Info - Battery
      'capacity': '容量',
      'health': '健康度',
      'charging_status': '充电状态',
      'temperature': '温度',
      'battery_level': '电量',
      
      // Device Info - Storage
      'total_space': '总空间',
      'used_space': '已用空间',
      'available_space': '可用空间',
      
      // Device Info - System
      'device_name': '设备名称',
      'product': '产品',
      'board': '主板',
      'hardware': '硬件',
      'bootloader': '引导加载程序',
      'device_type': '设备类型',
      'radio_version': '基带版本',
      'system_locale': '系统语言',
      'time_zone': '时区',
      'supported_abis': '支持的 ABI',
      '64_bit_support': '64 位支持',
      
      // Device Info - CPU/Memory
      'architecture': '架构',
      'core_count': '核心数',
      'total_memory': '总内存',
      'used_memory': '已用内存',
      'available_memory': '可用内存',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': '使用的第三方包',
      'donate': '赞助',
      'show_interstitial_ad_confirm': '确定要显示插页式广告吗？',
      'open_web_link_confirm': '确定要打开此网页链接吗？',
      'dismiss': '关闭',
      
      // Distribution Pages
      'cumulative': '累积',
      'individual': '个别',
      'last_updated': '最后更新',
      'data_from': '数据来源',
      'oops_something_wrong': '糟糕，出错了！',
      'retry': '重试',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': '设置页面',
      'intent_developer_options': '开发者选项页面',
      'intent_app_info': '应用信息与权限',
      'intent_usage_access': '使用情况访问设置',
      'intent_display_over_apps': '显示在其他应用上层',
      'intent_modify_system': '修改系统设置',
      'intent_install_unknown': '安装未知应用',
      'intent_do_not_disturb': '勿扰模式访问',
      'intent_locale': '语言与地区',
      'intent_all_apps': '所有应用',
      'intent_wifi': 'WiFi 设置',
      'intent_bluetooth': '蓝牙设置',
      'intent_date_time': '日期与时间',
      'intent_display': '显示设置',
      'intent_accessibility': '无障碍设置',
      'intent_about_device': '关于设备',
      'intent_notifications': '通知设置',
      'intent_default_apps': '默认应用',
      'intent_sound': '声音设置',
      'intent_storage': '存储设置',
      'intent_battery': '电池与节能',
      'intent_location': '位置服务',
      'intent_security': '安全设置',
      'intent_privacy': '隐私设置',
      'intent_nfc': 'NFC 设置',
      'intent_accounts': '账号与同步',
      'intent_search': '搜索设置',
      'intent_system_update': '系统更新',
      'intent_biometric': '生物识别注册',
      'intent_cast': '投屏设置',
      'intent_webview': 'WebView 实现',
    },
    'ja': {
      // Navigation & Menu
      'misc': 'その他',
      'android': 'Android',
      'ios': 'iOS',
      'settings': '設定',
      
      // Page Names
      'device_info': 'デバイス情報',
      'intent_actions': 'Intent アクション',
      'test_deep_link': 'ディープリンクテスト',
      'android_os_distribution': 'Android OS 分布',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'iOS 分布',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': '一般',
      'default_start_page': 'デフォルト開始ページ',
      'none_first_page': 'なし（最初のページ）',
      'about': '情報',
      'about_app': 'アプリについて',
      'default_page_set_to': 'デフォルトページを設定しました',
      
      // Common Actions
      'cancel': 'キャンセル',
      'confirm': '確認',
      'copy': 'コピー',
      'yes': 'はい',
      'order_reset_to_default': '順序をデフォルトにリセットしました',
      
      // Device Info - Basic
      'brand': 'ブランド',
      'model': 'モデル',
      'android_os_name': 'Android',
      'api_level': 'API レベル',
      'security_patch': 'セキュリティパッチ',
      'developer_options': '開発者オプション',
      'enabled': '有効',
      'disabled': '無効',
      
      // Device Info - Screen
      'screen_size_px': '画面サイズ (px)',
      'screen_size_dp': '画面サイズ (dp)',
      'screen_size_inch': '画面サイズ (インチ)',
      'screen_aspect_ratio': '画面アスペクト比',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': '画面密度',
      
      // Device Info - Network
      'ip_address': 'IP アドレス',
      'connectivity': '接続状態',
      'network_type': 'ネットワークタイプ',
      'network_subtype': 'ネットワークサブタイプ',
      'network_state': 'ネットワーク状態',
      'is_roaming': 'ローミング中',
      
      // Device Info - IDs
      'ad_id': '広告 ID',
      'android_id': 'Android ID',
      
      // Device Info - Battery
      'capacity': '容量',
      'health': 'ヘルス',
      'charging_status': '充電状態',
      'temperature': '温度',
      'battery_level': 'バッテリーレベル',
      
      // Device Info - Storage
      'total_space': '総容量',
      'used_space': '使用容量',
      'available_space': '利用可能容量',
      
      // Device Info - System
      'device_name': 'デバイス名',
      'product': '製品',
      'board': 'ボード',
      'hardware': 'ハードウェア',
      'bootloader': 'ブートローダー',
      'device_type': 'デバイスタイプ',
      'radio_version': 'ベースバンドバージョン',
      'system_locale': 'システム言語',
      'time_zone': 'タイムゾーン',
      'supported_abis': 'サポートされる ABI',
      '64_bit_support': '64ビットサポート',
      
      // Device Info - CPU/Memory
      'architecture': 'アーキテクチャ',
      'core_count': 'コア数',
      'total_memory': '総メモリ',
      'used_memory': '使用メモリ',
      'available_memory': '利用可能メモリ',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': '使用しているサードパーティパッケージ',
      'donate': '寄付',
      'show_interstitial_ad_confirm': 'インタースティシャル広告を表示しますか？',
      'open_web_link_confirm': 'このWebリンクを開きますか？',
      'dismiss': '閉じる',
      
      // Distribution Pages
      'cumulative': '累積',
      'individual': '個別',
      'last_updated': '最終更新',
      'data_from': 'データソース',
      'oops_something_wrong': 'エラーが発生しました！',
      'retry': '再試行',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': '設定ページ',
      'intent_developer_options': '開発者向けオプション',
      'intent_app_info': 'アプリ情報と権限',
      'intent_usage_access': '使用状況へのアクセス設定',
      'intent_display_over_apps': '他のアプリの上に表示',
      'intent_modify_system': 'システム設定の変更',
      'intent_install_unknown': '不明なアプリのインストール',
      'intent_do_not_disturb': 'マナーモードへのアクセス',
      'intent_locale': '言語と地域',
      'intent_all_apps': 'すべてのアプリ',
      'intent_wifi': 'WiFi設定',
      'intent_bluetooth': 'Bluetooth設定',
      'intent_date_time': '日付と時刻',
      'intent_display': 'ディスプレイ設定',
      'intent_accessibility': 'ユーザー補助設定',
      'intent_about_device': 'デバイス情報',
      'intent_notifications': '通知設定',
      'intent_default_apps': 'デフォルトアプリ',
      'intent_sound': 'サウンド設定',
      'intent_storage': 'ストレージ設定',
      'intent_battery': 'バッテリーと省電力',
      'intent_location': '位置情報サービス',
      'intent_security': 'セキュリティ設定',
      'intent_privacy': 'プライバシー設定',
      'intent_nfc': 'NFC設定',
      'intent_accounts': 'アカウントと同期',
      'intent_search': '検索設定',
      'intent_system_update': 'システムアップデート',
      'intent_biometric': '生体認証登録',
      'intent_cast': 'キャスト設定',
      'intent_webview': 'WebView実装',
    },
    'ko': {
      // Navigation & Menu
      'misc': '기타',
      'android': 'Android',
      'ios': 'iOS',
      'settings': '설정',
      
      // Page Names
      'device_info': '기기 정보',
      'intent_actions': 'Intent 작업',
      'test_deep_link': '딥링크 테스트',
      'android_os_distribution': 'Android OS 분포',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'iOS 분포',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': '일반',
      'default_start_page': '기본 시작 페이지',
      'none_first_page': '없음 (첫 페이지)',
      'about': '정보',
      'about_app': '앱 정보',
      'default_page_set_to': '기본 페이지가 다음으로 설정되었습니다',
      
      // Common Actions
      'cancel': '취소',
      'confirm': '확인',
      'copy': '복사',
      'yes': '예',
      'order_reset_to_default': '순서가 기본값으로 재설정되었습니다',
      
      // Device Info - Basic
      'brand': '브랜드',
      'model': '모델',
      'android_os_name': 'Android',
      'api_level': 'API 레벨',
      'security_patch': '보안 패치',
      'developer_options': '개발자 옵션',
      'enabled': '활성화됨',
      'disabled': '비활성화됨',
      
      // Device Info - Screen
      'screen_size_px': '화면 크기 (px)',
      'screen_size_dp': '화면 크기 (dp)',
      'screen_size_inch': '화면 크기 (인치)',
      'screen_aspect_ratio': '화면 비율',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': '화면 밀도',
      
      // Device Info - Network
      'ip_address': 'IP 주소',
      'connectivity': '연결 상태',
      'network_type': '네트워크 유형',
      'network_subtype': '네트워크 하위 유형',
      'network_state': '네트워크 상태',
      'is_roaming': '로밍 중',
      
      // Device Info - IDs
      'ad_id': '광고 ID',
      'android_id': 'Android ID',
      
      // Device Info - Battery
      'capacity': '용량',
      'health': '상태',
      'charging_status': '충전 상태',
      'temperature': '온도',
      'battery_level': '배터리 레벨',
      
      // Device Info - Storage
      'total_space': '총 공간',
      'used_space': '사용 공간',
      'available_space': '사용 가능 공간',
      
      // Device Info - System
      'device_name': '기기 이름',
      'product': '제품',
      'board': '보드',
      'hardware': '하드웨어',
      'bootloader': '부트로더',
      'device_type': '기기 유형',
      'radio_version': '베이스밴드 버전',
      'system_locale': '시스템 언어',
      'time_zone': '시간대',
      'supported_abis': '지원되는 ABI',
      '64_bit_support': '64비트 지원',
      
      // Device Info - CPU/Memory
      'architecture': '아키텍처',
      'core_count': '코어 수',
      'total_memory': '총 메모리',
      'used_memory': '사용 메모리',
      'available_memory': '사용 가능 메모리',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': '사용된 타사 패키지',
      'donate': '후원',
      'show_interstitial_ad_confirm': '전면 광고를 표시하시겠습니까?',
      'open_web_link_confirm': '이 웹 링크를 여시겠습니까?',
      'dismiss': '닫기',
      
      // Distribution Pages
      'cumulative': '누적',
      'individual': '개별',
      'last_updated': '마지막 업데이트',
      'data_from': '데이터 출처',
      'oops_something_wrong': '오류가 발생했습니다!',
      'retry': '다시 시도',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': '설정 페이지',
      'intent_developer_options': '개발자 옵션 페이지',
      'intent_app_info': '앱 정보 및 권한',
      'intent_usage_access': '사용 접근 설정',
      'intent_display_over_apps': '다른 앱 위에 표시',
      'intent_modify_system': '시스템 설정 수정',
      'intent_install_unknown': '알 수 없는 앱 설치',
      'intent_do_not_disturb': '방해 금지 모드 접근',
      'intent_locale': '언어 및 지역',
      'intent_all_apps': '모든 애플리케이션',
      'intent_wifi': 'WiFi 설정',
      'intent_bluetooth': '블루투스 설정',
      'intent_date_time': '날짜 및 시간',
      'intent_display': '디스플레이 설정',
      'intent_accessibility': '접근성 설정',
      'intent_about_device': '기기 정보',
      'intent_notifications': '알림 설정',
      'intent_default_apps': '기본 앱',
      'intent_sound': '소리 설정',
      'intent_storage': '저장공간 설정',
      'intent_battery': '배터리 및 절전',
      'intent_location': '위치 서비스',
      'intent_security': '보안 설정',
      'intent_privacy': '개인정보 보호 설정',
      'intent_nfc': 'NFC 설정',
      'intent_accounts': '계정 및 동기화',
      'intent_search': '검색 설정',
      'intent_system_update': '시스템 업데이트',
      'intent_biometric': '생체 인식 등록',
      'intent_cast': '캐스트 설정',
      'intent_webview': 'WebView 구현',
    },
    'es': {
      // Navigation & Menu
      'misc': 'Varios',
      'android': 'Android',
      'ios': 'iOS',
      'settings': 'Configuración',
      
      // Page Names
      'device_info': 'Información del dispositivo',
      'intent_actions': 'Acciones de Intent',
      'test_deep_link': 'Probar enlace profundo',
      'android_os_distribution': 'Distribución de Android OS',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'Distribución de iOS',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': 'General',
      'default_start_page': 'Página de inicio predeterminada',
      'none_first_page': 'Ninguna (Primera página)',
      'about': 'Acerca de',
      'about_app': 'Acerca de la aplicación',
      'default_page_set_to': 'Página predeterminada establecida en',
      
      // Common Actions
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'copy': 'Copiar',
      'yes': 'Sí',
      'order_reset_to_default': 'Orden restablecido a predeterminado',
      
      // Device Info - Basic
      'brand': 'Marca',
      'model': 'Modelo',
      'android_os_name': 'Android',
      'api_level': 'Nivel de API',
      'security_patch': 'Parche de seguridad',
      'developer_options': 'Opciones de desarrollador',
      'enabled': 'Habilitado',
      'disabled': 'Deshabilitado',
      
      // Device Info - Screen
      'screen_size_px': 'Tamaño de pantalla (px)',
      'screen_size_dp': 'Tamaño de pantalla (dp)',
      'screen_size_inch': 'Tamaño de pantalla (pulgadas)',
      'screen_aspect_ratio': 'Relación de aspecto',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': 'Densidad de pantalla',
      
      // Device Info - Network
      'ip_address': 'Dirección IP',
      'connectivity': 'Conectividad',
      'network_type': 'Tipo de red',
      'network_subtype': 'Subtipo de red',
      'network_state': 'Estado de red',
      'is_roaming': 'En itinerancia',
      
      // Device Info - IDs
      'ad_id': 'ID de anuncio',
      'android_id': 'ID de Android',
      
      // Device Info - Battery
      'capacity': 'Capacidad',
      'health': 'Estado',
      'charging_status': 'Estado de carga',
      'temperature': 'Temperatura',
      'battery_level': 'Nivel de batería',
      
      // Device Info - Storage
      'total_space': 'Espacio total',
      'used_space': 'Espacio usado',
      'available_space': 'Espacio disponible',
      
      // Device Info - System
      'device_name': 'Nombre del dispositivo',
      'product': 'Producto',
      'board': 'Placa',
      'hardware': 'Hardware',
      'bootloader': 'Gestor de arranque',
      'device_type': 'Tipo de dispositivo',
      'radio_version': 'Versión de radio',
      'system_locale': 'Idioma del sistema',
      'time_zone': 'Zona horaria',
      'supported_abis': 'ABIs compatibles',
      '64_bit_support': 'Soporte de 64 bits',
      
      // Device Info - CPU/Memory
      'architecture': 'Arquitectura',
      'core_count': 'Número de núcleos',
      'total_memory': 'Memoria total',
      'used_memory': 'Memoria usada',
      'available_memory': 'Memoria disponible',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': 'Paquetes de terceros utilizados',
      'donate': 'Donar',
      'show_interstitial_ad_confirm': '¿Estás seguro de mostrar un anuncio intersticial?',
      'open_web_link_confirm': '¿Estás seguro de abrir este enlace web?',
      'dismiss': 'Cerrar',
      
      // Distribution Pages
      'cumulative': 'Acumulativo',
      'individual': 'Individual',
      'last_updated': 'Última actualización',
      'data_from': 'Datos de',
      'oops_something_wrong': '¡Ups, algo salió mal!',
      'retry': 'Reintentar',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions  
      'intent_settings': 'Página de configuración',
      'intent_developer_options': 'Opciones de desarrollador',
      'intent_app_info': 'Información y permisos de la app',
      'intent_usage_access': 'Configuración de acceso de uso',
      'intent_display_over_apps': 'Mostrar sobre otras apps',
      'intent_modify_system': 'Modificar configuración del sistema',
      'intent_install_unknown': 'Instalar apps desconocidas',
      'intent_do_not_disturb': 'Acceso a No molestar',
      'intent_locale': 'Idioma y región',
      'intent_all_apps': 'Todas las aplicaciones',
      'intent_wifi': 'Configuración de WiFi',
      'intent_bluetooth': 'Configuración de Bluetooth',
      'intent_date_time': 'Fecha y hora',
      'intent_display': 'Configuración de pantalla',
      'intent_accessibility': 'Configuración de accesibilidad',
      'intent_about_device': 'Acerca del dispositivo',
      'intent_notifications': 'Configuración de notificaciones',
      'intent_default_apps': 'Apps predeterminadas',
      'intent_sound': 'Configuración de sonido',
      'intent_storage': 'Configuración de almacenamiento',
      'intent_battery': 'Batería y ahorro de energía',
      'intent_location': 'Servicios de ubicación',
      'intent_security': 'Configuración de seguridad',
      'intent_privacy': 'Configuración de privacidad',
      'intent_nfc': 'Configuración de NFC',
      'intent_accounts': 'Cuentas y sincronización',
      'intent_search': 'Configuración de búsqueda',
      'intent_system_update': 'Actualización del sistema',
      'intent_biometric': 'Inscripción biométrica',
      'intent_cast': 'Configuración de transmisión',
      'intent_webview': 'Implementación de WebView',
    },
    'fr': {
      // Navigation & Menu
      'misc': 'Divers',
      'intent_display_over_apps': 'Mostrar sobre otras apps',
      'intent_modify_system': 'Modificar configuración del sistema',
      'intent_install_unknown': 'Instalar apps desconocidas',
      'intent_do_not_disturb': 'Acceso a No molestar',
      'intent_locale': 'Idioma y región',
      'intent_all_apps': 'Todas las aplicaciones',
      'intent_wifi': 'Configuración de WiFi',
      'intent_bluetooth': 'Configuración de Bluetooth',
      'intent_date_time': 'Fecha y hora',
      'intent_display': 'Configuración de pantalla',
      'intent_accessibility': 'Configuración de accesibilidad',
      'intent_about_device': 'Acerca del dispositivo',
      'intent_notifications': 'Configuración de notificaciones',
      'intent_default_apps': 'Apps predeterminadas',
      'intent_sound': 'Configuración de sonido',
      'intent_storage': 'Configuración de almacenamiento',
      'intent_battery': 'Batería y ahorro de energía',
      'intent_location': 'Servicios de ubicación',
      'intent_security': 'Configuración de seguridad',
      'intent_privacy': 'Configuración de privacidad',
      'intent_nfc': 'Configuración de NFC',
      'intent_accounts': 'Cuentas y sincronización',
      'intent_search': 'Configuración de búsqueda',
      'intent_system_update': 'Actualización del sistema',
      'intent_biometric': 'Inscripción biométrica',
      'intent_cast': 'Configuración de transmisión',
      'intent_webview': 'Implementación de WebView',
    },
    'fr': {
      // Navigation & Menu
      'misc': 'Divers',
      'android': 'Android',
      'ios': 'iOS',
      'settings': 'Paramètres',
      
      // Page Names
      'device_info': 'Informations sur l\'appareil',
      'intent_actions': 'Actions Intent',
      'test_deep_link': 'Tester le lien profond',
      'android_os_distribution': 'Distribution Android OS',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'Distribution iOS',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': 'Général',
      'default_start_page': 'Page de démarrage par défaut',
      'none_first_page': 'Aucune (Première page)',
      'about': 'À propos',
      'about_app': 'À propos de l\'application',
      'default_page_set_to': 'Page par défaut définie sur',
      
      // Common Actions
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'copy': 'Copier',
      'yes': 'Oui',
      'order_reset_to_default': 'Ordre réinitialisé par défaut',
      
      // Device Info - Basic
      'brand': 'Marque',
      'model': 'Modèle',
      'android_os_name': 'Android',
      'api_level': 'Niveau API',
      'security_patch': 'Correctif de sécurité',
      'developer_options': 'Options développeur',
      'enabled': 'Activé',
      'disabled': 'Désactivé',
      
      // Device Info - Screen
      'screen_size_px': 'Taille d\'écran (px)',
      'screen_size_dp': 'Taille d\'écran (dp)',
      'screen_size_inch': 'Taille d\'écran (pouces)',
      'screen_aspect_ratio': 'Rapport d\'aspect',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': 'Densité d\'écran',
      
      // Device Info - Network
      'ip_address': 'Adresse IP',
      'connectivity': 'Connectivité',
      'network_type': 'Type de réseau',
      'network_subtype': 'Sous-type de réseau',
      'network_state': 'État du réseau',
      'is_roaming': 'En itinérance',
      
      // Device Info - IDs
      'ad_id': 'ID publicitaire',
      'android_id': 'ID Android',
      
      // Device Info - Battery
      'capacity': 'Capacité',
      'health': 'État',
      'charging_status': 'État de charge',
      'temperature': 'Température',
      'battery_level': 'Niveau de batterie',
      
      // Device Info - Storage
      'total_space': 'Espace total',
      'used_space': 'Espace utilisé',
      'available_space': 'Espace disponible',
      
      // Device Info - System
      'device_name': 'Nom de l\'appareil',
      'product': 'Produit',
      'board': 'Carte',
      'hardware': 'Matériel',
      'bootloader': 'Chargeur de démarrage',
      'device_type': 'Type d\'appareil',
      'radio_version': 'Version radio',
      'system_locale': 'Langue système',
      'time_zone': 'Fuseau horaire',
      'supported_abis': 'ABIs pris en charge',
      '64_bit_support': 'Support 64 bits',
      
      // Device Info - CPU/Memory
      'architecture': 'Architecture',
      'core_count': 'Nombre de cœurs',
      'total_memory': 'Mémoire totale',
      'used_memory': 'Mémoire utilisée',
      'available_memory': 'Mémoire disponible',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': 'Paquets tiers utilisés',
      'donate': 'Faire un don',
      'show_interstitial_ad_confirm': 'Êtes-vous sûr d\'afficher une publicité interstitielle?',
      'open_web_link_confirm': 'Êtes-vous sûr d\'ouvrir ce lien web?',
      'dismiss': 'Fermer',
      
      // Distribution Pages
      'cumulative': 'Cumulatif',
      'individual': 'Individuel',
      'last_updated': 'Dernière mise à jour',
      'data_from': 'Données de',
      'oops_something_wrong': 'Oups, quelque chose s\'est mal passé!',
      'retry': 'Réessayer',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': 'Page de paramètres',
      'intent_developer_options': 'Options développeur',
      'intent_app_info': 'Informations et autorisations',
      'intent_usage_access': 'Accès aux statistiques d\'utilisation',
      'intent_display_over_apps': 'Afficher par-dessus d\'autres apps',
      'intent_modify_system': 'Modifier les paramètres système',
      'intent_install_unknown': 'Installer des apps inconnues',
      'intent_do_not_disturb': 'Accès Ne pas déranger',
      'intent_locale': 'Langue et région',
      'intent_all_apps': 'Toutes les applications',
      'intent_wifi': 'Paramètres WiFi',
      'intent_bluetooth': 'Paramètres Bluetooth',
      'intent_date_time': 'Date et heure',
      'intent_display': 'Paramètres d\'affichage',
      'intent_accessibility': 'Paramètres d\'accessibilité',
      'intent_about_device': 'À propos de l\'appareil',
      'intent_notifications': 'Paramètres de notification',
      'intent_default_apps': 'Applications par défaut',
      'intent_sound': 'Paramètres audio',
      'intent_storage': 'Paramètres de stockage',
      'intent_battery': 'Batterie et économie d\'énergie',
      'intent_location': 'Services de localisation',
      'intent_security': 'Paramètres de sécurité',
      'intent_privacy': 'Paramètres de confidentialité',
      'intent_nfc': 'Paramètres NFC',
      'intent_accounts': 'Comptes et synchronisation',
      'intent_search': 'Paramètres de recherche',
      'intent_system_update': 'Mise à jour système',
      'intent_biometric': 'Inscription biométrique',
      'intent_cast': 'Paramètres de diffusion',
      'intent_webview': 'Implémentation WebView',
    },
    'de': {
      // Navigation & Menu
      'misc': 'Sonstiges',
      'android': 'Android',
      'ios': 'iOS',
      'settings': 'Einstellungen',
      
      // Page Names
      'device_info': 'Geräteinformationen',
      'intent_actions': 'Intent-Aktionen',
      'test_deep_link': 'Deep Link testen',
      'android_os_distribution': 'Android OS-Verteilung',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'iOS-Verteilung',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': 'Allgemein',
      'default_start_page': 'Standard-Startseite',
      'none_first_page': 'Keine (Erste Seite)',
      'about': 'Über',
      'about_app': 'Über die App',
      'default_page_set_to': 'Standardseite festgelegt auf',
      
      // Common Actions
      'cancel': 'Abbrechen',
      'confirm': 'Bestätigen',
      'copy': 'Kopieren',
      'yes': 'Ja',
      'order_reset_to_default': 'Reihenfolge auf Standard zurückgesetzt',
      
      // Device Info - Basic
      'brand': 'Marke',
      'model': 'Modell',
      'android_os_name': 'Android',
      'api_level': 'API-Level',
      'security_patch': 'Sicherheitspatch',
      'developer_options': 'Entwickleroptionen',
      'enabled': 'Aktiviert',
      'disabled': 'Deaktiviert',
      
      // Device Info - Screen
      'screen_size_px': 'Bildschirmgröße (px)',
      'screen_size_dp': 'Bildschirmgröße (dp)',
      'screen_size_inch': 'Bildschirmgröße (Zoll)',
      'screen_aspect_ratio': 'Seitenverhältnis',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': 'Bildschirmdichte',
      
      // Device Info - Network
      'ip_address': 'IP-Adresse',
      'connectivity': 'Konnektivität',
      'network_type': 'Netzwerktyp',
      'network_subtype': 'Netzwerk-Subtyp',
      'network_state': 'Netzwerkzustand',
      'is_roaming': 'Roaming',
      
      // Device Info - IDs
      'ad_id': 'Werbe-ID',
      'android_id': 'Android-ID',
      
      // Device Info - Battery
      'capacity': 'Kapazität',
      'health': 'Zustand',
      'charging_status': 'Ladestatus',
      'temperature': 'Temperatur',
      'battery_level': 'Akkustand',
      
      // Device Info - Storage
      'total_space': 'Gesamtspeicher',
      'used_space': 'Verwendeter Speicher',
      'available_space': 'Verfügbarer Speicher',
      
      // Device Info - System
      'device_name': 'Gerätename',
      'product': 'Produkt',
      'board': 'Board',
      'hardware': 'Hardware',
      'bootloader': 'Bootloader',
      'device_type': 'Gerätetyp',
      'radio_version': 'Funkversion',
      'system_locale': 'Systemsprache',
      'time_zone': 'Zeitzone',
      'supported_abis': 'Unterstützte ABIs',
      '64_bit_support': '64-Bit-Unterstützung',
      
      // Device Info - CPU/Memory
      'architecture': 'Architektur',
      'core_count': 'Anzahl der Kerne',
      'total_memory': 'Gesamtspeicher',
      'used_memory': 'Verwendeter Speicher',
      'available_memory': 'Verfügbarer Speicher',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': 'Verwendete Drittanbieter-Pakete',
      'donate': 'Spenden',
      'show_interstitial_ad_confirm': 'Möchten Sie wirklich eine Interstitial-Werbung anzeigen?',
      'open_web_link_confirm': 'Möchten Sie diesen Weblink wirklich öffnen?',
      'dismiss': 'Schließen',
      
      // Distribution Pages
      'cumulative': 'Kumulativ',
      'individual': 'Individuell',
      'last_updated': 'Zuletzt aktualisiert',
      'data_from': 'Daten von',
      'oops_something_wrong': 'Hoppla, etwas ist schief gelaufen!',
      'retry': 'Erneut versuchen',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': 'Einstellungsseite',
      'intent_developer_options': 'Entwickleroptionen',
      'intent_app_info': 'App-Informationen & Berechtigungen',
      'intent_usage_access': 'Nutzungszugriff-Einstellungen',
      'intent_display_over_apps': 'Über anderen Apps anzeigen',
      'intent_modify_system': 'Systemeinstellungen ändern',
      'intent_install_unknown': 'Unbekannte Apps installieren',
      'intent_do_not_disturb': 'Nicht-Stören-Zugriff',
      'intent_locale': 'Sprache & Region',
      'intent_all_apps': 'Alle Anwendungen',
      'intent_wifi': 'WiFi-Einstellungen',
      'intent_bluetooth': 'Bluetooth-Einstellungen',
      'intent_date_time': 'Datum & Uhrzeit',
      'intent_display': 'Anzeigeeinstellungen',
      'intent_accessibility': 'Bedienungshilfen',
      'intent_about_device': 'Über das Gerät',
      'intent_notifications': 'Benachrichtigungseinstellungen',
      'intent_default_apps': 'Standard-Apps',
      'intent_sound': 'Toneinstellungen',
      'intent_storage': 'Speichereinstellungen',
      'intent_battery': 'Akku & Energiesparen',
      'intent_location': 'Standortdienste',
      'intent_security': 'Sicherheitseinstellungen',
      'intent_privacy': 'Datenschutzeinstellungen',
      'intent_nfc': 'NFC-Einstellungen',
      'intent_accounts': 'Konten & Synchronisierung',
      'intent_search': 'Sucheinstellungen',
      'intent_system_update': 'Systemaktualisierung',
      'intent_biometric': 'Biometrische Anmeldung',
      'intent_cast': 'Cast-Einstellungen',
      'intent_webview': 'WebView-Implementierung',
    },
    'ar': {
      // Navigation & Menu
      'misc': 'متنوع',
      'android': 'Android',
      'ios': 'iOS',
      'settings': 'الإعدادات',
      
      // Page Names
      'device_info': 'معلومات الجهاز',
      'intent_actions': 'إجراءات Intent',
      'test_deep_link': 'اختبار الرابط العميق',
      'android_os_distribution': 'توزيع نظام Android',
      'android_os': 'نظام Android',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'توزيع iOS',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': 'عام',
      'default_start_page': 'صفحة البداية الافتراضية',
      'none_first_page': 'لا شيء (الصفحة الأولى)',
      'about': 'حول',
      'about_app': 'حول التطبيق',
      'default_page_set_to': 'تم تعيين الصفحة الافتراضية إلى',
      
      // Common Actions
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'copy': 'نسخ',
      'yes': 'نعم',
      'order_reset_to_default': 'تمت إعادة تعيين الترتيب إلى الافتراضي',
      
      // Device Info - Basic
      'brand': 'العلامة التجارية',
      'model': 'الطراز',
      'android_os_name': 'Android',
      'api_level': 'مستوى API',
      'security_patch': 'تصحيح الأمان',
      'developer_options': 'خيارات المطور',
      'enabled': 'مُفعَّل',
      'disabled': 'معطَّل',
      
      // Device Info - Screen
      'screen_size_px': 'حجم الشاشة (بكسل)',
      'screen_size_dp': 'حجم الشاشة (dp)',
      'screen_size_inch': 'حجم الشاشة (بوصة)',
      'screen_aspect_ratio': 'نسبة العرض إلى الارتفاع',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': 'كثافة الشاشة',
      
      // Device Info - Network
      'ip_address': 'عنوان IP',
      'connectivity': 'الاتصال',
      'network_type': 'نوع الشبكة',
      'network_subtype': 'النوع الفرعي للشبكة',
      'network_state': 'حالة الشبكة',
      'is_roaming': 'التجوال',
      
      // Device Info - IDs
      'ad_id': 'معرف الإعلان',
      'android_id': 'معرف Android',
      
      // Device Info - Battery
      'capacity': 'السعة',
      'health': 'الصحة',
      'charging_status': 'حالة الشحن',
      'temperature': 'درجة الحرارة',
      'battery_level': 'مستوى البطارية',
      
      // Device Info - Storage
      'total_space': 'المساحة الإجمالية',
      'used_space': 'المساحة المستخدمة',
      'available_space': 'المساحة المتاحة',
      
      // Device Info - System
      'device_name': 'اسم الجهاز',
      'product': 'المنتج',
      'board': 'اللوحة',
      'hardware': 'الأجهزة',
      'bootloader': 'محمل الإقلاع',
      'device_type': 'نوع الجهاز',
      'radio_version': 'إصدار الراديو',
      'system_locale': 'لغة النظام',
      'time_zone': 'المنطقة الزمنية',
      'supported_abis': 'ABIs المدعومة',
      '64_bit_support': 'دعم 64 بت',
      
      // Device Info - CPU/Memory
      'architecture': 'البنية',
      'core_count': 'عدد النوى',
      'total_memory': 'الذاكرة الإجمالية',
      'used_memory': 'الذاكرة المستخدمة',
      'available_memory': 'الذاكرة المتاحة',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': 'الحزم الخارجية المستخدمة',
      'donate': 'تبرع',
      'show_interstitial_ad_confirm': 'هل أنت متأكد من عرض إعلان بيني؟',
      'open_web_link_confirm': 'هل أنت متأكد من فتح رابط الويب هذا؟',
      'dismiss': 'إغلاق',
      
      // Distribution Pages
      'cumulative': 'تراكمي',
      'individual': 'فردي',
      'last_updated': 'آخر تحديث',
      'data_from': 'البيانات من',
      'oops_something_wrong': 'عذرًا، حدث خطأ ما!',
      'retry': 'إعادة المحاولة',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': 'صفحة الإعدادات',
      'intent_developer_options': 'خيارات المطور',
      'intent_app_info': 'معلومات التطبيق والأذونات',
      'intent_usage_access': 'إعدادات الوصول للاستخدام',
      'intent_display_over_apps': 'العرض فوق التطبيقات الأخرى',
      'intent_modify_system': 'تعديل إعدادات النظام',
      'intent_install_unknown': 'تثبيت التطبيقات غير المعروفة',
      'intent_do_not_disturb': 'الوصول إلى عدم الإزعاج',
      'intent_locale': 'اللغة والمنطقة',
      'intent_all_apps': 'جميع التطبيقات',
      'intent_wifi': 'إعدادات WiFi',
      'intent_bluetooth': 'إعدادات Bluetooth',
      'intent_date_time': 'التاريخ والوقت',
      'intent_display': 'إعدادات العرض',
      'intent_accessibility': 'إعدادات إمكانية الوصول',
      'intent_about_device': 'حول الجهاز',
      'intent_notifications': 'إعدادات الإشعارات',
      'intent_default_apps': 'التطبيقات الافتراضية',
      'intent_sound': 'إعدادات الصوت',
      'intent_storage': 'إعدادات التخزين',
      'intent_battery': 'البطارية وتوفير الطاقة',
      'intent_location': 'خدمات الموقع',
      'intent_security': 'إعدادات الأمان',
      'intent_privacy': 'إعدادات الخصوصية',
      'intent_nfc': 'إعدادات NFC',
      'intent_accounts': 'الحسابات والمزامنة',
      'intent_search': 'إعدادات البحث',
      'intent_system_update': 'تحديث النظام',
      'intent_biometric': 'التسجيل البيومتري',
      'intent_cast': 'إعدادات البث',
      'intent_webview': 'تنفيذ WebView',
    },
    'pt': {
      // Navigation & Menu
      'misc': 'Diversos',
      'android': 'Android',
      'ios': 'iOS',
      'settings': 'Configurações',
      
      // Page Names
      'device_info': 'Informações do dispositivo',
      'intent_actions': 'Ações de Intent',
      'test_deep_link': 'Testar deep link',
      'android_os_distribution': 'Distribuição do Android OS',
      'android_os': 'Android OS',
      'android_wear_os': 'Android WearOS',
      'ios_distribution': 'Distribuição do iOS',
      'ios_title': 'iOS',
      'ipados': 'iPadOS',
      'tvos': 'tvOS',
      'watchos': 'watchOS',
      'macos': 'macOS',
      
      // Settings Page
      'general': 'Geral',
      'default_start_page': 'Página inicial padrão',
      'none_first_page': 'Nenhuma (Primeira página)',
      'about': 'Sobre',
      'about_app': 'Sobre o aplicativo',
      'default_page_set_to': 'Página padrão definida para',
      
      // Common Actions
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'copy': 'Copiar',
      'yes': 'Sim',
      'order_reset_to_default': 'Ordem redefinida para padrão',
      
      // Device Info - Basic
      'brand': 'Marca',
      'model': 'Modelo',
      'android_os_name': 'Android',
      'api_level': 'Nível da API',
      'security_patch': 'Patch de segurança',
      'developer_options': 'Opções do desenvolvedor',
      'enabled': 'Ativado',
      'disabled': 'Desativado',
      
      // Device Info - Screen
      'screen_size_px': 'Tamanho da tela (px)',
      'screen_size_dp': 'Tamanho da tela (dp)',
      'screen_size_inch': 'Tamanho da tela (polegadas)',
      'screen_aspect_ratio': 'Proporção da tela',
      'xdpi': 'xdpi',
      'ydpi': 'ydpi',
      'screen_density': 'Densidade da tela',
      
      // Device Info - Network
      'ip_address': 'Endereço IP',
      'connectivity': 'Conectividade',
      'network_type': 'Tipo de rede',
      'network_subtype': 'Subtipo de rede',
      'network_state': 'Estado da rede',
      'is_roaming': 'Em roaming',
      
      // Device Info - IDs
      'ad_id': 'ID do anúncio',
      'android_id': 'ID do Android',
      
      // Device Info - Battery
      'capacity': 'Capacidade',
      'health': 'Saúde',
      'charging_status': 'Status de carregamento',
      'temperature': 'Temperatura',
      'battery_level': 'Nível da bateria',
      
      // Device Info - Storage
      'total_space': 'Espaço total',
      'used_space': 'Espaço usado',
      'available_space': 'Espaço disponível',
      
      // Device Info - System
      'device_name': 'Nome do dispositivo',
      'product': 'Produto',
      'board': 'Placa',
      'hardware': 'Hardware',
      'bootloader': 'Bootloader',
      'device_type': 'Tipo de dispositivo',
      'radio_version': 'Versão do rádio',
      'system_locale': 'Idioma do sistema',
      'time_zone': 'Fuso horário',
      'supported_abis': 'ABIs suportadas',
      '64_bit_support': 'Suporte a 64 bits',
      
      // Device Info - CPU/Memory
      'architecture': 'Arquitetura',
      'core_count': 'Número de núcleos',
      'total_memory': 'Memória total',
      'used_memory': 'Memória usada',
      'available_memory': 'Memória disponível',
      
      // App Info
      'github': 'Github',
      'used_third_party_packages': 'Pacotes de terceiros usados',
      'donate': 'Doar',
      'show_interstitial_ad_confirm': 'Tem certeza de que deseja exibir um anúncio intersticial?',
      'open_web_link_confirm': 'Tem certeza de que deseja abrir este link da web?',
      'dismiss': 'Fechar',
      
      // Distribution Pages
      'cumulative': 'Cumulativo',
      'individual': 'Individual',
      'last_updated': 'Última atualização',
      'data_from': 'Dados de',
      'oops_something_wrong': 'Ops, algo deu errado!',
      'retry': 'Tentar novamente',

      // Bluetooth Audio
      'bluetooth_audio': 'Bluetooth Audio',
      'bluetooth_not_supported': 'Not Supported',
      'bluetooth_permission_required': 'Bluetooth Permission Required',
      'bluetooth_permission_denied': 'Please grant Bluetooth permission to view device information.',
      'bluetooth_permission_permanently_denied': 'Bluetooth permission was denied. Please enable it in Settings.',
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'bluetooth_disabled_hint': 'Please enable Bluetooth to view connected device information.',
      'no_bluetooth_device': 'No Bluetooth Audio Device',
      'no_bluetooth_device_hint': 'Please connect a Bluetooth headphone or speaker to view its information.',
      'request_permission': 'Request Permission',
      'open_settings': 'Open Settings',
      'error': 'Error',
      'mac_address': 'MAC Address',
      'bluetooth_version': 'Bluetooth Version',
      'codec_info': 'Codec Information',
      'codec_type': 'Codec Type',
      'sample_rate': 'Sample Rate',
      'bits_per_sample': 'Bits Per Sample',
      'channel_mode': 'Channel Mode',
      'bitrate': 'Bitrate',

      // Intent Actions
      'intent_settings': 'Página de configurações',
      'intent_developer_options': 'Opções do desenvolvedor',
      'intent_app_info': 'Informações e permissões do app',
      'intent_usage_access': 'Configurações de acesso de uso',
      'intent_display_over_apps': 'Exibir sobre outros apps',
      'intent_modify_system': 'Modificar configurações do sistema',
      'intent_install_unknown': 'Instalar apps desconhecidos',
      'intent_do_not_disturb': 'Acesso ao Não perturbe',
      'intent_locale': 'Idioma e região',
      'intent_all_apps': 'Todos os aplicativos',
      'intent_wifi': 'Configurações de WiFi',
      'intent_bluetooth': 'Configurações de Bluetooth',
      'intent_date_time': 'Data e hora',
      'intent_display': 'Configurações de tela',
      'intent_accessibility': 'Configurações de acessibilidade',
      'intent_about_device': 'Sobre o dispositivo',
      'intent_notifications': 'Configurações de notificação',
      'intent_default_apps': 'Apps padrão',
      'intent_sound': 'Configurações de som',
      'intent_storage': 'Configurações de armazenamento',
      'intent_battery': 'Bateria e economia de energia',
      'intent_location': 'Serviços de localização',
      'intent_security': 'Configurações de segurança',
      'intent_privacy': 'Configurações de privacidade',
      'intent_nfc': 'Configurações de NFC',
      'intent_accounts': 'Contas e sincronização',
      'intent_search': 'Configurações de pesquisa',
      'intent_system_update': 'Atualização do sistema',
      'intent_biometric': 'Cadastro biométrico',
      'intent_cast': 'Configurações de transmissão',
      'intent_webview': 'Implementação de WebView',
    },
  };

  String get misc => _localizedValues[locale.toString()]!['misc']!;
  String get android => _localizedValues[locale.toString()]!['android']!;
  String get ios => _localizedValues[locale.toString()]!['ios']!;
  String get settings => _localizedValues[locale.toString()]!['settings']!;
  
  String get deviceInfo => _localizedValues[locale.toString()]!['device_info']!;
  String get intentActions => _localizedValues[locale.toString()]!['intent_actions']!;
  String get testDeepLink => _localizedValues[locale.toString()]!['test_deep_link']!;
  String get androidOsDistribution => _localizedValues[locale.toString()]!['android_os_distribution']!;
  String get androidOs => _localizedValues[locale.toString()]!['android_os']!;
  String get androidWearOs => _localizedValues[locale.toString()]!['android_wear_os']!;
  String get iosDistribution => _localizedValues[locale.toString()]!['ios_distribution']!;
  String get iosTitle => _localizedValues[locale.toString()]!['ios_title']!;
  String get ipados => _localizedValues[locale.toString()]!['ipados']!;
  String get tvos => _localizedValues[locale.toString()]!['tvos']!;
  String get watchos => _localizedValues[locale.toString()]!['watchos']!;
  String get macos => _localizedValues[locale.toString()]!['macos']!;
  
  String get general => _localizedValues[locale.toString()]!['general']!;
  String get defaultStartPage => _localizedValues[locale.toString()]!['default_start_page']!;
  String get noneFirstPage => _localizedValues[locale.toString()]!['none_first_page']!;
  String get about => _localizedValues[locale.toString()]!['about']!;
  String get aboutApp => _localizedValues[locale.toString()]!['about_app']!;
  String get defaultPageSetTo => _localizedValues[locale.toString()]!['default_page_set_to']!;
  
  String get cancel => _localizedValues[locale.toString()]!['cancel']!;
  String get confirm => _localizedValues[locale.toString()]!['confirm']!;
  String get copy => _localizedValues[locale.toString()]!['copy']!;
  String get yes => _localizedValues[locale.toString()]!['yes']!;
  String get orderResetToDefault => _localizedValues[locale.toString()]!['order_reset_to_default']!;
  
  String get brand => _localizedValues[locale.toString()]!['brand']!;
  String get model => _localizedValues[locale.toString()]!['model']!;
  String get androidOsName => _localizedValues[locale.toString()]!['android_os_name']!;
  String get apiLevel => _localizedValues[locale.toString()]!['api_level']!;
  String get securityPatch => _localizedValues[locale.toString()]!['security_patch']!;
  String get developerOptions => _localizedValues[locale.toString()]!['developer_options']!;
  String get enabled => _localizedValues[locale.toString()]!['enabled']!;
  String get disabled => _localizedValues[locale.toString()]!['disabled']!;
  
  String get screenSizePx => _localizedValues[locale.toString()]!['screen_size_px']!;
  String get screenSizeDp => _localizedValues[locale.toString()]!['screen_size_dp']!;
  String get screenSizeInch => _localizedValues[locale.toString()]!['screen_size_inch']!;
  String get screenAspectRatio => _localizedValues[locale.toString()]!['screen_aspect_ratio']!;
  String get xdpi => _localizedValues[locale.toString()]!['xdpi']!;
  String get ydpi => _localizedValues[locale.toString()]!['ydpi']!;
  String get screenDensity => _localizedValues[locale.toString()]!['screen_density']!;
  
  String get ipAddress => _localizedValues[locale.toString()]!['ip_address']!;
  String get connectivity => _localizedValues[locale.toString()]!['connectivity']!;
  String get networkType => _localizedValues[locale.toString()]!['network_type']!;
  String get networkSubtype => _localizedValues[locale.toString()]!['network_subtype']!;
  String get networkState => _localizedValues[locale.toString()]!['network_state']!;
  String get isRoaming => _localizedValues[locale.toString()]!['is_roaming']!;
  
  String get adId => _localizedValues[locale.toString()]!['ad_id']!;
  String get androidId => _localizedValues[locale.toString()]!['android_id']!;
  
  String get capacity => _localizedValues[locale.toString()]!['capacity']!;
  String get health => _localizedValues[locale.toString()]!['health']!;
  String get chargingStatus => _localizedValues[locale.toString()]!['charging_status']!;
  String get temperature => _localizedValues[locale.toString()]!['temperature']!;
  String get batteryLevel => _localizedValues[locale.toString()]!['battery_level']!;
  
  String get totalSpace => _localizedValues[locale.toString()]!['total_space']!;
  String get usedSpace => _localizedValues[locale.toString()]!['used_space']!;
  String get availableSpace => _localizedValues[locale.toString()]!['available_space']!;
  
  String get deviceName => _localizedValues[locale.toString()]!['device_name']!;
  String get product => _localizedValues[locale.toString()]!['product']!;
  String get board => _localizedValues[locale.toString()]!['board']!;
  String get hardware => _localizedValues[locale.toString()]!['hardware']!;
  String get bootloader => _localizedValues[locale.toString()]!['bootloader']!;
  String get deviceType => _localizedValues[locale.toString()]!['device_type']!;
  String get radioVersion => _localizedValues[locale.toString()]!['radio_version']!;
  String get systemLocale => _localizedValues[locale.toString()]!['system_locale']!;
  String get timeZone => _localizedValues[locale.toString()]!['time_zone']!;
  String get supportedAbis => _localizedValues[locale.toString()]!['supported_abis']!;
  String get support64Bit => _localizedValues[locale.toString()]!['64_bit_support']!;
  
  String get architecture => _localizedValues[locale.toString()]!['architecture']!;
  String get coreCount => _localizedValues[locale.toString()]!['core_count']!;
  String get totalMemory => _localizedValues[locale.toString()]!['total_memory']!;
  String get usedMemory => _localizedValues[locale.toString()]!['used_memory']!;
  String get availableMemory => _localizedValues[locale.toString()]!['available_memory']!;
  
  String get github => _localizedValues[locale.toString()]!['github']!;
  String get usedThirdPartyPackages => _localizedValues[locale.toString()]!['used_third_party_packages']!;
  String get donate => _localizedValues[locale.toString()]!['donate']!;
  String get showInterstitialAdConfirm => _localizedValues[locale.toString()]!['show_interstitial_ad_confirm']!;
  String get openWebLinkConfirm => _localizedValues[locale.toString()]!['open_web_link_confirm']!;
  String get dismiss => _localizedValues[locale.toString()]!['dismiss']!;
  
  String get cumulative => _localizedValues[locale.toString()]!['cumulative']!;
  String get individual => _localizedValues[locale.toString()]!['individual']!;
  String get lastUpdated => _localizedValues[locale.toString()]!['last_updated']!;
  String get dataFrom => _localizedValues[locale.toString()]!['data_from']!;
  String get oopsSomethingWrong => _localizedValues[locale.toString()]!['oops_something_wrong']!;
  String get retry => _localizedValues[locale.toString()]!['retry']!;

  // Bluetooth Audio
  String get bluetoothAudio => _localizedValues[locale.toString()]!['bluetooth_audio']!;
  String get bluetoothNotSupported => _localizedValues[locale.toString()]!['bluetooth_not_supported']!;
  String get bluetoothPermissionRequired => _localizedValues[locale.toString()]!['bluetooth_permission_required']!;
  String get bluetoothPermissionDenied => _localizedValues[locale.toString()]!['bluetooth_permission_denied']!;
  String get bluetoothPermissionPermanentlyDenied => _localizedValues[locale.toString()]!['bluetooth_permission_permanently_denied']!;
  String get bluetoothDisabled => _localizedValues[locale.toString()]!['bluetooth_disabled']!;
  String get bluetoothDisabledHint => _localizedValues[locale.toString()]!['bluetooth_disabled_hint']!;
  String get noBluetoothDevice => _localizedValues[locale.toString()]!['no_bluetooth_device']!;
  String get noBluetoothDeviceHint => _localizedValues[locale.toString()]!['no_bluetooth_device_hint']!;
  String get requestPermission => _localizedValues[locale.toString()]!['request_permission']!;
  String get openSettings => _localizedValues[locale.toString()]!['open_settings']!;
  String get error => _localizedValues[locale.toString()]!['error']!;
  String get macAddress => _localizedValues[locale.toString()]!['mac_address']!;
  String get bluetoothVersion => _localizedValues[locale.toString()]!['bluetooth_version']!;
  String get codecInfo => _localizedValues[locale.toString()]!['codec_info']!;
  String get codecType => _localizedValues[locale.toString()]!['codec_type']!;
  String get sampleRate => _localizedValues[locale.toString()]!['sample_rate']!;
  String get bitsPerSample => _localizedValues[locale.toString()]!['bits_per_sample']!;
  String get channelMode => _localizedValues[locale.toString()]!['channel_mode']!;
  String get bitrate => _localizedValues[locale.toString()]!['bitrate']!;

  // Intent Actions
  String get intentSettings => _localizedValues[locale.toString()]!['intent_settings']!;
  String get intentDeveloperOptions => _localizedValues[locale.toString()]!['intent_developer_options']!;
  String get intentAppInfo => _localizedValues[locale.toString()]!['intent_app_info']!;
  String get intentUsageAccess => _localizedValues[locale.toString()]!['intent_usage_access']!;
  String get intentDisplayOverApps => _localizedValues[locale.toString()]!['intent_display_over_apps']!;
  String get intentModifySystem => _localizedValues[locale.toString()]!['intent_modify_system']!;
  String get intentInstallUnknown => _localizedValues[locale.toString()]!['intent_install_unknown']!;
  String get intentDoNotDisturb => _localizedValues[locale.toString()]!['intent_do_not_disturb']!;
  String get intentLocale => _localizedValues[locale.toString()]!['intent_locale']!;
  String get intentAllApps => _localizedValues[locale.toString()]!['intent_all_apps']!;
  String get intentWifi => _localizedValues[locale.toString()]!['intent_wifi']!;
  String get intentBluetooth => _localizedValues[locale.toString()]!['intent_bluetooth']!;
  String get intentDateTime => _localizedValues[locale.toString()]!['intent_date_time']!;
  String get intentDisplay => _localizedValues[locale.toString()]!['intent_display']!;
  String get intentAccessibility => _localizedValues[locale.toString()]!['intent_accessibility']!;
  String get intentAboutDevice => _localizedValues[locale.toString()]!['intent_about_device']!;
  String get intentNotifications => _localizedValues[locale.toString()]!['intent_notifications']!;
  String get intentDefaultApps => _localizedValues[locale.toString()]!['intent_default_apps']!;
  String get intentSound => _localizedValues[locale.toString()]!['intent_sound']!;
  String get intentStorage => _localizedValues[locale.toString()]!['intent_storage']!;
  String get intentBattery => _localizedValues[locale.toString()]!['intent_battery']!;
  String get intentLocation => _localizedValues[locale.toString()]!['intent_location']!;
  String get intentSecurity => _localizedValues[locale.toString()]!['intent_security']!;
  String get intentPrivacy => _localizedValues[locale.toString()]!['intent_privacy']!;
  String get intentNfc => _localizedValues[locale.toString()]!['intent_nfc']!;
  String get intentAccounts => _localizedValues[locale.toString()]!['intent_accounts']!;
  String get intentSearch => _localizedValues[locale.toString()]!['intent_search']!;
  String get intentSystemUpdate => _localizedValues[locale.toString()]!['intent_system_update']!;
  String get intentBiometric => _localizedValues[locale.toString()]!['intent_biometric']!;
  String get intentCast => _localizedValues[locale.toString()]!['intent_cast']!;
  String get intentWebview => _localizedValues[locale.toString()]!['intent_webview']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en', 'zh', 'ja', 'ko', 'es', 'fr', 'de', 'ar', 'pt', 'ru',
      'it', 'nl', 'sv', 'no', 'da', 'fi', 'th', 'vi', 'id', 'ms',
      'hi', 'tr', 'pl'
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
