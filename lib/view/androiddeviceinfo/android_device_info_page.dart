import 'dart:async';

import 'package:device_info_tool/l10n/app_localizations.dart';
import 'package:device_info_tool/common/miscellaneous.dart';
import 'package:device_info_tool/theme.dart';
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

  Timer? _scrollEndTimer;
  bool _isScrolling = false;

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
    _scrollEndTimer?.cancel();
    _animationController
      ?..removeStatusListener(snackbarAnimationStatusListener!)
      ..dispose();
    _overlayEntry?.remove();
    context.read<AndroidDeviceInfoCubit>().release();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AndroidDeviceInfoCubit>().state;
    if (state is AndroidDeviceInfoInitial) {
      return Container(
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (state is AndroidDeviceInfoLoaded) {
      return Container(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              // User started scrolling
              if (!_isScrolling) {
                _isScrolling = true;
                context.read<AndroidDeviceInfoCubit>().pauseUpdates();
              }
              // Cancel any pending scroll end timer
              _scrollEndTimer?.cancel();
            } else if (scrollNotification is ScrollUpdateNotification) {
              // User is scrolling or Fling is active
              // Ensure we are in scrolling state
              if (!_isScrolling) {
                _isScrolling = true;
                context.read<AndroidDeviceInfoCubit>().pauseUpdates();
              }
              // Reset the timer each time there's a scroll update (including Fling)
              _scrollEndTimer?.cancel();
            } else if (scrollNotification is ScrollEndNotification) {
              // Finger lifted, but Fling might still be active
              // Wait longer to ensure Fling completely stops
              _scrollEndTimer?.cancel();
              _scrollEndTimer = Timer(const Duration(milliseconds: 800), () {
                if (_isScrolling) {
                  _isScrolling = false;
                  context.read<AndroidDeviceInfoCubit>().resumeUpdates();
                }
              });
            }
            return false;
          },
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
                    foregroundDecoration: getDecoration("Device", context),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: Theme.of(context).containerBorderColor()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(l10n.brand),
                              Text(l10n.model),
                              Text(l10n.androidOsName),
                              Text(l10n.apiLevel),
                              Text(l10n.securityPatch),
                              Text(l10n.developerOptions),
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
                              Text(state.isDeveloper ? l10n.enabled : l10n.disabled),
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
                    foregroundDecoration: getDecoration("Display", context),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: Theme.of(context).containerBorderColor()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(l10n.screenSizePx),
                              Text(l10n.screenSizeDp),
                              Text(l10n.screenSizeInch),
                              Text(l10n.screenAspectRatio),
                              Text(l10n.xdpi),
                              Text(l10n.ydpi),
                              Text(l10n.screenDensity),
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
                    height: 62.5,
                    width: double.infinity,
                    foregroundDecoration: getDecoration("Network", context),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: Theme.of(context).containerBorderColor()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(l10n.ipAddress),
                              Text(l10n.connectivity),
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
              _buildCpuDetailsSection(context, state),
              _buildStorageInfoSection(context, state),
              _buildBatteryInfoSection(context, state),
              // 以下兩個資訊用戶較少關心，先註解掉
              // _buildNetworkDetailsSection(context, state),
              // _buildSystemDetailsSection(context, state),
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
                          color: Theme.of(context).containerBorderColor()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(l10n.adId),
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
                          child: Text(l10n.copy,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0, bottom: 8.0),
                  child: Container(
                    key: androidIdContainerKey,
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          width: 1.5,
                          color: Theme.of(context).containerBorderColor()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(l10n.androidId),
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
                          child: Text(l10n.copy,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        ),
      );
    } else {
      throw Exception("invalid state=$state");
    }
  }

  Widget _buildBatteryInfoSection(BuildContext context, AndroidDeviceInfoLoaded state) {
    final l10n = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: Container(
          height: 175,
          width: double.infinity,
          foregroundDecoration: getDecoration("Battery", context),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                width: 1.5,
                color: Theme.of(context).containerBorderColor()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(l10n.capacity),
                    Text(l10n.health),
                    Text(l10n.chargingStatus),
                    Text(l10n.temperature),
                    Text(l10n.batteryLevel),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Visibility(
                visible: state.batteryInfoModel != null,
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(state.batteryInfoModel?.capacity ?? ''),
                      Text(state.batteryInfoModel?.health ?? ''),
                      Text(state.batteryInfoModel?.chargingStatus ?? ''),
                      Text(state.batteryInfoModel?.temperature ?? ''),
                      Text(state.batteryInfoModel?.batteryLevel ?? ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStorageInfoSection(BuildContext context, AndroidDeviceInfoLoaded state) {
    final l10n = AppLocalizations.of(context);
    final storageModel = state.storageInfoModel;
    final usedPercentage = storageModel?.getUsedPercentage() ?? '';
    final availablePercentage = storageModel?.getAvailablePercentage() ?? '';

    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: Container(
          height: 125,
          width: double.infinity,
          foregroundDecoration: getDecoration("Storage", context),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                width: 1.5,
                color: Theme.of(context).containerBorderColor()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(l10n.totalSpace),
                    Text(l10n.usedSpace),
                    Text(l10n.availableSpace),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(storageModel?.internalTotalSpace ?? ''),
                    Text('${storageModel?.internalUsedSpace ?? ''} ${usedPercentage.isNotEmpty ? '($usedPercentage)' : ''}'),
                    Text('${storageModel?.internalAvailableSpace ?? ''} ${availablePercentage.isNotEmpty ? '($availablePercentage)' : ''}'),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildNetworkDetailsSection(BuildContext context, AndroidDeviceInfoLoaded state) {
    final l10n = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: Container(
          height: 125,
          width: double.infinity,
          foregroundDecoration: getDecoration("Network Details", context),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                width: 1.5,
                color: Theme.of(context).containerBorderColor()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(l10n.networkType),
                    Text(l10n.networkSubtype),
                    Text(l10n.networkState),
                    Text(l10n.isRoaming),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(state.networkInfoModel?.networkType ?? ''),
                    Text(state.networkInfoModel?.networkSubtype ?? ''),
                    Text(state.networkInfoModel?.networkState ?? ''),
                    Text(state.networkInfoModel?.isRoaming ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSystemDetailsSection(BuildContext context, AndroidDeviceInfoLoaded state) {
    final l10n = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: Container(
          height: 300,
          width: double.infinity,
          foregroundDecoration: getDecoration("System Details", context),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                width: 1.5,
                color: Theme.of(context).containerBorderColor()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(l10n.deviceName),
                    Text(l10n.product),
                    Text(l10n.board),
                    Text(l10n.hardware),
                    Text(l10n.bootloader),
                    Text(l10n.deviceType),
                    Text(l10n.radioVersion),
                    Text(l10n.systemLocale),
                    Text(l10n.timeZone),
                    Text(l10n.supportedAbis),
                    Text(l10n.support64Bit),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FittedBox(child: Text(state.systemInfoModel?.deviceName ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.deviceProduct ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.deviceBoard ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.deviceHardware ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.deviceBootloader ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.deviceType ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.deviceRadioVersion ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.systemLocale ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.systemTimeZone ?? '')),
                    FittedBox(child: Text(state.systemInfoModel?.supportedABIs ?? '')),
                    Text(state.systemInfoModel?.is64Bit ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCpuDetailsSection(BuildContext context, AndroidDeviceInfoLoaded state) {
    final l10n = AppLocalizations.of(context);
    final cpuModel = state.cpuInfoModel;
    final usedMemoryPercentage = cpuModel?.getUsedMemoryPercentage() ?? '';
    final availableMemoryPercentage = cpuModel?.getAvailableMemoryPercentage() ?? '';

    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0, bottom: 8.0),
        child: Container(
          height: 200,
          width: double.infinity,
          foregroundDecoration: getDecoration("System", context),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                width: 1.5,
                color: Theme.of(context).containerBorderColor()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(l10n.architecture),
                    Text(l10n.coreCount),
                    Text(l10n.totalMemory),
                    Text(l10n.usedMemory),
                    Text(l10n.availableMemory),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(cpuModel?.cpuArchitecture ?? ''),
                    Text(cpuModel?.cpuCoreCount ?? ''),
                    Text(cpuModel?.totalMemory ?? ''),
                    Text('${cpuModel?.usedMemory ?? ''} ${usedMemoryPercentage.isNotEmpty ? '($usedMemoryPercentage)' : ''}'),
                    Text('${cpuModel?.availableMemory ?? ''} ${availableMemoryPercentage.isNotEmpty ? '($availableMemoryPercentage)' : ''}'),
                  ],
                ),
              ),
            ],
          ),
        ));
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
                color: Theme.of(context).toastBackgroundColor(),
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
