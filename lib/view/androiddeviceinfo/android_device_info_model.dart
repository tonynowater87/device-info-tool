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
  String ydpi;
  String xdpi;
  String totalSpace;
  String usedSpace;
  String freeSpace;

  AndroidDeviceInfoModel({
    required this.androidVersion,
    required this.androidSDKInt,
    required this.securityPatch,
    required this.deviceBrand,
    required this.deviceModel,
    required this.screenInch,
    required this.screenResolution,
    required this.screenDpSize,
    required this.ydpi,
    required this.xdpi,
    required this.totalSpace,
    required this.usedSpace,
    required this.freeSpace,
  });

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


}
