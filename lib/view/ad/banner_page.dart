import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:device_info_tool/view/ad/banner_ad_cubit.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({Key? key}) : super(key: key);

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  @override
  void initState() {
    super.initState();
    context.read<BannerAdCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BannerAdCubit>().state;
    if (state is BannerAdInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is BannerAdLoadFailed) {
      return Center(
        child: OutlinedButton(
          child: const Text('Error, retry...'),
          onPressed: () {
            context.read<BannerAdCubit>().load();
          },
        ),
      );
    } else if (state is BannerAdLoaded) {
      return SizedBox(
        width: state.bannerAd.size.width.toDouble(),
        height: state.bannerAd.size.height.toDouble(),
        child: AdWidget(ad: state.bannerAd),
      );
    } else {
      throw Exception("unexpected state = $state");
    }
  }
}
