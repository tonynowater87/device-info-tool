import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_tool/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'banner_ad_state.dart';

class BannerAdCubit extends Cubit<BannerAdState> {
  BannerAdCubit() : super(BannerAdInitial());

  BannerAd? _bannerAd;

  void load() {
    final String adUnit;

    if (Platform.isAndroid) {
      adUnit = BANNER_ANDROID_ID;
    } else {
      adUnit = BANNER_IOS_ID;
    }
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adUnit,
        listener: BannerAdListener(onAdLoaded: (ad) {
          emit(BannerAdLoaded(bannerAd: _bannerAd!));
        }, onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _bannerAd = null;
          emit(BannerAdLoadFailed(error: err));
        }),
        request: const AdRequest())
      ..load();
  }
}
