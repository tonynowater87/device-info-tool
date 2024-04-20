part of 'android_device_info_cubit.dart';

@immutable
abstract class AndroidDeviceInfoState {}

class AndroidDeviceInfoInitial extends AndroidDeviceInfoState {}

class AndroidDeviceInfoLoaded extends AndroidDeviceInfoState {
  final AndroidDeviceInfoModel deviceInfoModel;

  final String cpu;
  final String cpuCores;
  final String totalMemory;
  final String advertisingId;
  final String androidId;
  final bool isDeveloper;
  final AndroidBatteryInfoModel? batteryInfoModel;
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
    required this.storageInfo
  });

  AndroidDeviceInfoLoaded copyWith({AndroidBatteryInfoModel? batteryInfoModel, bool? isDeveloper}) =>
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
          batteryInfoModel: batteryInfoModel ?? this.batteryInfoModel);
}
