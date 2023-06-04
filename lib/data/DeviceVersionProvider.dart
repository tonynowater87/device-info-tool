enum DeviceType { android, androidWear, iPhone, iPad, appleTv, appleWatch, mac }

abstract class DeviceVersionProvider {
  Future<String> getOSVersion(DeviceType deviceType);

  Future<DeviceType?> getDeviceType();
}
