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
