import 'package:bloc/bloc.dart';
import 'package:device_info_tool/common/string_extensions.dart';
import 'package:device_info_tool/data/DeviceVersionProvider.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/model/VersionModelAndroid.dart';
import 'package:meta/meta.dart';

part 'android_version_page_state.dart';

class AndroidVersionPageCubit extends Cubit<AndroidVersionPageState> {
  final NetworkProvider _networkProvider;
  final DeviceVersionProvider _deviceVersionProvider;

  AndroidVersionPageCubit(
      {required NetworkProvider networkProvider,
      required DeviceVersionProvider deviceVersionProvider})
      : _networkProvider = networkProvider,
        _deviceVersionProvider = deviceVersionProvider,
        super(AndroidVersionPageInitial());

  Future<void> load() async {
    final String selfVersion =
        await _deviceVersionProvider.getOSVersion(DeviceType.android);
    try {
      final data = await _networkProvider.getAndroidVersions();
      _sort(data);
      final index = data
          .indexWhere((element) => selfVersion.compareVersion(element.version));
      emit(AndroidVersionPageSuccess(data: data, indexOfSelfVersion: index));
    } catch (e) {
      emit(AndroidVersionPageFailure());
    }
  }

  void _sort(List<VersionModelAndroid> data) {
    data.sort((VersionModelAndroid v1, VersionModelAndroid v2) {
      int apiLevel1 = int.tryParse(v1.apiLevel) ?? 1000;
      int apiLevel2 = int.tryParse(v2.apiLevel) ?? 1000;
      if (apiLevel1 > apiLevel2) {
        return -1;
      } else if (apiLevel1 < apiLevel2) {
        return 1;
      } else {
        return 0;
      }
    });
  }
}
