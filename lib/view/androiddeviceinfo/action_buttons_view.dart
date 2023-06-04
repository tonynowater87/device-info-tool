import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

class ActionButtonsView extends StatelessWidget {
  const ActionButtonsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        OutlinedButton(
          onPressed: () {
            if (Platform.isAndroid) {
              AndroidIntent intent = const AndroidIntent(
                action: 'android.settings.DEVICE_INFO_SETTINGS',
              );
              intent.launch();
            }
          },
          child: const Text('Go About Page'),
        ),
        const SizedBox(
          width: 10,
        ),
        OutlinedButton(
          onPressed: () {
            if (Platform.isAndroid) {
              AndroidIntent intent = const AndroidIntent(
                action: 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS',
              );
              intent.launch();
            }
          },
          child: const Text('Go Developer Options Page'),
        ),
        const SizedBox(
          width: 10,
        ),
        OutlinedButton(
          onPressed: () {
            if (Platform.isAndroid) {
              AndroidIntent intent = const AndroidIntent(
                action: 'android.settings.LOCALE_SETTINGS',
              );
              intent.launch();
            }
          },
          child: const Text('Go Languages Page'),
        ),
        const SizedBox(
          width: 10,
        ),
        OutlinedButton(
          onPressed: () {
            if (Platform.isAndroid) {
              AndroidIntent intent = const AndroidIntent(
                action: 'android.settings.MANAGE_ALL_APPLICATIONS_SETTINGS',
              );
              intent.launch();
            }
          },
          child: const Text('Go All Apps Page'),
        )
      ],
    );
  }
}
