# Codebase Structure

**Analysis Date:** 2026-02-08

## Directory Layout

```
lib/
├── main.dart                    # App entry point, MyApp root widget, tab controller
├── theme.dart                   # Light/dark theme definitions
├── constants.dart               # Ad unit IDs and environment-based configurations
├── firebase_options.dart        # Firebase platform configuration (generated)
├── oss_licenses.dart            # Open source license declarations (generated)
├── common/                      # Shared utilities and reusable components
│   ├── dialogs.dart             # Dialog builders
│   ├── drawer_tile.dart         # Reusable navigation drawer tile
│   ├── drawer_divider_tile.dart # Drawer section divider
│   ├── miscellaneous.dart       # Miscellaneous utilities
│   ├── string_extensions.dart   # String extension methods (version comparison)
│   └── utils.dart               # Utility functions (ratio calculation, formatting)
├── data/                        # Data layer - providers and models
│   ├── NetworkProvider.dart                    # Abstract network data provider interface
│   ├── NetworkProviderGithub.dart              # Concrete implementation fetching from GitHub
│   ├── NetworkProviderDebug.dart               # Mock implementation for testing
│   ├── DeviceVersionProvider.dart              # Abstract device info provider interface
│   ├── DeviceVersionProviderImpl.dart           # Concrete device info implementation
│   ├── AppVersionProvider.dart                 # Abstract app version provider interface
│   ├── AppVersionProviderImpl.dart              # Concrete app version implementation
│   ├── database_provider.dart                  # Abstract SQLite database provider interface and implementation
│   ├── default_page_provider.dart              # SharedPreferences-based default page persistence
│   ├── intent_order_provider.dart              # Intent action button order persistence
│   └── model/                                  # Data models
│       ├── VersionModelAndroid.dart            # Android OS version model
│       ├── VersionModelAndroidWearOS.dart      # Wear OS version model
│       ├── VersionModeliOS.dart                # iOS/iPadOS/tvOS/watchOS version model
│       ├── VersionModelTvOS.dart               # tvOS-specific version model
│       ├── VersionModelWatchOS.dart            # watchOS-specific version model
│       ├── VesionModelMacOS.dart               # macOS version model (note: typo in name)
│       ├── MobileDistribution.dart             # Market share distribution data
│       └── url_record.dart                     # Deep link URL record model
├── l10n/                        # Localization (generated)
│   └── app_localizations.dart   # Generated localization delegate
├── view/                        # Presentation layer - pages and UI components
│   ├── ad/                                     # Google Mobile Ads integration
│   │   ├── banner_ad_state.dart                # Banner ad state class
│   │   ├── banner_ad_cubit.dart                # Banner ad Cubit
│   │   └── banner_page.dart                    # Banner ad display widget
│   ├── android/                                # Android OS version display
│   │   ├── android_version_page.dart           # Android version list page
│   │   ├── android_version_page_cubit.dart     # Android version Cubit with sorting/filtering logic
│   │   └── android_version_page_state.dart     # Android version state classes
│   ├── androiddeviceinfo/                      # Android device info display
│   │   ├── android_device_info_page.dart
│   │   ├── android_device_info_cubit.dart
│   │   ├── android_device_info_state.dart
│   │   └── android_device_info_model.dart      # UI-specific model for device info display
│   ├── androiddistribution/                    # Android market share distribution
│   │   ├── android_distribution_page.dart
│   │   ├── android_distribution_cubit.dart
│   │   ├── android_distribution_state.dart
│   │   └── chart_type.dart                     # Enum for chart visualization types
│   ├── appinfo/                                # App version and build info
│   │   ├── appinfo_page.dart
│   │   ├── appinfo_cubit.dart
│   │   └── appinfo_state.dart
│   ├── cell/                                   # Reusable list item cells
│   │   ├── cell_android.dart                   # Android version list item
│   │   ├── cell_android_wear_os.dart           # Wear OS version list item
│   │   └── cell_ios.dart                       # iOS version list item
│   ├── deeplink/                               # Deep link testing (Android only)
│   │   ├── deep_link_page.dart
│   │   ├── deep_link_cubit.dart
│   │   ├── deep_link_state.dart
│   │   └── deep_link_cell_view.dart            # URL record list item
│   ├── intentbuttons/                          # Intent action launcher (Android only)
│   │   ├── intent_buttons_page.dart
│   │   ├── action_buttons_view.dart            # Grid of intent action buttons
│   │   └── intent_action_model.dart            # Intent action data model
│   ├── ios/                                    # iOS/iPadOS/tvOS/watchOS version display
│   │   ├── ios_version_page.dart               # Unified iOS variant page
│   │   ├── ios_version_page_cubit.dart         # iOS version Cubit
│   │   ├── ios_version_page_state.dart         # iOS version state classes
│   │   └── ui_model_ios.dart                   # iOS page UI model with device type
│   ├── iosdeviceinfo/                          # iOS device info display
│   │   ├── ios_device_info_page.dart
│   │   ├── ios_device_info_cubit.dart
│   │   └── ios_device_info_state.dart
│   ├── iosdistribution/                        # iOS market share distribution
│   │   ├── ios_distribution_page.dart
│   │   ├── ios_distribution_cubit.dart
│   │   └── ios_distribution_state.dart
│   ├── settings/                               # Settings page for default page preference
│   │   └── settings_page.dart
│   └── wearOS/                                 # Android Wear OS version display
│       ├── android_wear_os_version_page.dart
│       ├── android_wear_os_version_page_cubit.dart
│       └── android_wear_os_version_page_state.dart
└── l10n/                        # Localization resources (not shown - auto-generated)

test/
├── db_test.dart                 # SQLite database provider tests
├── utils_test.dart              # Utility function tests
├── version_comparing_test.dart   # Version comparison string extension tests
├── regex_test.dart              # Regular expression tests
└── widget_test.dart             # Widget integration tests
```

