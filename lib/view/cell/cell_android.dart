import 'package:flutter/cupertino.dart';
import 'package:device_info_tool/data/model/VersionModelAndroid.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class CellAndroidView extends StatelessWidget {
  final VersionModelAndroid versionModelAndroid;
  final bool isLatest;
  final bool isHighlighted;

  const CellAndroidView(
      {Key? key,
      required this.versionModelAndroid,
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
          color: CupertinoColors.activeBlue,
          badgeSize: const Size(112, 56),
          badgeCornerRadius: const Radius.circular(8),
          badgeShadow: const BadgeShadow(
              color: CupertinoColors.activeBlue, elevation: 2),
          textSpan: TextSpan(
            text: text,
            style: const TextStyle(fontSize: 12),
          ));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
      child: Container(
        height: 150,
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
                children: const <Widget>[
                  Text('Android'),
                  Text('API Level'),
                  Text('Code Name'),
                  Text('Release Date'),
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
                Text(versionModelAndroid.version),
                Text(versionModelAndroid.apiLevel),
                Text(versionModelAndroid.codeName),
                Text(versionModelAndroid.releaseDate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
