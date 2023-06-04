import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_tool/view/cell/cell_android_wear_os.dart';
import 'package:device_info_tool/view/wearOS/android_wear_os_version_page_cubit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AndroidWearOSVersionPage extends StatefulWidget {
  const AndroidWearOSVersionPage({Key? key}) : super(key: key);

  @override
  State<AndroidWearOSVersionPage> createState() =>
      _AndroidWearOSVersionPageState();
}

class _AndroidWearOSVersionPageState extends State<AndroidWearOSVersionPage>
    with AutomaticKeepAliveClientMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AndroidWearOSVersionPageCubit>().load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AndroidWearOSVersionPageCubit>().state;
    if (state is AndroidWearVersionPageInitial) {
      return Container(
        color: CupertinoColors.systemBackground,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (state is AndroidWearVersionPageFailure) {
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
                context.read<AndroidWearOSVersionPageCubit>().load();
              },
            ),
          ],
        ),
      );
    } else if (state is AndroidWearVersionPageSuccess) {
      return ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemBuilder: (context, position) {
          final model = state.data[position];
          return CellAndroidWearOSView(
            versionModelAndroidWearOS: model,
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
