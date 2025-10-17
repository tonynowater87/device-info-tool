import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info_tool/data/DeviceVersionProvider.dart';
import 'package:device_info_tool/theme.dart';
import 'package:device_info_tool/view/ios/ui_model_ios.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class CellIOSView extends StatelessWidget {
  final UiModelIOS versionModeliOs;
  final bool isLatest;
  final bool isHighlighted;

  const CellIOSView(
      {Key? key,
      required this.versionModeliOs,
      required this.isHighlighted,
      required this.isLatest})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Decoration? decoration;
    if (isLatest || isHighlighted) {
      String text = "";
      if (isLatest) {
        text = '  Latest\nVersion';
      }
      if (isHighlighted) {
        text = '  Current\nDevice Version';
      }

      decoration = RotatedCornerDecoration.withColor(
          color: Theme.of(context).badgeColor(),
          badgeSize: const Size(112, 56),
          badgeCornerRadius: const Radius.circular(8),
          badgeShadow: BadgeShadow(
              color: Theme.of(context).badgeShadowColor(), elevation: 2),
          textSpan: TextSpan(
            text: text,
            style: const TextStyle(fontSize: 12),
          ));
    }

    double cellHeight = 150;
    var titles = <Widget>[
      Text(_getTitle()),
      const Text('Release Date'),
      const Text('Latest Version'),
      const Text('Latest Release Date'),
    ];
    var values = <Widget>[
      Text(versionModeliOs.deviceType == DeviceType.mac
          ? "${versionModeliOs.versionName} ${versionModeliOs.version}"
          : versionModeliOs.version),
      Text(versionModeliOs.initialReleaseDate),
      Text(versionModeliOs.latestVersion),
      Text(versionModeliOs.latestReleaseDate),
    ];
    if (versionModeliOs.deviceType == DeviceType.appleWatch) {
      cellHeight = 187.5;
      titles.add(const Text('iOS Version based on'));
      values.add(Text(versionModeliOs.baseOnIOSVersion ?? ""));
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
      child: Container(
        height: cellHeight,
        foregroundDecoration: decoration,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                width: 1.5, color: Theme.of(context).containerBorderColor())),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: titles,
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: values),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (versionModeliOs.deviceType) {
      case DeviceType.iPhone:
        return "iOS";
      case DeviceType.iPad:
        return "iPadOS";
      case DeviceType.mac:
        return "macOS";
      case DeviceType.appleTv:
        return "tvOS";
      case DeviceType.appleWatch:
        return "watchOS";
      default:
        throw Exception(
            "not expected device type in here (${versionModeliOs.deviceType})");
    }
  }
}
