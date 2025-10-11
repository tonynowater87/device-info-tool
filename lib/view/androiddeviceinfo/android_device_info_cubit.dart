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
  Timer? _timerUpdateMemory;
  Timer? _timerUpdateBattery;
  StreamSubscription<FGBGType>? _foregroundEventStream;

  bool _isScrolling = false;
  bool _hasPendingUpdate = false;

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
    final isDeveloper = systemInfo.isDeveloperOptionsEnabled;

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

    // Start memory update timer
    _startMemoryUpdateTimer();

    // Start battery update timer
    _startBatteryUpdateTimer();
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

  void pauseUpdates() {
    _isScrolling = true;
  }

  void resumeUpdates() {
    _isScrolling = false;
    // If there were pending updates during scrolling, execute them now
    if (_hasPendingUpdate) {
      _hasPendingUpdate = false;
      _updateMemoryInfo();
      _updateBatteryInfo();
    }
  }

  void release() {
    _timerFetchBattery?.cancel();
    _timerUpdateMemory?.cancel();
    _timerUpdateBattery?.cancel();
    _foregroundEventStream?.cancel();
  }

  Future<void> _updateMemoryInfo() async {
    if (state is! AndroidDeviceInfoLoaded) return;

    // Skip update if user is scrolling, but mark as pending
    if (_isScrolling) {
      _hasPendingUpdate = true;
      return;
    }

    try {
      var channel = const MethodChannel('com.tonynowater.mobileosversions');
      var deviceInfoMap = await channel.invokeMethod("getDeviceInfo");

      // Only update CPU info (which contains memory info)
      final cpuInfo = AndroidCpuInfoModel.fromMap(deviceInfoMap);

      final currentState = state as AndroidDeviceInfoLoaded;

      // Only emit if memory data actually changed (to avoid unnecessary UI rebuilds)
      final currentCpu = currentState.cpuInfoModel;
      if (currentCpu != null &&
          currentCpu.availableMemory == cpuInfo.availableMemory &&
          currentCpu.usedMemory == cpuInfo.usedMemory) {
        // Data hasn't changed significantly, skip emit
        return;
      }

      emit(AndroidDeviceInfoLoaded(
        deviceInfoModel: currentState.deviceInfoModel,
        advertisingId: currentState.advertisingId,
        androidId: currentState.androidId,
        isDeveloper: currentState.isDeveloper,
        wifiIp: currentState.wifiIp,
        connectivities: currentState.connectivities,
        batteryInfoModel: currentState.batteryInfoModel,
        storageInfoModel: currentState.storageInfoModel,
        networkInfoModel: currentState.networkInfoModel,
        systemInfoModel: currentState.systemInfoModel,
        cpuInfoModel: cpuInfo, // Update only CPU/Memory info
      ));
    } catch (e) {
      // Silently fail to avoid disrupting the UI
      debugPrint('Failed to update memory info: $e');
    }
  }

  void _startMemoryUpdateTimer() {
    _timerUpdateMemory?.cancel();
    _timerUpdateMemory = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateMemoryInfo();
    });
  }

  Future<void> _updateBatteryInfo() async {
    if (state is! AndroidDeviceInfoLoaded) return;

    // Skip update if user is scrolling, but mark as pending
    if (_isScrolling) {
      _hasPendingUpdate = true;
      return;
    }

    try {
      var channel = const MethodChannel('com.tonynowater.mobileosversions');
      var deviceInfoMap = await channel.invokeMethod("getDeviceInfo");

      // Only update battery info
      final batteryInfo = AndroidBatteryInfoModel.fromMap(deviceInfoMap);

      final currentState = state as AndroidDeviceInfoLoaded;

      // Only emit if battery data actually changed (to avoid unnecessary UI rebuilds)
      final currentBattery = currentState.batteryInfoModel;
      if (currentBattery != null &&
          currentBattery.chargingStatus == batteryInfo.chargingStatus &&
          currentBattery.batteryLevel == batteryInfo.batteryLevel &&
          currentBattery.temperature == batteryInfo.temperature &&
          currentBattery.voltage == batteryInfo.voltage) {
        // Data hasn't changed, skip emit
        return;
      }

      emit(AndroidDeviceInfoLoaded(
        deviceInfoModel: currentState.deviceInfoModel,
        advertisingId: currentState.advertisingId,
        androidId: currentState.androidId,
        isDeveloper: currentState.isDeveloper,
        wifiIp: currentState.wifiIp,
        connectivities: currentState.connectivities,
        batteryInfoModel: batteryInfo, // Update only battery info
        storageInfoModel: currentState.storageInfoModel,
        networkInfoModel: currentState.networkInfoModel,
        systemInfoModel: currentState.systemInfoModel,
        cpuInfoModel: currentState.cpuInfoModel,
      ));
    } catch (e) {
      // Silently fail to avoid disrupting the UI
      debugPrint('Failed to update battery info: $e');
    }
  }

  void _startBatteryUpdateTimer() {
    _timerUpdateBattery?.cancel();
    _timerUpdateBattery = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateBatteryInfo();
    });
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
