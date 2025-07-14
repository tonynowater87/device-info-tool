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

  AndroidBatteryInfoModel({
    required this.batteryLevel,
    required this.chargingStatus,
    required this.capacity,
    required this.technology,
    required this.temperature,
    required this.health,
  });

  factory AndroidBatteryInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return AndroidBatteryInfoModel(
      batteryLevel: map['batteryLevel'],
      chargingStatus: map['chargingStatus'],
      capacity: map['capacity'],
      technology: map['technology'],
      temperature: map['temperature'],
      health: map['health'],
    );
  }


}
