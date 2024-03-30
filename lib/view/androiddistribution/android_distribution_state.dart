part of 'android_distribution_cubit.dart';

@immutable
class AndroidDistributionState {}

class AndroidDistributionInitial extends AndroidDistributionState {}

class AndroidDistributionLoaded extends AndroidDistributionState {
  final AndroidDistribution androidDistributionModel;

  AndroidDistributionLoaded({required this.androidDistributionModel});
}

class AndroidDistributionFailure extends AndroidDistributionState {}
