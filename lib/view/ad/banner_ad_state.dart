part of 'banner_ad_cubit.dart';

@immutable
abstract class BannerAdState {}

class BannerAdInitial extends BannerAdState {}

class BannerAdLoaded extends BannerAdState {
  final BannerAd bannerAd;

  BannerAdLoaded({
    required this.bannerAd,
  });
}

class BannerAdLoadFailed extends BannerAdState {
  final LoadAdError error;

  BannerAdLoadFailed({
    required this.error,
  });
}

