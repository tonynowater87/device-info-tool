import 'package:device_info_tool/data/AppVersionProvider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionProviderImpl extends AppVersionProvider {
  @override
  Future<PackageInfo> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }
}
