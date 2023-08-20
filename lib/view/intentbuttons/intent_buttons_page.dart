import 'package:device_info_tool/view/intentbuttons/action_buttons_view.dart';
import 'package:device_info_tool/view/intentbuttons/intent_action_model.dart';
import 'package:flutter/cupertino.dart';

class IntentButtonsPage extends StatelessWidget {
  List<IntentActionModel> actions = [
    IntentActionModel(
        buttonText: 'Settings Page', action: 'android.settings.SETTINGS'),
    IntentActionModel(
        buttonText: 'Developer Options Page',
        action: 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS'),
    IntentActionModel(
        buttonText: 'Locale Page', action: 'android.settings.LOCALE_SETTINGS'),
    IntentActionModel(
        buttonText: 'All Application Page',
        action: 'android.settings.MANAGE_ALL_APPLICATIONS_SETTINGS'),
    IntentActionModel(
        buttonText: 'Wifi Page', action: 'android.settings.WIFI_SETTINGS'),
    IntentActionModel(
        buttonText: 'Bluetooth Page',
        action: 'android.settings.BLUETOOTH_SETTINGS'),
    IntentActionModel(
        buttonText: 'Date Time Page', action: 'android.settings.DATE_SETTINGS'),
    IntentActionModel(
        buttonText: 'Display Page',
        action: 'android.settings.DISPLAY_SETTINGS'),
    IntentActionModel(
        buttonText: 'Accessibility Page',
        action: 'android.settings.ACCESSIBILITY_SETTINGS'),
    IntentActionModel(
        buttonText: 'About Page',
        action: 'android.settings.DEVICE_INFO_SETTINGS'),
    IntentActionModel(
        buttonText: 'Notification Page',
        action: 'android.settings.NOTIFICATION_SETTINGS'),
    IntentActionModel(
        buttonText: 'Open By Default Page',
        action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS'),
    IntentActionModel(
        buttonText: 'Sound Page', action: 'android.settings.SOUND_SETTINGS'),
    IntentActionModel(
        buttonText: 'Storage Page',
        action: 'android.settings.INTERNAL_STORAGE_SETTINGS'),
    IntentActionModel(
        buttonText: 'Battery Page',
        action: 'android.settings.BATTERY_SAVER_SETTINGS'),
    IntentActionModel(
        buttonText: 'Location Page',
        action: 'android.settings.LOCATION_SOURCE_SETTINGS'),
    IntentActionModel(
        buttonText: 'Security Page',
        action: 'android.settings.SECURITY_SETTINGS'),
    IntentActionModel(
        buttonText: 'Privacy Page',
        action: 'android.settings.PRIVACY_SETTINGS'),
    IntentActionModel(
        buttonText: 'NFC Page', action: 'android.settings.NFC_SETTINGS'),
    IntentActionModel(
        buttonText: 'Account Page', action: 'android.settings.SYNC_SETTINGS'),
    IntentActionModel(
        buttonText: 'Search Page',
        action: 'android.search.action.SEARCH_SETTINGS'),
    IntentActionModel(
        buttonText: 'System Update Page',
        action: 'android.settings.SYSTEM_UPDATE_SETTINGS'),
    IntentActionModel(
        buttonText: 'Bio Metric Page',
        action: 'android.settings.BIOMETRIC_ENROLL'),
    IntentActionModel(
        buttonText: 'Cast Page', action: 'android.settings.CAST_SETTINGS'),
    IntentActionModel(
        buttonText: 'Web View Page',
        action: 'android.settings.WEBVIEW_SETTINGS'),
  ];

  IntentButtonsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  width: 1.5, color: CupertinoColors.activeBlue.withAlpha(100)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ActionButtonsView(actions: actions),
            )));
  }
}
