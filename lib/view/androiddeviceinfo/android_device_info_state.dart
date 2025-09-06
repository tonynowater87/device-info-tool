part of 'android_device_info_cubit.dart';

@immutable
abstract class AndroidDeviceInfoState {}

class AndroidDeviceInfoInitial extends AndroidDeviceInfoState {}

class AndroidDeviceInfoLoaded extends AndroidDeviceInfoState {
  final AndroidDeviceInfoModel deviceInfoModel;
  final AndroidBatteryInfoModel? batteryInfoModel;
  final AndroidStorageInfoModel? storageInfoModel;
  final AndroidNetworkInfoModel? networkInfoModel;
  final AndroidSystemInfoModel? systemInfoModel;
  final AndroidCpuInfoModel? cpuInfoModel;

  final String cpu;
  final String cpuCores;
  final String totalMemory;
  final String advertisingId;
  final String androidId;
  final bool isDeveloper;
  String wifiIp;
  String connectivities;
  String storageInfo;

  AndroidDeviceInfoLoaded({
    required this.deviceInfoModel,
    required this.cpu,
    required this.cpuCores,
    required this.totalMemory,
    required this.advertisingId,
    required this.androidId,
    required this.isDeveloper,
    required this.batteryInfoModel,
    required this.wifiIp,
    required this.connectivities,
    required this.storageInfo,
    this.storageInfoModel,
    this.networkInfoModel,
    this.systemInfoModel,
    this.cpuInfoModel,
  });

  AndroidDeviceInfoLoaded copyWith({
    AndroidBatteryInfoModel? batteryInfoModel, 
    bool? isDeveloper,
    AndroidStorageInfoModel? storageInfoModel,
    AndroidNetworkInfoModel? networkInfoModel,
    AndroidSystemInfoModel? systemInfoModel,
    AndroidCpuInfoModel? cpuInfoModel,
  }) =>
      AndroidDeviceInfoLoaded(
          deviceInfoModel: deviceInfoModel,
          cpu: cpu,
          cpuCores: cpuCores,
          totalMemory: totalMemory,
          advertisingId: advertisingId,
          androidId: androidId,
          isDeveloper: isDeveloper ?? this.isDeveloper,
          wifiIp: wifiIp,
          connectivities: connectivities,
          storageInfo: storageInfo,
          batteryInfoModel: batteryInfoModel ?? this.batteryInfoModel,
          storageInfoModel: storageInfoModel ?? this.storageInfoModel,
          networkInfoModel: networkInfoModel ?? this.networkInfoModel,
          systemInfoModel: systemInfoModel ?? this.systemInfoModel,
          cpuInfoModel: cpuInfoModel ?? this.cpuInfoModel);
}
