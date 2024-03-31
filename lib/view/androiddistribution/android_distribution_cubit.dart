import 'package:bloc/bloc.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/model/AndroidDistribution.dart';
import 'package:device_info_tool/data/model/Distribution.dart';
import 'package:device_info_tool/view/androiddistribution/chart_type.dart';
import 'package:flutter/foundation.dart';

part 'android_distribution_state.dart';

class AndroidDistributionCubit extends Cubit<AndroidDistributionState> {
  final NetworkProvider _networkProvider;

  AndroidDistributionCubit({required NetworkProvider networkProvider})
      : _networkProvider = networkProvider,
        super(AndroidDistributionInitial());

  void load(ChartType chartType) async {
    try {
      AndroidDistribution? data;
      if (state is AndroidDistributionLoaded) {
        data = (state as AndroidDistributionLoaded).androidDistributionModel;
      } else {
        emit(AndroidDistributionInitial());
        data = await _networkProvider.getAndroidDistribution();
      }
      double max;
      if (data != null) {
        switch (chartType) {
          case ChartType.cumulative:
            data.cumulativeDistribution.insert(
                0,
                Distribution(
                    versionName: "Others", versionCode: "", percentage: 100.0));
            max = 100.0;
            break;
          case ChartType.individual:
            var cumulativePercentage = data.versionDistribution.fold(0.0,
                (previousValue, element) => element.percentage + previousValue);
            data.versionDistribution.insert(
                0,
                Distribution(
                    versionName: "Others",
                    versionCode: "",
                    percentage: double.parse((100.0 - cumulativePercentage)
                        .toStringAsPrecision(1))));
            max = data.versionDistribution
                .map((e) => e.percentage)
                .reduce((curr, next) => curr > next ? curr : next);
            break;
        }
        emit(AndroidDistributionLoaded(
            androidDistributionModel: data, maxX: max));
      } else {
        emit(AndroidDistributionFailure());
      }
    } catch (e) {
      emit(AndroidDistributionFailure());
    }
  }
}
