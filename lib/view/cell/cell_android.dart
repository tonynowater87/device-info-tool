import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_info_tool/data/model/VersionModelAndroid.dart';
import 'package:device_info_tool/common/android_version_doc.dart';
import 'package:device_info_tool/l10n/app_localizations.dart';
import 'package:device_info_tool/theme.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:url_launcher_android/url_launcher_android.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

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

  Future<void> _openDoc(String url) async {
    final launcher = UrlLauncherAndroid();
    const options = LaunchOptions(mode: PreferredLaunchMode.platformDefault);
    await launcher.launchUrl(url, options);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 只有 Android 5+ 才有官方頁面；連結開啟目前僅支援 Android 裝置。
    final docUrl = AndroidVersionDoc.urlFor(
      versionModelAndroid.version,
      versionModelAndroid.codeName,
      localeCode: l10n.locale.toString(),
    );
    final canOpenDoc = docUrl != null && Platform.isAndroid;

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

    final cell = Container(
      height: 150,
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
          if (canOpenDoc)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Icon(Icons.open_in_new, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      l10n.androidVersionDoc,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
      child: canOpenDoc
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openDoc(docUrl),
              child: cell,
            )
          : cell,
    );
  }
}
