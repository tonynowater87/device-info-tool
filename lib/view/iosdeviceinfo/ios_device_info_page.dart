import 'package:device_info_tool/common/miscellaneous.dart';
import 'package:device_info_tool/view/iosdeviceinfo/ios_device_info_cubit.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IosDeviceInfoPage extends StatefulWidget {
  const IosDeviceInfoPage({super.key});

  @override
  State<IosDeviceInfoPage> createState() => _IosDeviceInfoPageState();
}

class _IosDeviceInfoPageState extends State<IosDeviceInfoPage> with SingleTickerProviderStateMixin {

  final identifierContainerKey = GlobalKey();
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
    context.read<IosDeviceInfoCubit>().load();
  }

  @override
  void deactivate() {
    _animationController
      ?..removeStatusListener(snackbarAnimationStatusListener!)
      ..dispose();
    _overlayEntry?.remove();
    super.deactivate();
  }

  @override
  Widget build(BuildContext buildContext) {
    debugPrint('[Tony] IosDeviceInfoPage, build');
    return DisplayMetricsWidget(
      child: BlocConsumer<IosDeviceInfoCubit, IosDeviceInfoState>(
          listener: (context, state) {
        debugPrint('[Tony] IosDeviceInfoPage, state: $state');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          context.read<IosDeviceInfoCubit>().loadContext(context);
        });
      }, builder: (context, state) {
        if (state.brand.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                    child: Container(
                      height: 140.6,
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
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text('Brand'),
                                Text('Model'),
                                Text('SystemVersion'),
                                Text('IsPhysicalDevice'),
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
                                Text(state.brand),
                                Text(state.model),
                                Text(state.systemVersion),
                                Text(state.isPhysicalDevice.toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                // Padding(
                //     padding:
                //         const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                //     child: Container(
                //       height: 200.5,
                //       width: double.infinity,
                //       foregroundDecoration: getDecoration("utsname"),
                //       decoration: BoxDecoration(
                //         borderRadius: const BorderRadius.all(Radius.circular(8)),
                //         border: Border.all(
                //             width: 1.5,
                //             color: CupertinoColors.activeBlue.withAlpha(100)),
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: <Widget>[
                //           const Expanded(
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                //               crossAxisAlignment: CrossAxisAlignment.end,
                //               children: <Widget>[
                //                 Text('sysname'),
                //                 Text('nodename'),
                //                 Text('release'),
                //                 Text('machine'),
                //                 Text('version'),
                //               ],
                //             ),
                //           ),
                //           const SizedBox(
                //             width: 20,
                //           ),
                //           Expanded(
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: <Widget>[
                //                 Text(state.sysName),
                //                 Text(state.nodeName),
                //                 Text(state.release),
                //                 Text(state.machine),
                //                 Text(state.version),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     )),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                    child: Container(
                      height: 125,
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
                                Text('Resolution'),
                                Text('Screen Size in Pt'),
                                Text('Screen Inch'),
                                Text('PPI'),
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
                                Text(state.resolution),
                                Text(state.screenPt),
                                Text(state.inch),
                                Text(state.ppi),
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
                                Text('Wifi IP'),
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
                      height: 62.5,
                      width: double.infinity,
                      foregroundDecoration: getDecoration("Hardware"),
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
                                Text('RAM'),
                                Text('Storage'),
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
                                Text(state.totalMemoryInGB),
                                FittedBox(child: Text(state.storageInfo)),
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
                      key: identifierContainerKey,
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
                          const Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text('Identifier'),
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
                                FittedBox(child: Text(state.identifierForVendor)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              RenderBox renderBox = (identifierContainerKey
                                  .currentContext!
                                  .findRenderObject() as RenderBox);
                              Offset position =
                              renderBox.localToGlobal(Offset.zero);
                              showCopyToast(
                                  position, 'Copy Identifier Successfully');
                              Clipboard.setData(ClipboardData(
                                  text: state.identifierForVendor));
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
              ],
            ),
          );
        }
      }),
    );
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
