# Architecture

**Analysis Date:** 2026-02-08

## Pattern Overview

**Overall:** Clean Architecture with BLoC pattern (Business Logic Component) for state management

**Key Characteristics:**
- Separation of concerns across data, business logic (Cubit), and presentation (View) layers
- Reactive state management using Flutter BLoC library
- Dependency injection using MultiRepositoryProvider at app root
- Multi-platform support (Android, iOS, and variants: Wear OS, tvOS, watchOS, macOS)
- Network data abstraction with injectable NetworkProvider implementations

## Layers

**Data Layer:**
- Purpose: Handles all data sources - network fetching, local database, device info, and shared preferences
- Location: `lib/data/`
- Contains: Provider abstractions (NetworkProvider, DeviceVersionProvider, AppVersionProvider, DatabaseProvider), model classes, and implementation classes
- Depends on: External packages (http, sqflite, device_info_plus, shared_preferences)
- Used by: Cubit/business logic layer

**Business Logic Layer (Cubit):**
- Purpose: Manages state transitions and application logic using Flutter BLoC pattern
- Location: `lib/view/[feature]/[feature]_cubit.dart` and `lib/view/[feature]/[feature]_state.dart`
- Contains: Cubit classes that emit states, state classes (initial, success, failure)
- Depends on: Data layer providers
- Used by: Presentation layer (Pages/Widgets)

**Presentation Layer (View):**
- Purpose: Renders UI and handles user interactions
- Location: `lib/view/`
- Contains: Page widgets (StatefulWidget), reusable UI components (cells, dialogs, tiles), custom widgets
- Depends on: Cubit layer for state, common utilities and extensions
- Used by: Material app routing and navigation

**Common Layer:**
- Purpose: Shared utilities, extensions, dialogs, and reusable components
- Location: `lib/common/`
- Contains: String extensions, utility functions, dialog builders, custom tiles, miscellaneous helpers
- Depends on: Flutter and localization packages
- Used by: All layers

## Data Flow

**OS Version Display Flow:**

1. User navigates to Android Version page (view)
2. AndroidVersionPage widget initializes AndroidVersionPageCubit in BlocProvider
3. Page calls cubit.load() on initState
4. Cubit calls networkProvider.getAndroidVersions() and deviceVersionProvider.getOSVersion()
5. NetworkProviderGithub fetches JSON from GitHub raw content and deserializes to VersionModelAndroid list
6. Cubit sorts versions by API level (descending) and finds current device version index
7. Cubit emits AndroidVersionPageSuccess state with data and highlight index
8. Widget watches state and rebuilds ScrollablePositionedList with version cells
9. List auto-scrolls to highlight current device version

**Deep Link Handling Flow:**

1. User enters deep link URL in intentional testing page
2. DeepLinkPage stores URL in DatabaseProvider (SQLite)
3. DeepLinkCubit queries stored URLs from database
4. Page displays list of saved URLs for testing intent actions

**State Management:**
- Each screen feature has dedicated Cubit (AndroidVersionPageCubit, IosVersionPageCubit, etc.)
- Cubits manage both loading states (Initial) and result states (Success, Failure)
- Pages watch Cubit state using context.watch<CubitType>() and rebuild on emission
- Multiple instances of same Cubit for different device types (iPhone, iPad, tvOS, etc.) share logic but maintain separate state

## Key Abstractions

**NetworkProvider (Abstract):**
- Purpose: Abstracts network data source - allows swapping between GitHub live data and debug mock data
- Examples: `lib/data/NetworkProvider.dart`, `lib/data/NetworkProviderGithub.dart`, `lib/data/NetworkProviderDebug.dart`
- Pattern: Strategy pattern with abstract interface, concrete implementations for different data sources

**DeviceVersionProvider (Abstract):**
- Purpose: Gets current device's OS version and device type
- Examples: `lib/data/DeviceVersionProvider.dart`, `lib/data/DeviceVersionProviderImpl.dart`
- Pattern: Abstract provider pattern, uses device_info_plus package for platform-specific queries

**DatabaseProvider (Abstract):**
- Purpose: Encapsulates SQLite database operations for URL records
- Examples: `lib/data/database_provider.dart`
- Pattern: Abstract DAO pattern, provides insert, delete, query operations on url_record table

**Cubit State Pattern:**
- Purpose: Represents discrete states during async operations
- Pattern: Each feature has State base class and concrete states (Initial, Success, Failure)
- Location: Defined as part of Cubit file using Dart part directive

## Entry Points

**App Entry Point:**
- Location: `lib/main.dart`
- Triggers: Flutter framework on app launch
- Responsibilities:
  - Firebase and mobile ads initialization
  - System chrome configuration (edge-to-edge mode, transparent bars)
  - Crash reporting setup with Firebase Crashlytics
  - Repository provider setup for dependency injection
  - Theme setup with EasyDynamicTheme
  - Localization configuration

**Root Widget:**
- Location: `lib/main.dart` - MyApp class (StatefulWidget)
- Triggers: Rendered as home in MaterialApp
- Responsibilities:
  - Manages tab navigation between 12 screens (Android) or 7 screens (iOS)
  - Loads and applies saved default page preference
  - Builds drawer navigation with platform-specific menu items
  - Handles app bar actions (e.g., Reset Order button for intent actions)
  - Manages banner ad display (hidden in debug mode)

## Error Handling

**Strategy:** Each Cubit has dedicated Failure state emitted on exception

**Patterns:**
- Try-catch in Cubit load() methods catching all exceptions and emitting Failure state
- Pages check for Failure state and display user-friendly error UI with retry button
- Database operations return empty lists on error rather than throwing
- Network errors (no internet, parse errors) caught and wrapped in Failure state

**Firebase Crashlytics Integration:**
- All Flutter framework errors routed to Crashlytics via FlutterError.onError
- All uncaught async errors routed via PlatformDispatcher.instance.onError
- Allows remote monitoring of production crashes

## Cross-Cutting Concerns

**Logging:**
- Uses debugPrint() for debug-only logging
- Database operations log with [DB-*] prefix (e.g., [DB-QUERY], [DB-INSERT])
- Firebase Crashlytics logs all exceptions

**Validation:**
- Version comparison via String extension compareVersion() in `lib/common/string_extensions.dart`
- API level parsing with int.tryParse() with fallback value 1000 for invalid levels
- URL record deduplication in database (insertOrUpdate logic)

**Localization:**
- Generated localization delegates from `lib/l10n/app_localizations.dart`
- Page names and UI strings retrieved via AppLocalizations.of(context) pattern
- Supports multiple locales defined in supportedLocales

**Theming:**
- Light and dark themes defined in `lib/theme.dart`
- Theme switching via EasyDynamicTheme package
- Text scale factor clamped to 1.0 to prevent UI overflow

**Platform-Specific Behavior:**
- Platform.isAndroid and Platform.isIOS checks determine which screens are available
- Android shows 12 screens, iOS shows 7 screens
- Device type detection via DeviceVersionProvider.getDeviceType()
- Intent action button visibility limited to Android
- Deep link testing limited to Android (DeepLinkPage)

---

*Architecture analysis: 2026-02-08*
