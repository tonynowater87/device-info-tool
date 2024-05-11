import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_tool/common/utils.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/cupertino.dart';
import 'package:memory_info/memory_info.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:storage_space/storage_space.dart';

part 'ios_device_info_state.dart';

class IosDeviceInfoCubit extends Cubit<IosDeviceInfoState> {
  final _deviceInfoPlugin = DeviceInfoPlugin();
  final _networkInfoPlugin = NetworkInfo();
  final _connectivityPlugin = Connectivity();
  final _memoryInfoPlugin = MemoryInfoPlugin();

  bool isLoaded = false;

  IosDeviceInfoCubit() : super(IosDeviceInfoState.empty());

  Future<void> load() async {
    final deviceInfo = await _deviceInfoPlugin.iosInfo;
    debugPrint('[Tony] deviceInfo: $deviceInfo');

    // device info
    var brand = 'Apple';
    var model = deviceInfo.name;
    var systemVersion = deviceInfo.systemVersion;
    var identifierForVendor = deviceInfo.identifierForVendor;
    var isPhysicalDevice = deviceInfo.isPhysicalDevice;

    // utsname info
    var sysName = deviceInfo.utsname.sysname;
    var nodeName = deviceInfo.utsname.nodename;
    var release = deviceInfo.utsname.release;
    var version = deviceInfo.utsname.version;
    var machine = deviceInfo.utsname.machine;

    // network info
    var wifiIp = await _networkInfoPlugin.getWifiIP();
    debugPrint('[Tony] wifiIp: $wifiIp');
    var connectivity = await _connectivityPlugin.checkConnectivity();
    String connectivityString = connectivity.map((e) => e.name).join(', ');
    for (var value in connectivity) {
      debugPrint('[Tony] connectivity: $value');
    }

    // hardware info
    var totalMemory =
        Utils.formatMB((await _memoryInfoPlugin.memoryInfo).totalMem!.toInt(), 0);
    debugPrint('[Tony] totalMemory: $totalMemory');
    StorageSpace storageSpace =
        await getStorageSpace(lowOnSpaceThreshold: 0, fractionDigits: 2);
    debugPrint(
        '[Tony] storageSpace, total: ${storageSpace.totalSize}, free: ${storageSpace.freeSize}, used: ${storageSpace.usedSize}, usagePercent: ${storageSpace.usagePercent}');

    emit(IosDeviceInfoState(
        brand: brand,
        model: model ?? "",
        systemVersion: systemVersion ?? "",
        identifierForVendor: identifierForVendor ?? "",
        isPhysicalDevice: isPhysicalDevice,
        sysName: sysName ?? "",
        nodeName: nodeName ?? "",
        release: release ?? "",
        version: version ?? "",
        machine: machine ?? "",
        resolution: "",
        screenPt: "",
        inch: "",
        aspectRatio: "",
        ppi: "",
        wifiIp: wifiIp ?? "",
        connectivities: connectivityString,
        totalMemoryInGB: totalMemory,
        storageInfo:
            "${storageSpace.usedSize} / ${storageSpace.totalSize} (${storageSpace.usagePercent}%)"));
  }

  void loadContext(BuildContext buildContext) {
    if (isLoaded) return;

    // display metrics
    DisplayMetricsData? displayMetricsData =
        DisplayMetrics.maybeOf(buildContext);

    if (displayMetricsData == null) {
      debugPrint('[Tony] displayMetricsData is null');
      return;
    }
    isLoaded = true;
    var width = displayMetricsData.resolution.width.toInt();
    var height = displayMetricsData.resolution.height.toInt();
    String resolution = "$width x $height";
    String inch = "${displayMetricsData.diagonal} inch";
    String ppi = "${displayMetricsData.ppi.toInt()} ppi";
    // calculate the screen width and height in pt
    double screenWidthPt = displayMetricsData.physicalSize.width *
        displayMetricsData.inchesToLogicalPixelRatio;
    double screenHeightPt = displayMetricsData.physicalSize.height *
        displayMetricsData.inchesToLogicalPixelRatio;
    String screenPt = "${screenWidthPt.toInt()} x ${screenHeightPt.toInt()}";

    debugPrint(
        '[Tony] resolution: $resolution, screenPt: $screenPt, inch: $inch, ppi: $ppi');
    emit(state.copyWith(
      resolution: resolution,
      screenPt: screenPt,
      inch: inch,
      aspectRatio: Utils.getScreenRatio(width, height),
      ppi: ppi,
    ));
  }
}