## Directory Purposes

**lib/common/:**
- Purpose: Shared utilities, extensions, and reusable UI components
- Contains: String manipulation, dialog builders, custom drawer tiles, utility math/formatting functions
- Key files: `string_extensions.dart` for version comparison, `utils.dart` for display formatting

**lib/data/:**
- Purpose: Data access layer with abstraction and dependency injection
- Contains: Abstract provider interfaces, concrete implementations, data models
- Key patterns: Abstract interfaces (NetworkProvider, DatabaseProvider) with multiple implementations (GitHub live, Debug mock)

**lib/data/model/:**
- Purpose: Data transfer objects for network responses and local storage
- Contains: Version models for each OS platform, distribution data, URL records
- Pattern: All models have fromJson() constructors, copyWith() methods, toJson() serialization

**lib/view/:**
- Purpose: User interface presentation organized by feature
- Contains: Pages (StatefulWidget), Cubits for business logic, States for state management, reusable cells/widgets
- Structure: Each feature has dedicated subdirectory with page, cubit, state, and feature-specific models

**lib/view/android/ to lib/view/wearOS/:**
- Purpose: Feature-specific pages and logic for different mobile platforms
- Pattern: Each feature has: page.dart (UI), cubit.dart (logic), state.dart (state classes), optional model.dart (UI data)

**lib/view/cell/:**
- Purpose: Reusable list item widgets for displaying version information
- Contains: CellAndroidView, CellAndroidWearOsView, CellIOSView for platform-specific styling

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App initialization, Firebase/ads setup, root widget (MyApp), tab navigation controller
- `lib/l10n/app_localizations.dart`: Localization entry point (generated)

**Configuration:**
- `lib/constants.dart`: Ad unit IDs and environment-based settings
- `lib/theme.dart`: Material design theme definitions (light/dark)
- `lib/firebase_options.dart`: Firebase platform configuration (generated)

