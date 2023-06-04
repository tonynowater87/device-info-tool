import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';

import '../../data/model/VersionModelAndroidWearOS.dart';

part 'android_wear_os_version_page_state.dart';

class AndroidWearOSVersionPageCubit
    extends Cubit<AndroidWearOSVersionPageState> {
  final NetworkProvider _networkProvider;

  AndroidWearOSVersionPageCubit({required NetworkProvider networkProvider})
      : _networkProvider = networkProvider,
        super(AndroidWearVersionPageInitial());

  Future<void> load() async {
    try {
      final data = await _networkProvider.getAndroidWearOSVersions();
      _sort(data);
      emit(AndroidWearVersionPageSuccess(data: data));
    } catch (e) {
      emit(AndroidWearVersionPageFailure());
    }
  }

  void _sort(List<VersionModelAndroidWearOs> data) {
    data.sort((VersionModelAndroidWearOs v1, VersionModelAndroidWearOs v2) {
      int order1 = int.tryParse(v1.order) ?? -1;
      int order2 = int.tryParse(v2.order) ?? -1;
      if (order1 > order2) {
        return -1;
      } else if (order1 < order2) {
        return 1;
      } else {
        return 0;
      }
    });
  }
}
