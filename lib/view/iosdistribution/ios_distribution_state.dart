part of 'ios_distribution_cubit.dart';

@immutable
class IosDistributionState {}

class IosDistributionInitial extends IosDistributionState {}

class IosDistributionLoaded extends IosDistributionState {

  final MobileDistribution iOSDistributionModel;
  double maxX;

  IosDistributionLoaded({required this.iOSDistributionModel, this.maxX = 100.0});
}

class IosDistributionFailure extends IosDistributionState {}
