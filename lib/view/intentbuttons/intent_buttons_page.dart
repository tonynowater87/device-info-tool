import 'package:device_info_tool/data/intent_order_provider.dart';
import 'package:device_info_tool/theme.dart';
import 'package:device_info_tool/view/intentbuttons/action_buttons_view.dart';
import 'package:device_info_tool/view/intentbuttons/intent_action_model.dart';
import 'package:flutter/material.dart';

class IntentButtonsPage extends StatefulWidget {
  const IntentButtonsPage({Key? key}) : super(key: key);

  @override
  State<IntentButtonsPage> createState() => IntentButtonsPageState();
}

class IntentButtonsPageState extends State<IntentButtonsPage> {
  final IntentOrderProvider _orderProvider = IntentOrderProvider();
  List<IntentActionModel> _actions = [];
  bool _isLoading = true;

  // Default actions with expanded developer-useful options
  List<IntentActionModel> get _defaultActions => [
    IntentActionModel(
        id: 'settings',
        buttonText: 'Settings Page', 
        action: 'android.settings.SETTINGS'),
    IntentActionModel(
        id: 'developer_options',
        buttonText: 'Developer Options Page',
        action: 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS'),
    IntentActionModel(
        id: 'app_info',
        buttonText: 'App Info & Permissions',
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS'),
    IntentActionModel(
        id: 'usage_access',
        buttonText: 'Usage Access Settings',
        action: 'android.settings.USAGE_ACCESS_SETTINGS'),
    IntentActionModel(
        id: 'overlay_settings',
        buttonText: 'Display Over Other Apps',
        action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION'),
    IntentActionModel(
        id: 'write_settings',
        buttonText: 'Modify System Settings',
        action: 'android.settings.action.MANAGE_WRITE_SETTINGS'),
    IntentActionModel(
        id: 'unknown_sources',
        buttonText: 'Install Unknown Apps',
        action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES'),
    IntentActionModel(
        id: 'notification_policy',
        buttonText: 'Do Not Disturb Access',
        action: 'android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS'),
    IntentActionModel(
        id: 'locale',
        buttonText: 'Locale & Language', 
        action: 'android.settings.LOCALE_SETTINGS'),
    IntentActionModel(
        id: 'all_apps',
        buttonText: 'All Applications',
        action: 'android.settings.MANAGE_ALL_APPLICATIONS_SETTINGS'),
    IntentActionModel(
        id: 'wifi',
        buttonText: 'WiFi Settings', 
        action: 'android.settings.WIFI_SETTINGS'),
    IntentActionModel(
        id: 'bluetooth',
        buttonText: 'Bluetooth Settings',
        action: 'android.settings.BLUETOOTH_SETTINGS'),
    IntentActionModel(
        id: 'date_time',
        buttonText: 'Date & Time', 
        action: 'android.settings.DATE_SETTINGS'),
    IntentActionModel(
        id: 'display',
        buttonText: 'Display Settings',
        action: 'android.settings.DISPLAY_SETTINGS'),
    IntentActionModel(
        id: 'accessibility',
        buttonText: 'Accessibility Settings',
        action: 'android.settings.ACCESSIBILITY_SETTINGS'),
    IntentActionModel(
        id: 'device_info',
        buttonText: 'About Device',
        action: 'android.settings.DEVICE_INFO_SETTINGS'),
    IntentActionModel(
        id: 'notifications',
        buttonText: 'Notification Settings',
        action: 'android.settings.NOTIFICATION_SETTINGS'),
    IntentActionModel(
        id: 'default_apps',
        buttonText: 'Default Apps',
        action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS'),
    IntentActionModel(
        id: 'sound',
        buttonText: 'Sound Settings', 
        action: 'android.settings.SOUND_SETTINGS'),
    IntentActionModel(
        id: 'storage',
        buttonText: 'Storage Settings',
        action: 'android.settings.INTERNAL_STORAGE_SETTINGS'),
    IntentActionModel(
        id: 'battery',
        buttonText: 'Battery & Power Saving',
        action: 'android.settings.BATTERY_SAVER_SETTINGS'),
    IntentActionModel(
        id: 'location',
        buttonText: 'Location Services',
        action: 'android.settings.LOCATION_SOURCE_SETTINGS'),
    IntentActionModel(
        id: 'security',
        buttonText: 'Security Settings',
        action: 'android.settings.SECURITY_SETTINGS'),
    IntentActionModel(
        id: 'privacy',
        buttonText: 'Privacy Settings',
        action: 'android.settings.PRIVACY_SETTINGS'),
    IntentActionModel(
        id: 'nfc',
        buttonText: 'NFC Settings', 
        action: 'android.settings.NFC_SETTINGS'),
    IntentActionModel(
        id: 'accounts',
        buttonText: 'Accounts & Sync', 
        action: 'android.settings.SYNC_SETTINGS'),
    IntentActionModel(
        id: 'search',
        buttonText: 'Search Settings',
        action: 'android.search.action.SEARCH_SETTINGS'),
    IntentActionModel(
        id: 'system_update',
        buttonText: 'System Update',
        action: 'android.settings.SYSTEM_UPDATE_SETTINGS'),
    IntentActionModel(
        id: 'biometric',
        buttonText: 'Biometric Enrollment',
        action: 'android.settings.BIOMETRIC_ENROLL'),
    IntentActionModel(
        id: 'cast',
        buttonText: 'Cast Settings', 
        action: 'android.settings.CAST_SETTINGS'),
    IntentActionModel(
        id: 'webview',
        buttonText: 'WebView Implementation',
        action: 'android.settings.WEBVIEW_SETTINGS'),
  ];

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    final savedActions = await _orderProvider.getIntentOrder();
    setState(() {
      if (savedActions != null && savedActions.isNotEmpty) {
        // Merge saved order with new default actions
        _actions = _mergeActionsWithDefaults(savedActions);
      } else {
        _actions = List.from(_defaultActions);
      }
      _isLoading = false;
    });
  }

  List<IntentActionModel> _mergeActionsWithDefaults(List<IntentActionModel> savedActions) {
    final defaultActionMap = {for (var action in _defaultActions) action.id: action};
    final savedActionIds = savedActions.map((action) => action.id).toSet();
    
    // Start with saved actions that still exist in defaults
    final mergedActions = <IntentActionModel>[];
    for (var savedAction in savedActions) {
      if (defaultActionMap.containsKey(savedAction.id)) {
        mergedActions.add(defaultActionMap[savedAction.id]!);
      }
    }
    
    // Add any new default actions that weren't in saved list
    for (var defaultAction in _defaultActions) {
      if (!savedActionIds.contains(defaultAction.id)) {
        mergedActions.add(defaultAction);
      }
    }
    
    return mergedActions;
  }

  Future<void> _saveOrder() async {
    await _orderProvider.saveIntentOrder(_actions);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _actions.removeAt(oldIndex);
      _actions.insert(newIndex, item);
    });
    _saveOrder();
  }

  Future<void> resetOrder() async {
    setState(() {
      _actions = List.from(_defaultActions);
    });
    await _saveOrder();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  width: 1.5, color: Theme.of(context).containerBorderColor()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ActionButtonsView(
                actions: _actions,
                onReorder: _onReorder,
              ),
            )));
  }
}
