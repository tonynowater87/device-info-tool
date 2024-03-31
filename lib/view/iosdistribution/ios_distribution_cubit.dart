import 'package:bloc/bloc.dart';
import 'package:device_info_tool/data/NetworkProvider.dart';
import 'package:device_info_tool/data/model/AndroidDistribution.dart';
import 'package:device_info_tool/view/androiddistribution/chart_type.dart';
import 'package:meta/meta.dart';

part 'ios_distribution_state.dart';

class IosDistributionCubit extends Cubit<IosDistributionState> {

  final NetworkProvider _networkProvider;

  IosDistributionCubit({required NetworkProvider networkProvider}) : _networkProvider = networkProvider, super(IosDistributionInitial());

  void load(ChartType chartType) async {
    try {
      MobileDistribution? data;
      if (state is IosDistributionLoaded) {
        data = (state as IosDistributionLoaded).iOSDistributionModel;
      } else {
        emit(IosDistributionInitial());
        data = await _networkProvider.getIOSDistribution();
      }
      double max;
      if (data != null) {
        switch (chartType) {
          case ChartType.cumulative:
            max = 100.0;
            break;
          case ChartType.individual:
            max = data.versionDistribution
                .map((e) => e.percentage)
                .reduce((curr, next) => curr > next ? curr : next);
            break;
        }
        emit(IosDistributionLoaded(
            iOSDistributionModel: data, maxX: max));
      } else {
        emit(IosDistributionFailure());
      }
    } catch (e) {
      emit(IosDistributionFailure());
    }
  }
}
