import 'dart:io';

import 'package:device_info_tool/common/drawer_divider_tile.dart';
import 'package:device_info_tool/common/drawer_tile.dart';
import 'package:device_info_tool/data/AppVersionProvider.dart';
import 'package:device_info_tool/data/AppVersionProviderImpl.dart';
import 'package:device_info_tool/data/DeviceVersionProvider.dart';
import 'package:device_info_tool/data/DeviceVersionProviderImpl.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/NetworkProviderDebug.dart';
import 'package:device_info_tool/data/NetworkProviderGithub.dart';
import 'package:device_info_tool/data/database_provider.dart';
import 'package:device_info_tool/firebase_options.dart';
import 'package:device_info_tool/theme.dart';
import 'package:device_info_tool/view/ad/banner_ad_cubit.dart';
import 'package:device_info_tool/view/ad/banner_page.dart';
import 'package:device_info_tool/view/android/android_version_page.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_cubit.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_page.dart';
import 'package:device_info_tool/view/androiddistribution/android_distribution_cubit.dart';
import 'package:device_info_tool/view/androiddistribution/android_distribution_page.dart';
import 'package:device_info_tool/view/appinfo/appinfo_cubit.dart';
import 'package:device_info_tool/view/appinfo/appinfo_page.dart';
import 'package:device_info_tool/view/deeplink/deep_link_cubit.dart';
import 'package:device_info_tool/view/deeplink/deep_link_page.dart';
import 'package:device_info_tool/view/intentbuttons/intent_buttons_page.dart';
import 'package:device_info_tool/view/ios/ios_version_page.dart';
import 'package:device_info_tool/view/ios/ios_version_page_cubit.dart';
import 'package:device_info_tool/view/iosdeviceinfo/ios_device_info_cubit.dart';
import 'package:device_info_tool/view/iosdeviceinfo/ios_device_info_page.dart';
import 'package:device_info_tool/view/iosdistribution/ios_distribution_cubit.dart';
import 'package:device_info_tool/view/iosdistribution/ios_distribution_page.dart';
import 'package:device_info_tool/view/wearOS/android_wear_os_version_page.dart';
import 'package:device_info_tool/view/wearOS/android_wear_os_version_page_cubit.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'view/android/android_version_page_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  MobileAds.instance.initialize().then((value) => {
        MobileAds.instance
          ..setAppMuted(true)
          ..setAppVolume(0.05)
      });
  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider<NetworkProvider>(
          create: (context) => kDebugMode
              ? NetworkProviderDebug()
              : NetworkProviderGithub(httpClient: HttpClient())),
      RepositoryProvider<DeviceVersionProvider>(
          create: (context) => DeviceVersionProviderImpl()),
      RepositoryProvider<AppVersionProvider>(
          create: (context) => AppVersionProviderImpl()),
      RepositoryProvider<DatabaseProvider>(
          create: (context) => DatabaseProviderImpl(isUnitTest: false)),
    ],
    child: EasyDynamicThemeWidget(
      child: Builder(builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightThemeData,
          darkTheme: darkThemeData,
          themeMode: EasyDynamicTheme.of(context).themeMode,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.0);
            return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                child: child!);
          },
          home: const MyApp(),
        );
      }),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String DefaultTitle = 'Device Info Tool';

  late TabController _tabController;
  var bottomNavBarItems = <Widget>[];
  var screens = <Widget>[];
  var currentPageIndex = 0;
  var currentPageTitle = DefaultTitle;

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var androidDeviceInfoScreen = BlocProvider(
        create: (context) => AndroidDeviceInfoCubit(),
        child: const AndroidDeviceInfoPage());

    var androidIntentButtonScreen = IntentButtonsPage();

    var deepLinkScreen = BlocProvider(
        create: (context) => DeepLinkCubit(context.read<DatabaseProvider>()),
        child: const DeepLinkPage());

    var androidScreen = BlocProvider(
      create: (context) => AndroidVersionPageCubit(
          networkProvider: context.read<NetworkProvider>(),
          deviceVersionProvider: context.read<DeviceVersionProvider>()),
      child: const AndroidVersionPage(),
    );
    var androidWearOSScreen = BlocProvider(
      create: (context) => AndroidWearOSVersionPageCubit(
          networkProvider: context.read<NetworkProvider>()),
      child: const AndroidWearOSVersionPage(),
    );

    var iOSScreen = BlocProvider(
      create: (context) => IosVersionPageCubit(
          networkProvider: context.read<NetworkProvider>(),
          deviceVersionProvider: context.read<DeviceVersionProvider>()),
      child: const IOSVersionPage(deviceType: DeviceType.iPhone),
    );
    var iPadOSScreen = BlocProvider(
      create: (context) => IosVersionPageCubit(
          networkProvider: context.read<NetworkProvider>(),
          deviceVersionProvider: context.read<DeviceVersionProvider>()),
      child: const IOSVersionPage(deviceType: DeviceType.iPad),
    );
    var tvOSScreen = BlocProvider(
      create: (context) => IosVersionPageCubit(
          networkProvider: context.read<NetworkProvider>(),
          deviceVersionProvider: context.read<DeviceVersionProvider>()),
      child: const IOSVersionPage(deviceType: DeviceType.appleTv),
    );
    var watchOSScreen = BlocProvider(
      create: (context) => IosVersionPageCubit(
          networkProvider: context.read<NetworkProvider>(),
          deviceVersionProvider: context.read<DeviceVersionProvider>()),
      child: const IOSVersionPage(deviceType: DeviceType.appleWatch),
    );
    var macOSScreen = BlocProvider(
      create: (context) => IosVersionPageCubit(
          networkProvider: context.read<NetworkProvider>(),
          deviceVersionProvider: context.read<DeviceVersionProvider>()),
      child: const IOSVersionPage(deviceType: DeviceType.mac),
    );

    var androidDistributionScreen = BlocProvider(
      create: (context) => AndroidDistributionCubit(
          networkProvider: context.read<NetworkProvider>()),
      child: const AndroidDistributionPage(),
    );

    var iOSDistributionScreen = BlocProvider(
      create: (context) => IosDistributionCubit(
          networkProvider: context.read<NetworkProvider>()),
      child: const IOSDistributionPage(),
    );

    var iOSDeviceInfoScreen = BlocProvider(
      create: (context) => IosDeviceInfoCubit(),
      child: const IosDeviceInfoPage(),
    );

    if (Platform.isAndroid) {
      bottomNavBarItems = [
        const DrawerDividerTile(title: 'Misc'),
        DrawerTile(
            selected: currentPageIndex == 0,
            icon: Image.asset(
              'assets/images/android-device-icon.png',
              fit: BoxFit.contain,
              width: 30,
              height: 30,
            ),
            title: 'Device Info',
            onTap: (title) {
              changePageByIndex(0, title);
            }),
        DrawerTile(
            selected: currentPageIndex == 1,
            icon: const Icon(Icons.open_in_new_rounded),
            title: 'Intent Actions',
            onTap: (title) {
              changePageByIndex(1, title);
            }),
        DrawerTile(
            selected: currentPageIndex == 2,
            icon: const Icon(Icons.link),
            title: 'Test Deep Link',
            onTap: (title) {
              changePageByIndex(2, title);
            }),
        const DrawerDividerTile(title: 'Android'),
        DrawerTile(
            selected: currentPageIndex == 3,
            icon: Image.asset(
              'assets/images/android-device-icon.png',
              fit: BoxFit.contain,
              width: 30,
              height: 30,
            ),
            title: 'Android OS Distribution',
            onTap: (title) {
              changePageByIndex(3, title);
            }),
        DrawerTile(
          selected: currentPageIndex == 4,
          icon: Image.asset(
            'assets/images/android-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'Android OS',
          onTap: (title) {
            changePageByIndex(4, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 5,
          icon: Image.asset(
            'assets/images/smart-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'Android WearOS',
          onTap: (title) {
            changePageByIndex(5, title);
          },
        ),
        const DrawerDividerTile(title: 'iOS'),
        DrawerTile(
            selected: currentPageIndex == 6,
            icon: Image.asset(
              'assets/images/iphone-device-icon.png',
              fit: BoxFit.contain,
              width: 30,
              height: 30,
            ),
            title: 'iOS Distribution',
            onTap: (title) {
              changePageByIndex(6, title);
            }),
        DrawerTile(
          selected: currentPageIndex == 7,
          icon: Image.asset(
            'assets/images/iphone-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'iOS',
          onTap: (title) {
            changePageByIndex(7, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 8,
          icon: Image.asset(
            'assets/images/ipad-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'iPadOS',
          onTap: (title) {
            changePageByIndex(8, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 9,
          icon: Image.asset(
            'assets/images/apple-tv-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'tvOS',
          onTap: (title) {
            changePageByIndex(9, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 10,
          icon: Image.asset(
            'assets/images/apple-watch-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'watchOS',
          onTap: (title) {
            changePageByIndex(10, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 11,
          icon: Image.asset(
            'assets/images/mac-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'macOS',
          onTap: (title) {
            changePageByIndex(11, title);
          },
        ),
      ];
      screens = [
        androidDeviceInfoScreen,
        androidIntentButtonScreen,
        deepLinkScreen,
        androidDistributionScreen,
        androidScreen,
        androidWearOSScreen,
        iOSDistributionScreen,
        iOSScreen,
        iPadOSScreen,
        tvOSScreen,
        watchOSScreen,
        macOSScreen,
      ];
    } else if (Platform.isIOS) {
      // TODO add divider for iOS
      bottomNavBarItems = [
        DrawerTile(
            selected: currentPageIndex == 0,
            icon: Image.asset(
              'assets/images/iphone-device-icon.png',
              fit: BoxFit.contain,
              width: 30,
              height: 30,
            ),
            title: 'Device Info',
            onTap: (title) {
              changePageByIndex(0, title);
            }),
        DrawerTile(
            selected: currentPageIndex == 1,
            icon: Image.asset(
              'assets/images/iphone-device-icon.png',
              fit: BoxFit.contain,
              width: 30,
              height: 30,
            ),
            title: 'iOS Distribution',
            onTap: (title) {
              changePageByIndex(1, title);
            }),
        DrawerTile(
          selected: currentPageIndex == 2,
          icon: Image.asset(
            'assets/images/iphone-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'iOS',
          onTap: (title) {
            changePageByIndex(2, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 3,
          icon: Image.asset(
            'assets/images/ipad-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'iPadOS',
          onTap: (title) {
            changePageByIndex(3, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 4,
          icon: Image.asset(
            'assets/images/apple-tv-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'tvOS',
          onTap: (title) {
            changePageByIndex(4, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 5,
          icon: Image.asset(
            'assets/images/apple-watch-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'watchOS',
          onTap: (title) {
            changePageByIndex(5, title);
          },
        ),
        DrawerTile(
          selected: currentPageIndex == 6,
          icon: Image.asset(
            'assets/images/mac-device-icon.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
          title: 'macOS',
          onTap: (title) {
            changePageByIndex(6, title);
          },
        )
      ];
      screens = [
        iOSDeviceInfoScreen,
        iOSDistributionScreen,
        iOSScreen,
        iPadOSScreen,
        tvOSScreen,
        watchOSScreen,
        macOSScreen,
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPageTitle),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: bottomNavBarItems,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About App'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider(
                            create: (context) => AppInfoCubit(
                                context.read<AppVersionProvider>()),
                            child: const AppInfoPage())));
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                    initialIndex: currentPageIndex,
                    length: screens.length,
                    child: Builder(builder: (context) {
                      _tabController = DefaultTabController.of(context);
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: screens,
                            ),
                          ),
                        ],
                      );
                    }),
                  )),
            ),
            Visibility(
              visible: !kDebugMode,
              child: SizedBox(
                height: 50,
                child: BlocProvider(
                  create: (context) => BannerAdCubit(),
                  child: const BannerPage(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void changePageByIndex(int index, String title) {
    setState(() {
      currentPageTitle = title;
      currentPageIndex = index;
      _tabController.index = index;
    });
    Navigator.pop(context);
  }
}
