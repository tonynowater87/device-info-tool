import 'package:device_info_tool/common/miscellaneous.dart';
import 'package:device_info_tool/view/androiddeviceinfo/android_device_info_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AndroidDeviceInfoPage extends StatefulWidget {
  const AndroidDeviceInfoPage({Key? key}) : super(key: key);

  @override
  State<AndroidDeviceInfoPage> createState() => _AndroidDeviceInfoPageState();
}

class _AndroidDeviceInfoPageState extends State<AndroidDeviceInfoPage>
    with SingleTickerProviderStateMixin {
  final adidContainerKey = GlobalKey();
  final androidIdContainerKey = GlobalKey();
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
                    height: 187.5,
                    width: double.infinity,
                    foregroundDecoration: getDecoration("Device"),
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
                    height: 200,
                    width: double.infinity,
                    foregroundDecoration: getDecoration("Display"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('Screen Size (px)'),
                              Text('Screen Size (dp)'),
                              Text('Screen Size (inch)'),
                              Text('Screen Aspect Ratio'),
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
                              Text(state.deviceInfoModel.screenDpSize),
                              Text(state.deviceInfoModel.screenInch),
                              Text(state.deviceInfoModel.screenRatio),
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
                    key: adidContainerKey,
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
                              Text('AD ID'),
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
                            RenderBox renderBox = (adidContainerKey
                                .currentContext!
                                .findRenderObject() as RenderBox);
                            Offset position =
                                renderBox.localToGlobal(Offset.zero);
                            showCopyToast(
                                position, 'Copy Advertising ID Successfully');
                            context
                                .read<AndroidDeviceInfoCubit>()
                                .copyAdvertisingId();
                          },
                          child: Text('Copy',
                              style: Theme.of(context).textTheme.bodyText2),
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
                    key: androidIdContainerKey,
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
                              Text('Android ID'),
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
                              FittedBox(child: Text(state.androidId)),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            RenderBox renderBox = (androidIdContainerKey
                                .currentContext!
                                .findRenderObject() as RenderBox);
                            Offset position =
                                renderBox.localToGlobal(Offset.zero);
                            showCopyToast(
                                position, 'Copy Android ID Successfully');
                            context
                                .read<AndroidDeviceInfoCubit>()
                                .copyAndroidId();
                          },
                          child: Text('Copy',
                              style: Theme.of(context).textTheme.bodyText2),
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
                    height: 62.5,
                    width: double.infinity,
                    foregroundDecoration: getDecoration("Network"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('IP Address'),
                              Text('Connectivity'),
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
                              Text(state.wifiIp),
                              Text(state.connectivities),
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
                    height: 157.5,
                    width: double.infinity,
                    foregroundDecoration: getDecoration("System"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text('CPU Architecture'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text('CPU Cores'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text('Memory'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text('Storage'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text(state.cpu),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text(state.cpuCores),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text(state.totalMemory),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text(state.storageInfo),
                              ),
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
                    foregroundDecoration: getDecoration("Battery"),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: CupertinoColors.activeBlue.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
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

  showCopyToast(Offset positionAnchor, String text) {
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
                child: Text(text,
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
