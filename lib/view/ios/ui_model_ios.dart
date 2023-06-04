import 'package:device_info_tool/data/DeviceVersionProvider.dart';

class UiModelIOS {
  late DeviceType deviceType;
  late String version;
  late String initialReleaseDate;
  late String latestVersion;
  late String latestReleaseDate;
  String? baseOnIOSVersion;
  String? versionName;

  UiModelIOS(
      {required this.deviceType,
      required this.version,
      required this.initialReleaseDate,
      required this.latestVersion,
      required this.latestReleaseDate,
      this.baseOnIOSVersion,
      this.versionName});
}
