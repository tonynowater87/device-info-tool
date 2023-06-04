import 'package:flutter/cupertino.dart';
import 'package:device_info_tool/data/model/VersionModelAndroidWearOS.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class CellAndroidWearOSView extends StatelessWidget {
  final VersionModelAndroidWearOs versionModelAndroidWearOS;
  final bool isLatest;

  const CellAndroidWearOSView(
      {Key? key,
      required this.versionModelAndroidWearOS,
      required this.isLatest})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Decoration? decoration;
    if (isLatest) {
      decoration = const RotatedCornerDecoration.withColor(
          color: CupertinoColors.activeBlue,
          badgeSize: Size(112, 56),
          badgeCornerRadius: Radius.circular(8),
          badgeShadow:
              BadgeShadow(color: CupertinoColors.activeBlue, elevation: 2),
          textSpan: TextSpan(
            text: '  Latest\nVersion',
            style: TextStyle(fontSize: 12),
          ));
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
      child: Container(
        height: 112.5,
        foregroundDecoration: decoration,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
                width: 1.5, color: CupertinoColors.activeBlue.withAlpha(100))),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(versionModelAndroidWearOS.osName),
                  const Text('Based on Android'),
                  const Text('Release Date'),
                ],
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(versionModelAndroidWearOS.version),
                Text(versionModelAndroidWearOS.androidos),
                Text(versionModelAndroidWearOS.releasedate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
