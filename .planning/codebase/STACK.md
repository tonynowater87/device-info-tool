# Technology Stack

**Analysis Date:** 2026-02-08

## Languages

**Primary:**
- Dart 3.7.0+ - All application logic, BLoC patterns, and data layer
- Kotlin - Android native integration and platform channels
- Swift - iOS native integration and platform channels

**Secondary:**
- JSON - Data serialization for version data and Firebase configuration
- YAML - Configuration (pubspec.yaml, Firebase config)
- HTML/CSS - Web platform support

## Runtime

**Environment:**
- Flutter SDK (beta channel, revision 75927305ff855f76a9ef704f9b4a86fa2fce7292)
- Dart SDK (bundled with Flutter, version 3.7.0+)

**Package Manager:**
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` - Present and maintained

## Frameworks

**Core:**
- Flutter 3.x - UI framework for iOS, Android, and Web
- Flutter BLoC 8.1.2 - State management and business logic separation
- Material Design - UI component library

**Device/Platform Integration:**
- device_info_plus 11.5.0 - Device information access
- package_info_plus 8.3.0 - App version and build information
- android_intent_plus 5.3.0 - Android Intent launching and handling
- network_info_plus 6.1.4 - Network connectivity information
- connectivity_plus 6.1.4 - Network connectivity status monitoring
- android_id 0.3.4 - Android device ID retrieval
- advertising_id 2.7.1 - Advertising identifier access
- flutter_fgbg 0.7.1 - App foreground/background lifecycle detection
- system_info2 3.0.2 - System information utilities
- memory_info 0.0.4 - Memory/RAM information
- display_metrics 0.1.5 - Display metrics and screen information
- url_launcher_android 6.3.16 - URL launching on Android

**Analytics & Crashes:**
- firebase_core 2.11.0 - Firebase initialization
- firebase_crashlytics 3.2.0 - Error tracking and crash reporting

**UI & Presentation:**
- persistent_bottom_nav_bar 5.0.2 - Navigation bar persistence
- easy_dynamic_theme 2.3.1 - Dynamic theme switching
- lottie 3.3.1 - Animation support
- rotated_corner_decoration 2.1.0+1 - Custom UI decorations
- material_dialogs 1.1.5 - Material design dialogs
- fluttertoast - Toast notifications (custom git dependency from ponnamkarthik/FlutterToast)

**Data Display:**
- syncfusion_flutter_charts 30.1.38 - Charts for distribution data visualization

**Data Management:**
- sqflite 2.4.2 - SQLite database for local persistence
- shared_preferences 2.3.3 - Key-value storage
- shared_preferences_android 2.4.10 - Android shared preferences implementation

**Networking:**
- http 1.4.0 - HTTP client for GitHub API requests
- intl - Internationalization support
- cupertino_icons 1.0.2 - iOS-style icons

**Development & Build Tools:**
- flutter_lints 2.0.0 - Lint rules for code quality
- flutter_launcher_icons 0.13.1 - App icon generation
- flutter_oss_licenses 2.0.1 - OSS license tracking and display
- sqflite_common_ffi 2.2.5 - FFI support for sqflite in tests

## Key Dependencies

**Critical:**
- firebase_core 2.11.0 - Essential for crash reporting and analytics
- flutter_bloc 8.1.2 - Core state management pattern
- http 1.4.0 - GitHub API integration for OS version data
- sqflite 2.4.2 - Local database for URL history

**Infrastructure:**
- device_info_plus 11.5.0 - Core device information feature
- firebase_crashlytics 3.2.0 - Production error tracking
- connectivity_plus 6.1.4 - Network status monitoring

## Configuration

**Environment:**
- Firebase project: `mobile-os-versions` (ID: 990464626733)
- Uses FlutterFire CLI generated configuration files
- Configuration file: `lib/firebase_options.dart` (auto-generated)

**Build:**
- Android: `android/app/build.gradle`, `android/build.gradle`
- iOS: `ios/Podfile` (minimum iOS 12.0)
- Flutter: `pubspec.yaml`
- Analysis: `analysis_options.yaml` (uses flutter_lints)

## Platform Requirements

**Development:**
- Dart SDK 3.7.0+
- Flutter SDK (beta channel)
- Android SDK (for Android builds)
- Xcode 12+ (for iOS builds)
- CocoaPods (iOS dependency management)
- Java Development Kit (for Android)

**Production:**
- Android: Minimum API level 21 (Android 5.0)
- iOS: Minimum iOS 12.0
- Web: Standard web deployment via Firebase Hosting
- Firebase project setup (required for crashlytics)

**Data Sources:**
- GitHub raw content API: `https://raw.githubusercontent.com/tonynowater87/mobile-os-versions/main/resources`
  - Provides JSON files for OS version data
  - Files: android-os-versions.json, ios-os-versions.json, ipad-os-versions.json, wear-os-versions.json, mac-os-versions.json, tv-os-versions.json, watch-os-versions.json, android-distribution.json, ios-distribution.json

---

*Stack analysis: 2026-02-08*
