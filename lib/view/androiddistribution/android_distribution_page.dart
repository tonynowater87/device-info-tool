import 'package:device_info_tool/view/androiddistribution/android_distribution_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AndroidDistributionPage extends StatefulWidget {
  const AndroidDistributionPage({super.key});

  @override
  State<AndroidDistributionPage> createState() =>
      _AndroidDistributionPageState();
}

class _AndroidDistributionPageState extends State<AndroidDistributionPage> {
  @override
  void initState() {
    super.initState();
    context.read<AndroidDistributionCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AndroidDistributionCubit>().state;
    switch (state.runtimeType) {
      case AndroidDistributionInitial:
        return const Center(child: CircularProgressIndicator());
      case AndroidDistributionLoaded:
        final data =
            (state as AndroidDistributionLoaded).androidDistributionModel;
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 30),
              itemCount: data.versionDistribution.length,
              itemBuilder: (context, index) {
                final item = data.versionDistribution[index];
                return ListTile(
                  title: Text('${item.versionName} ${item.versionCode}'),
                  subtitle: Text(item.percentage),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                color: CupertinoColors.systemBlue,
                child: Center(child: Text('Last updated: ${data.lastUpdated}', style: Theme.of(context).textTheme.bodyText1)),
              ),
            ),
          ],
        );
      case AndroidDistributionFailure:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Oops, Something wrong!'),
            OutlinedButton(
              child: const Text('Retry'),
              onPressed: () {
                context.read<AndroidDistributionCubit>().load();
              },
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}
