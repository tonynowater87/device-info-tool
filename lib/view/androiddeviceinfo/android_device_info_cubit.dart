import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:advertising_id/advertising_id.dart';
import 'package:android_id/android_id.dart';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_tool/common/utils.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_model.dart';
import 'package:memory_info/memory_info.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:system_info2/system_info2.dart';

part 'android_device_info_state.dart';

class AndroidDeviceInfoCubit extends Cubit<AndroidDeviceInfoState> {
  
  final _networkInfoPlugin = NetworkInfo();
  final _memoryInfoPlugin = MemoryInfoPlugin();
  final _connectivityPlugin = Connectivity();

  Timer? _timerFetchBattery;
  StreamSubscription<FGBGType>? _foregroundEventStream;

  AndroidDeviceInfoCubit() : super(AndroidDeviceInfoInitial());

  Future<void> load() async {
    var channel = const MethodChannel('com.tonynowater.mobileosversions');
    var deviceInfoMap = await channel.invokeMethod("getDeviceInfo");

    // Parse all device info from the single map
    final deviceInfo = AndroidDeviceInfoModel.fromMap(deviceInfoMap);
    final batteryInfo = AndroidBatteryInfoModel.fromMap(deviceInfoMap);
    final storageInfo = AndroidStorageInfoModel.fromMap(deviceInfoMap);
    final networkInfo = AndroidNetworkInfoModel.fromMap(deviceInfoMap);
    final systemInfo = AndroidSystemInfoModel.fromMap(deviceInfoMap);
    final cpuInfo = AndroidCpuInfoModel.fromMap(deviceInfoMap);

    final adId = await _getAdvertisingId();
    final isDeveloper = await _getIsDeveloper();

    // network info from Flutter plugins
    var wifiIp = await _networkInfoPlugin.getWifiIP();
    var connectivity = await _connectivityPlugin.checkConnectivity();
    String connectivityString = connectivity.map((e) => e.name).join(', ');

    emit(AndroidDeviceInfoLoaded(
        deviceInfoModel: deviceInfo,
        advertisingId: adId,
        androidId: systemInfo.androidId,  // Use from systemInfo instead of separate call
        isDeveloper: isDeveloper,
        wifiIp: wifiIp ?? '',
        connectivities: connectivityString,
        batteryInfoModel: batteryInfo,
        storageInfoModel: storageInfo,
        networkInfoModel: networkInfo,
        systemInfoModel: systemInfo,
        cpuInfoModel: cpuInfo));
  }

  void copyAdvertisingId() {
    if (state is AndroidDeviceInfoLoaded) {
      Clipboard.setData(ClipboardData(
          text: (state as AndroidDeviceInfoLoaded).advertisingId));
    }
  }

  void copyAndroidId() {
    if (state is AndroidDeviceInfoLoaded) {
      Clipboard.setData(ClipboardData(
          text: (state as AndroidDeviceInfoLoaded).androidId));
    }
  }

  void release() {
    _timerFetchBattery?.cancel();
    _foregroundEventStream?.cancel();
  }

  Future<bool> _getIsDeveloper() async {
    // TODO manually implement this
    // return await FlutterAndroidDeveloperMode.isAndroidDeveloperModeEnabled;
    return false;
  }

  Future<String> _getAdvertisingId() async {
    String? advertisingId;
    bool? isLimitAdTrackingEnabled;

    try {
      advertisingId = await AdvertisingId.id(true);
    } on PlatformException {
      FirebaseCrashlytics.instance
          .recordError(Exception("getAdvertisingId PlatformException 1"), null);
    }

    try {
      isLimitAdTrackingEnabled = await AdvertisingId.isLimitAdTrackingEnabled;
    } on PlatformException {
      isLimitAdTrackingEnabled = false;
      FirebaseCrashlytics.instance
          .recordError(Exception("getAdvertisingId PlatformException 2"), null);
    }

    return advertisingId ?? 'Failed to get advertisingId.';
  }

  
}
