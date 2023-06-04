import 'dart:io';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:device_info_tool/data/AppVersionProvider.dart';
import 'package:device_info_tool/data/AppVersionProviderImpl.dart';
import 'package:device_info_tool/data/DeviceVersionProvider.dart';
import 'package:device_info_tool/data/DeviceVersionProviderImpl.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/NetworkProviderGithub.dart';
import 'package:device_info_tool/firebase_options.dart';
import 'package:device_info_tool/view/ad/banner_ad_cubit.dart';
import 'package:device_info_tool/view/ad/banner_page.dart';
import 'package:device_info_tool/view/android/android_version_page.dart';
import 'package:device_info_tool/view/appinfo/appinfo_cubit.dart';
import 'package:device_info_tool/view/appinfo/appinfo_page.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_cubit.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_page.dart';
import 'package:device_info_tool/view/ios/ios_version_page.dart';
import 'package:device_info_tool/view/ios/ios_version_page_cubit.dart';
import 'package:device_info_tool/view/wearOS/android_wear_os_version_page.dart';
import 'package:device_info_tool/view/wearOS/android_wear_os_version_page_cubit.dart';

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

  MobileAds.instance.initialize();
  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider<NetworkProvider>(
          create: (context) => NetworkProviderGithub(httpClient: HttpClient())),
      RepositoryProvider<DeviceVersionProvider>(
          create: (context) => DeviceVersionProviderImpl()),
      RepositoryProvider<AppVersionProvider>(
          create: (context) => AppVersionProviderImpl()),
    ],
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String DefaultTitle = 'Current Device Information';
  String appTitle = DefaultTitle;
  var bottomNavBarItems = <Tab>[];
  var screens = <Widget>[];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var androidDeviceInfoScreen = BlocProvider(
        create: (context) => AndroidDeviceInfoCubit(), child: const AndroidDeviceInfoPage());

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

    if (Platform.isAndroid) {
      bottomNavBarItems = [
        _getDeviceInfoNavBarItem(),
        _getAndroidNavBarItem(),
        _getAndroidWearOSNavBarItem(),
        _getIOSNavBarItem(),
        _getIPadOSNavBarItem(),
        _getTvOSNavBarItem(),
        _getWatchOSNavBarItem(),
        _getMacOSNavBarItem()
      ];
      screens = [
        androidDeviceInfoScreen,
        androidScreen,
        androidWearOSScreen,
        iOSScreen,
        iPadOSScreen,
        tvOSScreen,
        watchOSScreen,
        macOSScreen
      ];
    } else if (Platform.isIOS) {
      bottomNavBarItems = [
        _getIOSNavBarItem(),
        _getIPadOSNavBarItem(),
        _getTvOSNavBarItem(),
        _getWatchOSNavBarItem(),
        _getMacOSNavBarItem()
      ];
      screens = [
        iOSScreen,
        iPadOSScreen,
        tvOSScreen,
        watchOSScreen,
        macOSScreen
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => BlocProvider(
                          create: (context) {
                            return AppInfoCubit(context.read<AppVersionProvider>());
                          },
                          child: const AppInfoPage())),
                );
              },
              icon: const Icon(Icons.info_outline_rounded))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                    length: screens.length,
                    child: Builder(builder: (context) {
                      TabController tabController =
                          DefaultTabController.of(context);
                      if (!tabController.hasListeners) {
                        tabController.addListener(() {
                          _updateAppTitleByTabIndex(tabController.index);
                        });
                      }

                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: TabBarView(
                              children: screens,
                            ),
                          ),
                          ButtonsTabBar(
                            radius: 12,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            backgroundColor: CupertinoColors.activeBlue,
                            unselectedBackgroundColor: CupertinoColors.white,
                            borderWidth: 1,
                            unselectedBorderColor:
                                CupertinoColors.activeBlue.withAlpha(200),
                            borderColor: Colors.transparent,
                            center: false,
                            unselectedLabelStyle:
                                TextStyle(color: CupertinoColors.activeBlue),
                            labelStyle: TextStyle(color: CupertinoColors.white),
                            height: 56,
                            tabs: bottomNavBarItems,
                          )
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

  void _updateAppTitleByTabIndex(int tabIndex) {
    setState(() {
      if (tabIndex == 0) {
        appTitle = DefaultTitle;
      } else {
        var tabText = bottomNavBarItems[tabIndex].text;
        appTitle = tabText == null ? "" : "$tabText Version List";
      }
    });
  }

  Tab _getDeviceInfoNavBarItem() {
    return Tab(
        icon: Image.asset(
            Platform.isAndroid
                ? 'assets/images/android-device-icon.png'
                : 'assets/images/iphone-device-icon.png',
            fit: BoxFit.contain),
        text: "Device Info");
  }

  Tab _getAndroidNavBarItem() {
    return Tab(
        icon: Image.asset(
          'assets/images/android-device-icon.png',
          fit: BoxFit.contain,
        ),
        text: "Android OS");
  }

  Tab _getAndroidWearOSNavBarItem() {
    return Tab(
        icon: Image.asset(
          'assets/images/smart-device-icon.png',
          fit: BoxFit.contain,
        ),
        text: "Android WearOS");
  }

  Tab _getIOSNavBarItem() {
    return Tab(
      icon: Image.asset(
        'assets/images/iphone-device-icon.png',
        fit: BoxFit.contain,
      ),
      text: "iOS",
    );
  }

  Tab _getIPadOSNavBarItem() {
    return Tab(
      icon: Image.asset(
        'assets/images/ipad-device-icon.png',
        fit: BoxFit.contain,
      ),
      text: "iPadOS",
    );
  }

  Tab _getTvOSNavBarItem() {
    return Tab(
      icon: Image.asset(
        'assets/images/apple-tv-device-icon.png',
        fit: BoxFit.contain,
      ),
      text: "tvOS",
    );
  }

  Tab _getWatchOSNavBarItem() {
    return Tab(
      icon: Image.asset(
        'assets/images/apple-watch-device-icon.png',
        fit: BoxFit.contain,
      ),
      text: "watchOS",
    );
  }

  Tab _getMacOSNavBarItem() {
    return Tab(
      icon: Image.asset(
        'assets/images/mac-device-icon.png',
        fit: BoxFit.contain,
      ),
      text: "macOS",
    );
  }
}
