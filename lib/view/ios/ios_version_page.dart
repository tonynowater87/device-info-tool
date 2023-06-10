import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_tool/data/DeviceVersionProvider.dart';
import 'package:device_info_tool/view/cell/cell_ios.dart';
import 'package:device_info_tool/view/ios/ios_version_page_cubit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class IOSVersionPage extends StatefulWidget {
  final DeviceType _deviceType;

  const IOSVersionPage({Key? key, required DeviceType deviceType})
      : _deviceType = deviceType,
        super(key: key);

  @override
  State<IOSVersionPage> createState() => _IOSVersionPageState();
}

class _IOSVersionPageState extends State<IOSVersionPage>
    with AutomaticKeepAliveClientMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<IosVersionPageCubit>().state;

    if (state is IosVersionPageInitial) {
      return Container(
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (state is IosVersionPageFailure) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops, Something wrong!',
            ),
            OutlinedButton(
              child: const Text('Retry'),
              onPressed: () {
                _load();
              },
            ),
          ],
        ),
      );
    } else if (state is IosVersionPageSuccess) {
      return ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          final model = state.data[position];
          final isHighlighted = position == state.indexOfSelfVersion;
          return CellIOSView(
            versionModeliOs: model,
            isHighlighted: isHighlighted,
            isLatest: position == 0,
          );
        },
        itemCount: state.data.length,
      );
    } else {
      throw Exception("invalid state = $state");
    }
  }

  void _load() {
    switch (widget._deviceType) {
      case DeviceType.iPhone:
      case DeviceType.iPad:
      case DeviceType.appleTv:
      case DeviceType.appleWatch:
      case DeviceType.mac:
        context
            .read<IosVersionPageCubit>()
            .loadOSVersions(widget._deviceType)
            .then((e) {
          _scrolledToDefaultPosition();
        });
        break;
      case DeviceType.android:
      case DeviceType.androidWear:
        throw Exception("unexpected case");
    }
  }

  void _scrolledToDefaultPosition() {
    final state = context.read<IosVersionPageCubit>().state;
    if (state is IosVersionPageSuccess && state.indexOfSelfVersion != -1) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _itemScrollController.jumpTo(index: state.indexOfSelfVersion);
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