**Core Logic:**
- `lib/data/NetworkProvider.dart`: Abstract interface for data fetching
- `lib/data/NetworkProviderGithub.dart`: Live data fetching from GitHub repository
- `lib/data/NetworkProviderDebug.dart`: Mock data for testing (returns hardcoded versions)
- `lib/data/database_provider.dart`: SQLite database operations (CRUD for URL records)
- `lib/common/string_extensions.dart`: Version string comparison logic

**Testing:**
- `test/db_test.dart`: SQLite provider tests with sqflite_common_ffi
- `test/version_comparing_test.dart`: String extension version comparison tests
- `test/utils_test.dart`: Utility function tests (ratio calculation, formatting)

## Naming Conventions

**Files:**
- `[feature]_page.dart`: UI pages (e.g., android_version_page.dart, settings_page.dart)
- `[feature]_cubit.dart`: BLoC state management classes
- `[feature]_state.dart`: State classes for Cubit (or in same file as part)
- `[model_name].dart`: Data models with PascalCase (e.g., VersionModelAndroid.dart)
- `[utility_name].dart`: Utility/helper files with snake_case (e.g., database_provider.dart)

**Classes:**
- `[FeatureName]Page`: UI page widgets (StatefulWidget)
- `[FeatureName]Cubit`: Business logic component classes
- `[FeatureName]State`: Abstract base class for feature states
- `[FeatureName]Success`, `[FeatureName]Failure`, `[FeatureName]Initial`: Concrete state classes
- `VersionModel[OS]`: Version data models (Android, iOS, WearOS, etc.)

**Directories:**
- Feature-specific: lowercase with underscores (e.g., `androiddeviceinfo`, `androiddistribution`)
- Logical groups: lowercase with underscores (e.g., `view`, `data`, `common`, `l10n`)

## Where to Add New Code

**New Feature (e.g., new device version page):**
- Create new directory: `lib/view/[feature_name]/`
- Primary code: `lib/view/[feature_name]/[feature_name]_page.dart` (UI widget)
- Business logic: `lib/view/[feature_name]/[feature_name]_cubit.dart` and `_state.dart`
- Optional model: `lib/view/[feature_name]/[feature_name]_model.dart` if UI-specific data needed
- Tests: `test/[feature_name]_test.dart`

**New Data Provider (e.g., new data source):**
- Abstraction: `lib/data/[ProviderName].dart` (abstract class)
- Concrete: `lib/data/[ProviderNameImpl].dart` (implementation class)
- Register: Add RepositoryProvider in main.dart MultiRepositoryProvider
- Model: Add to `lib/data/model/` if new data type needed

**New Utility/Helper:**
- Shared helpers: `lib/common/[helper_name].dart`
- Extension methods: Add to `lib/common/string_extensions.dart` or create new extension file
- Database operations: Add methods to DatabaseProviderImpl in `lib/data/database_provider.dart`

**New Dialog or Reusable Component:**
- Dialogs: Add to `lib/common/dialogs.dart` or create dedicated file
- Drawer components: Modify `lib/common/drawer_tile.dart` or extend with new variants
- List cells: Add new cell type to `lib/view/cell/cell_[type].dart`

## Special Directories

**lib/l10n/:**
- Purpose: Localization strings and delegates (auto-generated)
- Generated: Yes - via `flutter gen-l10n` from ARB files
- Committed: Yes - generated files are committed to git

**build/:**
- Purpose: Build artifacts and compiled output
- Generated: Yes - created during `flutter build`
- Committed: No - typically in .gitignore

**resources/:**
- Purpose: Version data JSON files (android-os-versions.json, ios-os-versions.json, etc.)
- Generated: No - manually maintained or external source
- Committed: Yes - source data for the app

**android/ and ios/:**
- Purpose: Platform-specific native code and configurations
- Generated: Partially - some files auto-generated during build
- Committed: Yes - native configurations, pods, etc.

---

*Structure analysis: 2026-02-08*
