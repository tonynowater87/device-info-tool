import 'package:device_info_tool/common/miscellaneous.dart';
import 'package:device_info_tool/data/model/Distribution.dart';
import 'package:device_info_tool/view/androiddistribution/chart_type.dart';
import 'package:device_info_tool/view/iosdistribution/ios_distribution_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IOSDistributionPage extends StatefulWidget {
  const IOSDistributionPage({super.key});

  @override
  State<IOSDistributionPage> createState() =>
      _IOSDistributionPageState();
}

class _IOSDistributionPageState extends State<IOSDistributionPage>
    with AutomaticKeepAliveClientMixin {
  ChartType _selectedSegment = ChartType.cumulative;

  @override
  void initState() {
    super.initState();
    context.read<IosDistributionCubit>().load(_selectedSegment);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var state = context.watch<IosDistributionCubit>().state;
    switch (state.runtimeType) {
      case IosDistributionInitial:
      case IosDistributionLoaded:
        final data = tryCast<IosDistributionLoaded>(state);

        List<Widget> content;
        if (data == null) {
          content = [const Center(child: CircularProgressIndicator())];
        } else {
          content = [
            Padding(
              padding:
                  const EdgeInsets.only(left: 4, top: 4, right: 4, bottom: 30),
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                    majorGridLines: MajorGridLines(width: 0)),
                primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: data.maxX,
                    interval:
                        _selectedSegment == ChartType.cumulative ? 25 : 10,
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
                        ? data.iOSDistributionModel.cumulativeDistribution
                        : data.iOSDistributionModel.versionDistribution,
                    xValueMapper: (Distribution data, _) => data.versionName,
                    yValueMapper: (Distribution data, _) => data.percentage,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      'Last updated: ${data.iOSDistributionModel.lastUpdated}\ndata from: https://gs.statcounter.com',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            ),
          ];
        }

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
                        .read<IosDistributionCubit>()
                        .load(_selectedSegment);
                  }),
            ),
            Expanded(
              child: Stack(
                children: content,
              ),
            ),
          ],
        );
      case IosDistributionFailure:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Oops, Something wrong!'),
            OutlinedButton(
              child: const Text('Retry'),
              onPressed: () {
                context.read<IosDistributionCubit>().load(_selectedSegment);
              },
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  bool get wantKeepAlive => true;
}