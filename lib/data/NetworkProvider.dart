import 'package:device_info_tool/data/model/AndroidDistribution.dart';
import 'package:device_info_tool/data/model/VersionModelAndroid.dart';
import 'package:device_info_tool/data/model/VersionModelAndroidWearOS.dart';
import 'package:device_info_tool/data/model/VersionModelAndroid.dart';
import 'package:device_info_tool/data/model/VersionModelAndroidWearOS.dart';
import 'package:device_info_tool/data/model/VersionModelIOS.dart';
import 'package:device_info_tool/data/model/VersionModelTvOS.dart';
import 'package:device_info_tool/data/model/VersionModelWatchOS.dart';
import 'package:device_info_tool/data/model/VesionModelMacOS.dart';

abstract class NetworkProvider {
  Future<List<VersionModelAndroid>> getAndroidVersions();

  Future<List<VersionModelAndroidWearOs>> getAndroidWearOSVersions();

  Future<List<VersionModeliOs>> getIOSVersions();

  Future<List<VersionModeliOs>> getIPadOSVersions();

  Future<List<VersionModelTvOs>> getTvOSVersions();

  Future<List<VersionModelWatchOs>> getWatchOSVersions();

  Future<List<VesionModelMacOs>> getMacOSVersions();

  Future<MobileDistribution?> getAndroidDistribution();

  Future<MobileDistribution?> getIOSDistribution();
}
