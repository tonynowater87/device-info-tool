import 'package:bloc/bloc.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/model/AndroidDistribution.dart';
import 'package:flutter/foundation.dart';

part 'android_distribution_state.dart';

class AndroidDistributionCubit extends Cubit<AndroidDistributionState> {
  final NetworkProvider _networkProvider;

  AndroidDistributionCubit({required NetworkProvider networkProvider})
      : _networkProvider = networkProvider,
        super(AndroidDistributionInitial());

  void load() async {
    emit(AndroidDistributionInitial());
    try {
      final data = await _networkProvider.getAndroidDistribution();
      if (data != null) {
        emit(AndroidDistributionLoaded(androidDistributionModel: data));
      } else {
        emit(AndroidDistributionFailure());
      }
    } catch (e) {
      emit(AndroidDistributionFailure());
    }
  }
}
