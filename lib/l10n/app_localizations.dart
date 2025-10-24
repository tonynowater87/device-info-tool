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
      'oops_something_wrong': '糟糕，發生錯誤！',
      'retry': '重試',
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
