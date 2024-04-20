import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:advertising_id/advertising_id.dart';
import 'package:android_id/android_id.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_tool/common/utils.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android_developer_mode/flutter_android_developer_mode.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_model.dart';
import 'package:memory_info/memory_info.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:storage_space/storage_space.dart';
import 'package:system_info2/system_info2.dart';

part 'android_device_info_state.dart';

class AndroidDeviceInfoCubit extends Cubit<AndroidDeviceInfoState> {
  final _deviceInfoPlugin = DeviceInfoPlugin();
  final _batteryInfo = BatteryInfoPlugin();
  final _networkInfoPlugin = NetworkInfo();
  final _memoryInfoPlugin = MemoryInfoPlugin();
  final _connectivityPlugin = Connectivity();

  Timer? _timerFetchBattery;
  StreamSubscription? _streamBatteryState;
  StreamSubscription<FGBGType>? _foregroundEventStream;

  AndroidDeviceInfoCubit() : super(AndroidDeviceInfoInitial());

  Future<void> load() async {
    final deviceInfo = await _getDeviceInfo();
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

    // storage info
    StorageSpace storageSpace =
    await getStorageSpace(lowOnSpaceThreshold: 0, fractionDigits: 2);

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
        storageInfo:
            "${storageSpace.usedSize} / ${storageSpace.totalSize} (${storageSpace.usagePercent}%)",
        batteryInfoModel: null));
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
    _streamBatteryState?.cancel();
    _foregroundEventStream?.cancel();
  }

  @override
  void onChange(Change<AndroidDeviceInfoState> change) {
    super.onChange(change);
    _foregroundEventStream ??= FGBGEvents.stream.listen((event) {
      if (state is AndroidDeviceInfoInitial) return;
      _getIsDeveloper().then((isDeveloper) {
        emit((state as AndroidDeviceInfoLoaded)
            .copyWith(isDeveloper: isDeveloper));
      });
    });

    _streamBatteryState ??=
        _batteryInfo.androidBatteryInfoStream.listen((batteryState) {
      if (state is AndroidDeviceInfoInitial) return;
      const unknown = 'unknown';
      String capacityMaH;
      if (batteryState?.batteryCapacity == null) {
        capacityMaH = 'unknown';
      } else {
        capacityMaH = "${batteryState!.batteryCapacity! ~/ pow(2, 10)} mAh";
      }

      emit((state as AndroidDeviceInfoLoaded).copyWith(
          batteryInfoModel: AndroidBatteryInfoModel(
              batteryLevel: '${batteryState?.batteryLevel} %' ?? unknown,
              // Remaining battery capacity as an integer percentage of total capacity (with no fractional part).
              chargingStatus: batteryState?.chargingStatus?.name ?? unknown,
              // charging, full, discharging
              capacity: capacityMaH,
              // Battery capacity in microampere-hours, as an integer. (mAh / 2 ^ 10)
              technology: batteryState?.technology ?? unknown,
              // String describing the technology of the current battery. e.g. Li-ion
              temperature: "${batteryState?.temperature} °C" ?? unknown,
              // integer containing the current battery temperature.
              health: batteryState?.health?.toString().replaceAll('_', ' ') ??
                  unknown))); // health_good, dead, over_heat, over_voltage, cold, unspecified_failure
    }, onError: (error) {
      if (state is AndroidDeviceInfoInitial) return;
      FirebaseCrashlytics.instance
          .recordError(Exception("listen battery info error: $error"), null);
    }, onDone: () {}, cancelOnError: true);
  }

  Future<String> _getMemoryInfo() async {

    // hardware info
    var totalMemory =
    Utils.formatMB((await _memoryInfoPlugin.memoryInfo).totalMem!.toInt(), 0);
    debugPrint('[Tony] totalMemory: $totalMemory');
    StorageSpace storageSpace =
        await getStorageSpace(lowOnSpaceThreshold: 0, fractionDigits: 2);
    debugPrint(
        '[Tony] storageSpace, total: ${storageSpace.totalSize}, free: ${storageSpace.freeSize}, used: ${storageSpace.usedSize}, usagePercent: ${storageSpace.usagePercent}');

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
    return await FlutterAndroidDeveloperMode.isAndroidDeveloperModeEnabled;
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

  Future<AndroidDeviceInfoModel> _getDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await _deviceInfoPlugin.androidInfo;
      var deviceModel = androidDeviceInfo.model;
      var deviceBrand = androidDeviceInfo.manufacturer;
      var screenInch =
          "${androidDeviceInfo.displayMetrics.sizeInches.toStringAsPrecision(2)} inches";
      var screenResolution =
          '${androidDeviceInfo.displayMetrics.widthPx.toInt()} x ${androidDeviceInfo.displayMetrics.heightPx.toInt()}';
      var density = androidDeviceInfo.displayMetrics.density;
      var dpInWidth = androidDeviceInfo.displayMetrics.widthPx / density;
      var dpInHeight = androidDeviceInfo.displayMetrics.heightPx / density;
      return AndroidDeviceInfoModel(
          deviceModel: deviceModel,
          screenInch: screenInch,
          screenResolution: screenResolution,
          screenDpSize: "${dpInWidth.toInt()} x ${dpInHeight.toInt()}",
          androidVersion: androidDeviceInfo.version.release,
          androidSDKInt: androidDeviceInfo.version.sdkInt.toString(),
          securityPatch: androidDeviceInfo.version.securityPatch ?? "",
          deviceBrand: deviceBrand,
          ydpi: androidDeviceInfo.displayMetrics.yDpi.toInt().toString(),
          xdpi: androidDeviceInfo.displayMetrics.xDpi.toInt().toString());
    } else {
      throw Exception("no expected device");
    }
  }
}
