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

  Timer? _updateTimer;
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

    if (!isClosed) {
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

    // Start consolidated update timer
    _startUpdateTimer();
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
    // Clear the pending flag, but don't execute updates immediately
    // Let the Timer trigger the next update naturally to avoid performance impact
    _hasPendingUpdate = false;
  }

  void pauseTimers() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void resumeTimers() {
    // Trigger one immediate update, then restart periodic timer
    _updateDynamicInfo();
    _startUpdateTimer();
  }

  void release() {
    _updateTimer?.cancel();
    _foregroundEventStream?.cancel();
  }

  @override
  Future<void> close() {
    _updateTimer?.cancel();
    _foregroundEventStream?.cancel();
    return super.close();
  }

  Future<void> _updateDynamicInfo() async {
    if (state is! AndroidDeviceInfoLoaded) return;

    // Skip update if user is scrolling, but mark as pending
    if (_isScrolling) {
      _hasPendingUpdate = true;
      return;
    }

    try {
      var channel = const MethodChannel('com.tonynowater.mobileosversions');
      var deviceInfoMap = await channel.invokeMethod("getDeviceInfo");

      // Parse both CPU/memory and battery from the same platform channel call
      final cpuInfo = AndroidCpuInfoModel.fromMap(deviceInfoMap);
      final batteryInfo = AndroidBatteryInfoModel.fromMap(deviceInfoMap);

      final currentState = state as AndroidDeviceInfoLoaded;

      // Check if memory data changed
      final currentCpu = currentState.cpuInfoModel;
      bool cpuChanged = currentCpu == null ||
          currentCpu.availableMemory != cpuInfo.availableMemory ||
          currentCpu.usedMemory != cpuInfo.usedMemory;

      // Check if battery data changed
      final currentBattery = currentState.batteryInfoModel;
      bool batteryChanged = currentBattery == null ||
          currentBattery.chargingStatus != batteryInfo.chargingStatus ||
          currentBattery.batteryLevel != batteryInfo.batteryLevel ||
          currentBattery.temperature != batteryInfo.temperature ||
          currentBattery.voltage != batteryInfo.voltage;

      // Only emit if either changed (to avoid unnecessary UI rebuilds)
      if (!cpuChanged && !batteryChanged) return;

      // Check again if user started scrolling during data fetch
      if (_isScrolling) {
        _hasPendingUpdate = true;
        return;
      }

      if (!isClosed) {
        emit(AndroidDeviceInfoLoaded(
          deviceInfoModel: currentState.deviceInfoModel,
          advertisingId: currentState.advertisingId,
          androidId: currentState.androidId,
          isDeveloper: currentState.isDeveloper,
          wifiIp: currentState.wifiIp,
          connectivities: currentState.connectivities,
          batteryInfoModel: batteryInfo,
          storageInfoModel: currentState.storageInfoModel,
          networkInfoModel: currentState.networkInfoModel,
          systemInfoModel: currentState.systemInfoModel,
          cpuInfoModel: cpuInfo,
        ));
      }
    } catch (e) {
      // Silently fail to avoid disrupting the UI
      debugPrint('Failed to update dynamic info: $e');
    }
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateDynamicInfo();
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
