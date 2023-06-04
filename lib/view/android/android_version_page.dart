import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_tool/view/android/android_version_page_cubit.dart';
import 'package:device_info_tool/view/cell/cell_android.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AndroidVersionPage extends StatefulWidget {
  const AndroidVersionPage({Key? key}) : super(key: key);

  @override
  State<AndroidVersionPage> createState() => _AndroidVersionPageState();
}

class _AndroidVersionPageState extends State<AndroidVersionPage>
    with AutomaticKeepAliveClientMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AndroidVersionPageCubit>().load().then((value) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        final state = context.read<AndroidVersionPageCubit>().state;
        if (state is AndroidVersionPageSuccess &&
            state.indexOfSelfVersion != -1) {
          _itemScrollController.jumpTo(index: state.indexOfSelfVersion);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AndroidVersionPageCubit>().state;
    if (state is AndroidVersionPageInitial) {
      return Container(
        color: CupertinoColors.systemBackground,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (state is AndroidVersionPageFailure) {
      return Container(
        color: CupertinoColors.systemBackground,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops, Something wrong!',
            ),
            OutlinedButton(
              child: const Text('Retry'),
              onPressed: () {
                context.read<AndroidVersionPageCubit>().load();
              },
            ),
          ],
        ),
      );
    } else if (state is AndroidVersionPageSuccess) {
      return ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemBuilder: (context, position) {
          final model = state.data[position];
          final isHighlighted = position == state.indexOfSelfVersion;
          return CellAndroidView(
            versionModelAndroid: model,
            isHighlighted: isHighlighted,
            isLatest: position == 0,
          );
        },
        itemCount: state.data.length,
      );
    } else {
      throw Exception("invalid state=$state");
    }
  }

  @override
  bool get wantKeepAlive => true;
}
