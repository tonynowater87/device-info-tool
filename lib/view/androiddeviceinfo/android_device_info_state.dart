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
  final bool isDeveloper;
  final AndroidBatteryInfoModel? batteryInfoModel;

  AndroidDeviceInfoLoaded({
    required this.deviceInfoModel,
    required this.cpu,
    required this.cpuCores,
    required this.totalMemory,
    required this.advertisingId,
    required this.isDeveloper,
    required this.batteryInfoModel,
  });

  AndroidDeviceInfoLoaded copyWith({AndroidBatteryInfoModel? batteryInfoModel, bool? isDeveloper}) =>
      AndroidDeviceInfoLoaded(
          deviceInfoModel: deviceInfoModel,
          cpu: cpu,
          cpuCores: cpuCores,
          totalMemory: totalMemory,
          advertisingId: advertisingId,
          isDeveloper: isDeveloper ?? this.isDeveloper,
          batteryInfoModel: batteryInfoModel ?? this.batteryInfoModel);
}
