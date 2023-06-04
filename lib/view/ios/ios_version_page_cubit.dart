import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:device_info_tool/common/string_extensions.dart';
import 'package:device_info_tool/data/DeviceVersionProvider.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/model/VersionModelIOS.dart';
import 'package:device_info_tool/data/model/VersionModelTvOS.dart';
import 'package:device_info_tool/data/model/VersionModelWatchOS.dart';
import 'package:device_info_tool/data/model/VesionModelMacOS.dart';
import 'package:device_info_tool/view/ios/ui_model_ios.dart';

part 'ios_version_page_state.dart';

class IosVersionPageCubit extends Cubit<IosVersionPageState> {
  final NetworkProvider _networkProvider;
  final DeviceVersionProvider _deviceVersionProvider;

  IosVersionPageCubit(
      {required NetworkProvider networkProvider,
      required DeviceVersionProvider deviceVersionProvider})
      : _networkProvider = networkProvider,
        _deviceVersionProvider = deviceVersionProvider,
        super(IosVersionPageInitial());

  Future<void> loadOSVersions(DeviceType deviceType) async {
    final String selfVersion =
        await _deviceVersionProvider.getOSVersion(deviceType);
    int index = -1;
    try {
      List<UiModelIOS> uiData = await mappingResponseToUiModel(deviceType);
      _sort(uiData);
      if (selfVersion.isNotEmpty) {
        index = uiData.indexWhere(
            (element) => selfVersion.compareVersion(element.version));
      }
      emit(IosVersionPageSuccess(data: uiData, indexOfSelfVersion: index));
    } catch (e) {
      emit(IosVersionPageFailure());
    }
  }

  void _sort(List<UiModelIOS> data) {
    if (data.first.deviceType == DeviceType.mac) {
      data.sort((UiModelIOS v1, UiModelIOS v2) {
        return v1.initialReleaseDate.compareTo(v2.initialReleaseDate) * -1;
      });
    } else {
      data.sort((UiModelIOS v1, UiModelIOS v2) {
        double version1 = double.tryParse(v1.version) ?? 1000.0;
        double version2 = double.tryParse(v2.version) ?? 1000.0;
        if (version1 > version2) {
          return -1;
        } else if (version1 < version2) {
          return 1;
        } else {
          return 0;
        }
      });
    }
  }

  Future<List<UiModelIOS>> mappingResponseToUiModel(
      DeviceType deviceType) async {
    switch (deviceType) {
      case DeviceType.iPhone:
        List<VersionModeliOs> data = await _networkProvider.getIOSVersions();
        List<UiModelIOS> uiData = data
            .map((e) => UiModelIOS(
            deviceType: deviceType,
            version: e.version,
            initialReleaseDate: e.releaseDate,
            latestVersion: e.latestVersion,
            latestReleaseDate: e.latestDate))
            .toList();
        return Future.value(uiData);
      case DeviceType.iPad:
        List<VersionModeliOs> data = await _networkProvider.getIPadOSVersions();
        List<UiModelIOS> uiData = data
            .map((e) => UiModelIOS(
                deviceType: deviceType,
                version: e.version,
                initialReleaseDate: e.releaseDate,
                latestVersion: e.latestVersion,
                latestReleaseDate: e.latestDate))
            .toList();
        return Future.value(uiData);
      case DeviceType.appleTv:
        List<VersionModelTvOs> data = await _networkProvider.getTvOSVersions();
        List<UiModelIOS> uiData = data
            .map((e) => UiModelIOS(
                deviceType: deviceType,
                version: e.version,
                initialReleaseDate: e.releaseDate,
                latestVersion: e.latestVersion,
                latestReleaseDate: e.latestDate))
            .toList();
        return Future.value(uiData);
      case DeviceType.appleWatch:
        List<VersionModelWatchOs> data =
            await _networkProvider.getWatchOSVersions();
        List<UiModelIOS> uiData = data
            .map((e) => UiModelIOS(
                deviceType: deviceType,
                version: e.version,
                initialReleaseDate: e.releaseDate,
                latestVersion: e.latestVersion,
                latestReleaseDate: e.latestReleaseDate,
                baseOnIOSVersion: e.basedoniosversion))
            .toList();
        return Future.value(uiData);

      case DeviceType.mac:
        List<VesionModelMacOs> data = await _networkProvider.getMacOSVersions();
        List<UiModelIOS> uiData = data
            .map((e) => UiModelIOS(
                deviceType: deviceType,
                version: e.version,
                initialReleaseDate: e.initialReleaseDate,
                latestVersion: e.latestVersion,
                latestReleaseDate: e.latestReleaseDate,
                versionName: e.versionName))
            .toList();
        return Future.value(uiData);
      case DeviceType.android:
      case DeviceType.androidWear:
        throw Exception("unexpected device type here ($deviceType)");
    }
  }
}
