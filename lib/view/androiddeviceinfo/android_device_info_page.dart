import 'package:device_info_tool/view/androiddeviceinfo/action_buttons_view.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class AndroidDeviceInfoPage extends StatefulWidget {
  const AndroidDeviceInfoPage({Key? key}) : super(key: key);

  @override
  State<AndroidDeviceInfoPage> createState() => _AndroidDeviceInfoPageState();
}

class _AndroidDeviceInfoPageState extends State<AndroidDeviceInfoPage>
    with SingleTickerProviderStateMixin {
  final containerKey = GlobalKey();
  AnimationController? _animationController;
  Animation<double>? _animation;
  OverlayEntry? _overlayEntry;
  AnimationStatusListener? snackbarAnimationStatusListener;

  @override
  void initState() {
    super.initState();
    snackbarAnimationStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        _animationController?.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    };
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = CurveTween(curve: Curves.fastLinearToSlowEaseIn)
        .animate(_animationController!);
    context.read<AndroidDeviceInfoCubit>().load();
  }

  @override
  void deactivate() {
    _animationController
      ?..removeStatusListener(snackbarAnimationStatusListener!)
      ..dispose();
    _overlayEntry?.remove();
    context.read<AndroidDeviceInfoCubit>().release();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AndroidDeviceInfoCubit>().state;
    if (state is AndroidDeviceInfoInitial) {
      return Container(
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (state is AndroidDeviceInfoLoaded) {
      return Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: Container(
                      height: 112.5,
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      foregroundDecoration: _getDecoration("Actions"),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(
                            width: 1.5,
                            color: CupertinoColors.activeBlue.withAlpha(100)),
                      ),
                      child: const ActionButtonsView())),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: Container(
                    height: 187.5,
                    width: double.infinity,
                    foregroundDecoration: _getDecoration("Device"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const <Widget>[
                              Text('Brand'),
                              Text('Model'),
                              Text('Android'),
                              Text('API Level'),
                              Text('Security Patch'),
                              Text('Developer Options'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child:
                                        Text(state.deviceInfoModel.deviceBrand),
                                  )),
                              Text(state.deviceInfoModel.deviceModel),
                              Text(state.deviceInfoModel.androidVersion),
                              Text(state.deviceInfoModel.androidSDKInt),
                              Text(state.deviceInfoModel.securityPatch),
                              Text(state.isDeveloper ? 'Enabled' : 'Disabled'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: Container(
                    height: 187.5,
                    width: double.infinity,
                    foregroundDecoration: _getDecoration("Display"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const <Widget>[
                              Text('Resolution'),
                              Text('Size'),
                              Text('xdpi'),
                              Text('ydpi'),
                              Text('Screen Density'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(state.deviceInfoModel.screenResolution),
                              Text(state.deviceInfoModel.screenInch),
                              Text(state.deviceInfoModel.xdpi),
                              Text(state.deviceInfoModel.ydpi),
                              Text(state.deviceInfoModel
                                  .getScreenDensity()
                                  .name),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: Container(
                    key: containerKey,
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const <Widget>[
                              Text('Advertising ID'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FittedBox(child: Text(state.advertisingId)),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            RenderBox renderBox = (containerKey.currentContext!
                                .findRenderObject() as RenderBox);
                            Offset position =
                                renderBox.localToGlobal(Offset.zero);
                            showCopyToast(position);
                            context
                                .read<AndroidDeviceInfoCubit>()
                                .copyAdvertisingId();
                          },
                          child: const Text('Copy'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: Container(
                    height: 225,
                    width: double.infinity,
                    foregroundDecoration: _getDecoration("System"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const <Widget>[
                              Text('CPU Architecture'),
                              Text('CPU Cores'),
                              Text('Memory'),
                              Text('Total Storage Space'),
                              Text('Free Storage Space'),
                              Text('Used Storage Space'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(state.cpu),
                              Text(state.cpuCores),
                              Text(state.totalMemory),
                              Text(state.deviceInfoModel.totalSpace),
                              Text(state.deviceInfoModel.freeSpace),
                              Text(state.deviceInfoModel.usedSpace),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: Container(
                    height: 187.5,
                    width: double.infinity,
                    foregroundDecoration: _getDecoration("Battery"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const <Widget>[
                              Text('Battery Level'),
                              Text('Charging Status'),
                              Text('Temperature'),
                              Text('Health'),
                              Text('Capacity'),
                              Text('Technology'),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Visibility(
                          visible: state.batteryInfoModel != null,
                          child: Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    state.batteryInfoModel?.batteryLevel ?? ''),
                                Text(state.batteryInfoModel?.chargingStatus ??
                                    ''),
                                Text(state.batteryInfoModel?.temperature ?? ''),
                                Text(state.batteryInfoModel?.health ?? ''),
                                Text(state.batteryInfoModel?.capacity ?? ''),
                                Text(state.batteryInfoModel?.technology ?? ''),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );
    } else {
      throw Exception("invalid state=$state");
    }
  }

  Decoration _getDecoration(String text) => RotatedCornerDecoration.withColor(
      color: CupertinoColors.activeBlue,
      badgePosition: BadgePosition.topStart,
      badgeSize: const Size(56, 56),
      badgeCornerRadius: const Radius.circular(8),
      badgeShadow:
          const BadgeShadow(color: CupertinoColors.activeBlue, elevation: 2),
      textSpan: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 12),
      ));

  showCopyToast(Offset positionAnchor) {
    _animationController
        ?.removeStatusListener(snackbarAnimationStatusListener!);
    _animationController?.reset();
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        left: positionAnchor.dx,
        top: positionAnchor.dy + 0.75,
        child: FadeTransition(
          opacity: _animation!,
          child: Container(
            width: MediaQuery.of(context).size.width - 16,
            decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
              child: Center(
                child: Text('Copy Advertising ID Successfully',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: CupertinoColors.white)),
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context).insert(_overlayEntry!);

    _animationController?.addStatusListener(snackbarAnimationStatusListener!);
    _animationController?.forward();
  }
}
