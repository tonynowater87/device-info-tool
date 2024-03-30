part of 'android_distribution_cubit.dart';

@immutable
class AndroidDistributionState {}

class AndroidDistributionInitial extends AndroidDistributionState {}

class AndroidDistributionLoaded extends AndroidDistributionState {

  final AndroidDistribution androidDistributionModel;
  double maxX;

  AndroidDistributionLoaded({required this.androidDistributionModel, this.maxX = 100.0});
}

class AndroidDistributionFailure extends AndroidDistributionState {}
