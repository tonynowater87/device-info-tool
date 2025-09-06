import 'package:device_info_tool/common/utils.dart';

enum AndroidScreenDensity {
  ldpi(120),
  mdpi(160),
  hdpi(240),
  xhdpi(320),
  xxhdpi(480),
  xxxhdpi(640),
  unknown(-1);

  const AndroidScreenDensity(this.dpi);

  final int dpi;
}

class AndroidDeviceInfoModel {
  String androidVersion;
  String androidSDKInt;
  String securityPatch;
  String deviceBrand;
  String deviceModel;
  String screenInch;
  String screenResolution;
  String screenDpSize;
  String screenRatio;
  String ydpi;
  String xdpi;

  AndroidDeviceInfoModel({
    required this.androidVersion,
    required this.androidSDKInt,
    required this.securityPatch,
    required this.deviceBrand,
    required this.deviceModel,
    required this.screenInch,
    required this.screenResolution,
    required this.screenDpSize,
    required this.screenRatio,
    required this.ydpi,
    required this.xdpi,
  });

  factory AndroidDeviceInfoModel.fromMap(Map<dynamic, dynamic> map) {
    var widthInPx = int.tryParse(map['screenResolutionWidth']);
    var heightInPx = int.tryParse(map['screenResolutionHeight']);
    return AndroidDeviceInfoModel(
      androidVersion: map['androidVersion'],
      androidSDKInt: map['androidSDKInt'],
      securityPatch: map['securityPatch'],
      deviceBrand: map['deviceBrand'],
      deviceModel: map['deviceModel'],
      screenInch: map['screenInch'] ?? '',
      screenResolution: "$widthInPx x $heightInPx",
      screenDpSize: map['screenDpSize'],
      screenRatio: Utils.getScreenRatio(
        widthInPx ?? 0,
        heightInPx ?? 0,
      ),
      ydpi: map['ydpi'],
      xdpi: map['xdpi'],
    );
  }

  AndroidScreenDensity getScreenDensity() {
    final intDPI = int.tryParse(ydpi) ?? 0;
    if (intDPI == 0) {
      return AndroidScreenDensity.unknown;
    }
    if (intDPI <= AndroidScreenDensity.ldpi.dpi) {
      return AndroidScreenDensity.ldpi;
    }
    if (intDPI <= AndroidScreenDensity.mdpi.dpi) {
      return AndroidScreenDensity.mdpi;
    }
    if (intDPI <= AndroidScreenDensity.hdpi.dpi) {
      return AndroidScreenDensity.hdpi;
    }
    if (intDPI <= AndroidScreenDensity.xhdpi.dpi) {
      return AndroidScreenDensity.xhdpi;
    }
    if (intDPI <= AndroidScreenDensity.xxhdpi.dpi) {
      return AndroidScreenDensity.xxhdpi;
    }
    if (intDPI <= AndroidScreenDensity.xxxhdpi.dpi) {
      return AndroidScreenDensity.xxxhdpi;
    }
    return AndroidScreenDensity.unknown;
  }
}

class AndroidBatteryInfoModel {
  String batteryLevel;
  String chargingStatus;
  String capacity;
  String technology;
  String temperature;
  String health;
  String voltage;

  AndroidBatteryInfoModel({
    required this.batteryLevel,
    required this.chargingStatus,
    required this.capacity,
    required this.technology,
    required this.temperature,
    required this.health,
    required this.voltage,
  });

  factory AndroidBatteryInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return AndroidBatteryInfoModel(
      batteryLevel: map['batteryLevel'] ?? '',
      chargingStatus: map['batteryStatus'] ?? '',
      capacity: map['capacity'] ?? '',
      technology: map['batteryTechnology'] ?? '',
      temperature: map['batteryTemperature'] ?? '',
      health: map['batteryHealth'] ?? '',
      voltage: map['batteryVoltage'] ?? '',
    );
  }
}

class AndroidStorageInfoModel {
  String internalTotalSpace;
  String internalAvailableSpace;
  String internalUsedSpace;
  String externalTotalSpace;
  String externalAvailableSpace;
  String externalUsedSpace;

  AndroidStorageInfoModel({
    required this.internalTotalSpace,
    required this.internalAvailableSpace,
    required this.internalUsedSpace,
    required this.externalTotalSpace,
    required this.externalAvailableSpace,
    required this.externalUsedSpace,
  });

