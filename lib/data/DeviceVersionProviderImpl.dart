import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_tool/data/DeviceVersionProvider.dart';

class DeviceVersionProviderImpl extends DeviceVersionProvider {
  @override
  Future<String> getOSVersion(DeviceType deviceType) async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // {systemName: iOS, isPhysicalDevice: false, utsname: {release: 22.2.0, sysname: Darwin, nodename: tonynowaterdeMacBook-Pro.local, machine: iPhone14,4, version: Darwin Kernel Version 22.2.0: Fri Nov 11 02:03:51 PST 2022; root:xnu-8792.61.2~4/RELEASE_ARM64_T6000}, model: iPhone, localizedModel: iPhone, systemVersion: 16.1, name: iPhone 13 mini, identifierForVendor: 35CA575F-7B6B-4EB7-B03A-9D0C0AC10654}
    IosDeviceInfo? iOSInfo;
    bool isIPad = false;
    if (Platform.isIOS) {
      iOSInfo = await deviceInfoPlugin.iosInfo;
      isIPad = iOSInfo.model?.toLowerCase().contains("ipad") ?? false;
    }

    AndroidDeviceInfo? androidInfo;
    if (Platform.isAndroid) {
      androidInfo = await deviceInfoPlugin.androidInfo;
    }

    switch (deviceType) {
      case DeviceType.iPad:
        return isIPad ? iOSInfo?.systemVersion ?? "" : "";
      case DeviceType.iPhone:
        return !isIPad ? iOSInfo?.systemVersion ?? "" : "";
      case DeviceType.android:
        return androidInfo?.version.release ?? "";
      case DeviceType.appleTv:
      case DeviceType.androidWear:
      case DeviceType.appleWatch:
      case DeviceType.mac:
        return "";
    }
  }

  @override
  Future<DeviceType?> getDeviceType() async {
    if (Platform.isAndroid) {
      return DeviceType.android;
    } else if (Platform.isIOS) {
      final iOSInfo = await DeviceInfoPlugin().iosInfo;
      final isIPad = iOSInfo.model?.toLowerCase().contains("ipad") ?? false;
      if (isIPad) {
        return DeviceType.iPad;
      } else {
        return DeviceType.iPhone;
      }
    } else {
      // unsupported device
      return null;
    }
  }
}
