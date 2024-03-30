import 'package:device_info_tool/data/model/Distribution.dart';
import 'package:device_info_tool/view/androiddistribution/android_distribution_cubit.dart';
import 'package:device_info_tool/view/androiddistribution/chart_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AndroidDistributionPage extends StatefulWidget {
  const AndroidDistributionPage({super.key});

  @override
  State<AndroidDistributionPage> createState() =>
      _AndroidDistributionPageState();
}

class _AndroidDistributionPageState extends State<AndroidDistributionPage> {
  ChartType _selectedSegment = ChartType.cumulative;

  @override
  void initState() {
    super.initState();
    context.read<AndroidDistributionCubit>().load(_selectedSegment);
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
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              width: double.infinity,
              child: SegmentedButton(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        value: ChartType.cumulative, label: Text('Cumulative')),
                    ButtonSegment(
                        value: ChartType.individual, label: Text('Individual')),
                  ],
                  selected: {_selectedSegment},
                  onSelectionChanged: (value) {
                    _selectedSegment = value.first;
                    context
                        .read<AndroidDistributionCubit>()
                        .load(_selectedSegment);
                  }),
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 4, top: 4, right: 4, bottom: 30),
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(
                          majorGridLines: MajorGridLines(width: 0)),
                      primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: state.maxX,
                          interval: _selectedSegment == ChartType.cumulative
                              ? 25
                              : 10,
                          majorGridLines: const MajorGridLines(width: 0)),
                      series: <CartesianSeries<Distribution, String>>[
                        BarSeries(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          animationDuration: 600,
                          isTrackVisible: true,
                          dataLabelMapper: (Distribution data, _) =>
                              '${data.percentage}%',
                          dataLabelSettings: const DataLabelSettings(
                              labelPosition: ChartDataLabelPosition.outside,
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.top),
                          dataSource: _selectedSegment == ChartType.cumulative
                              ? data.cumulativeDistribution
                              : data.versionDistribution,
                          xValueMapper: (Distribution data, _) =>
                              data.versionName,
                          yValueMapper: (Distribution data, _) =>
                              data.percentage,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      color: CupertinoColors.systemBlue,
                      child: Center(
                          child: Text('Last updated: ${data.lastUpdated}',
                              style: Theme.of(context).textTheme.bodyText1)),
                    ),
                  ),
                ],
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
                context.read<AndroidDistributionCubit>().load(_selectedSegment);
              },
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}