  factory AndroidStorageInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return AndroidStorageInfoModel(
      internalTotalSpace: map['internalStorageTotal'] ?? '',
      internalAvailableSpace: map['internalStorageAvailable'] ?? '',
      internalUsedSpace: map['internalStorageUsed'] ?? '',
      externalTotalSpace: map['externalStorageTotal'] ?? '',
      externalAvailableSpace: map['externalStorageAvailable'] ?? '',
      externalUsedSpace: map['externalStorageUsed'] ?? '',
    );
  }
}

class AndroidNetworkInfoModel {
  String networkType;
  String networkSubtype;
  String networkState;
  String isRoaming;

  AndroidNetworkInfoModel({
    required this.networkType,
    required this.networkSubtype,
    required this.networkState,
    required this.isRoaming,
  });

  factory AndroidNetworkInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return AndroidNetworkInfoModel(
      networkType: map['networkType'] ?? '',
      networkSubtype: map['networkSubtype'] ?? '',
      networkState: map['networkState'] ?? '',
      isRoaming: map['networkIsRoaming'] ?? '',
    );
  }
}

class AndroidSystemInfoModel {
  String androidId;
  String deviceName;
  String deviceProduct;
  String deviceBoard;
  String deviceHardware;
  String deviceBootloader;
  String deviceFingerprint;
  String deviceHost;
  String deviceUser;
  String deviceTime;
  String deviceType;
  String deviceTags;
  String deviceRadioVersion;
  String systemLocale;
  String systemTimeZone;
  String kernelVersion;
  String supportedABIs;
  String is64Bit;

  AndroidSystemInfoModel({
    required this.androidId,
    required this.deviceName,
    required this.deviceProduct,
    required this.deviceBoard,
    required this.deviceHardware,
    required this.deviceBootloader,
    required this.deviceFingerprint,
    required this.deviceHost,
    required this.deviceUser,
    required this.deviceTime,
    required this.deviceType,
    required this.deviceTags,
    required this.deviceRadioVersion,
    required this.systemLocale,
    required this.systemTimeZone,
    required this.kernelVersion,
    required this.supportedABIs,
    required this.is64Bit,
  });

  factory AndroidSystemInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return AndroidSystemInfoModel(
      androidId: map['androidId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      deviceProduct: map['deviceProduct'] ?? '',
      deviceBoard: map['deviceBoard'] ?? '',
      deviceHardware: map['deviceHardware'] ?? '',
      deviceBootloader: map['deviceBootloader'] ?? '',
      deviceFingerprint: map['deviceFingerprint'] ?? '',
      deviceHost: map['deviceHost'] ?? '',
      deviceUser: map['deviceUser'] ?? '',
      deviceTime: map['deviceTime'] ?? '',
      deviceType: map['deviceType'] ?? '',
      deviceTags: map['deviceTags'] ?? '',
      deviceRadioVersion: map['deviceRadioVersion'] ?? '',
      systemLocale: map['systemLocale'] ?? '',
      systemTimeZone: map['systemTimeZone'] ?? '',
      kernelVersion: map['kernelVersion'] ?? '',
      supportedABIs: map['supportedABIs'] ?? '',
      is64Bit: map['is64Bit'] ?? '',
    );
  }
}

class AndroidCpuInfoModel {
  String cpuCoreCount;
  String totalMemory;
  String availableMemory;
  Map<String, String> cpuDetails;

  AndroidCpuInfoModel({
    required this.cpuCoreCount,
    required this.totalMemory,
    required this.availableMemory,
    required this.cpuDetails,
  });

  factory AndroidCpuInfoModel.fromMap(Map<dynamic, dynamic> map) {
    Map<String, String> details = {};
    map.forEach((key, value) {
      if (key != 'CPU Core Count' && 
          key != 'Total Memory' && 
          key != 'Available Memory') {
        details[key.toString()] = value.toString();
      }
    });

    return AndroidCpuInfoModel(
      cpuCoreCount: map['CPU Core Count'] ?? '',
      totalMemory: map['Total Memory'] ?? '',
      availableMemory: map['Available Memory'] ?? '',
      cpuDetails: details,
    );
  }
}
