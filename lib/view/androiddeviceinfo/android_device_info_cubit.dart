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
    var batteryInfoMap = await channel.invokeMethod("getBatteryInfo");

    final deviceInfo = AndroidDeviceInfoModel.fromMap(deviceInfoMap);
    final batteryInfo = AndroidBatteryInfoModel.fromMap(batteryInfoMap);

    final adId = await _getAdvertisingId();
    final androidId = await _getAndroidId();
    final isDeveloper = await _getIsDeveloper();
    final totalMemory = await _getMemoryInfo();
    final cpu = _getCpuInfo();
    final cpuCores = _getCpuCore();

    // network info
    var wifiIp = await _networkInfoPlugin.getWifiIP();
    var connectivity = await _connectivityPlugin.checkConnectivity();
    String connectivityString = connectivity.map((e) => e.name).join(', ');

    emit(AndroidDeviceInfoLoaded(
        deviceInfoModel: deviceInfo,
        cpu: cpu,
        cpuCores: cpuCores,
        totalMemory: totalMemory,
        advertisingId: adId,
        androidId: androidId,
        isDeveloper: isDeveloper,
        wifiIp: wifiIp ?? '',
        connectivities: connectivityString,
        storageInfo: "",
        batteryInfoModel: batteryInfo));
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

  

  Future<String> _getMemoryInfo() async {

    // hardware info
    var totalMemory =
    Utils.formatMB((await _memoryInfoPlugin.memoryInfo).totalMem!.toInt(), 0);
    // debugPrint('[Tony] totalMemory: $totalMemory');
    // StorageSpace storageSpace =
    //     await getStorageSpace(lowOnSpaceThreshold: 0, fractionDigits: 2);
    // debugPrint(
    //     '[Tony] storageSpace, total: ${storageSpace.totalSize}, free: ${storageSpace.freeSize}, used: ${storageSpace.usedSize}, usagePercent: ${storageSpace.usagePercent}');

    return totalMemory;
  }

  String _getCpuInfo() {
    var kernelName = SysInfo.kernelName;
    var kernelVersion = SysInfo.kernelVersion;
    var cpuArch = SysInfo.kernelArchitecture.name;
    var cores = SysInfo.cores.length;
    var core1 = SysInfo.cores.first;
    var vendor = SysInfo.cores.first.vendor;
    var bits = SysInfo.userSpaceBitness;
    return "$vendor $cpuArch";
  }

  Future<bool> _getIsDeveloper() async {
    // TODO manually implement this
    // return await FlutterAndroidDeveloperMode.isAndroidDeveloperModeEnabled;
    return false;
  }

  String _getCpuCore() {
    return SysInfo.cores.length.toString();
  }

  Future<String> _getAndroidId() async {
    String? androidId;
    try {
      androidId = await const AndroidId().getId();
    } on PlatformException {
      FirebaseCrashlytics.instance
          .recordError(Exception("getAndroidId PlatformException 1"), null);
    }
    return androidId ?? 'Failed to get androidId.';
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
