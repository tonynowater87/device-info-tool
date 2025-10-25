import 'package:device_info_tool/data/intent_order_provider.dart';
import 'package:device_info_tool/l10n/app_localizations.dart';
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
  List<IntentActionModel> _defaultActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      IntentActionModel(
          id: 'settings',
          buttonText: l10n.intentSettings, 
          action: 'android.settings.SETTINGS'),
      IntentActionModel(
          id: 'developer_options',
          buttonText: l10n.intentDeveloperOptions,
          action: 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS'),
      IntentActionModel(
          id: 'app_info',
          buttonText: l10n.intentAppInfo,
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS'),
      IntentActionModel(
          id: 'usage_access',
          buttonText: l10n.intentUsageAccess,
          action: 'android.settings.USAGE_ACCESS_SETTINGS'),
      IntentActionModel(
          id: 'overlay_settings',
          buttonText: l10n.intentDisplayOverApps,
          action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION'),
      IntentActionModel(
          id: 'write_settings',
          buttonText: l10n.intentModifySystem,
          action: 'android.settings.action.MANAGE_WRITE_SETTINGS'),
      IntentActionModel(
          id: 'unknown_sources',
          buttonText: l10n.intentInstallUnknown,
          action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES'),
      IntentActionModel(
          id: 'notification_policy',
          buttonText: l10n.intentDoNotDisturb,
          action: 'android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS'),
      IntentActionModel(
          id: 'locale',
          buttonText: l10n.intentLocale, 
          action: 'android.settings.LOCALE_SETTINGS'),
      IntentActionModel(
          id: 'all_apps',
          buttonText: l10n.intentAllApps,
          action: 'android.settings.MANAGE_ALL_APPLICATIONS_SETTINGS'),
      IntentActionModel(
          id: 'wifi',
          buttonText: l10n.intentWifi, 
          action: 'android.settings.WIFI_SETTINGS'),
      IntentActionModel(
          id: 'bluetooth',
          buttonText: l10n.intentBluetooth,
          action: 'android.settings.BLUETOOTH_SETTINGS'),
      IntentActionModel(
          id: 'date_time',
          buttonText: l10n.intentDateTime, 
          action: 'android.settings.DATE_SETTINGS'),
      IntentActionModel(
          id: 'display',
          buttonText: l10n.intentDisplay,
          action: 'android.settings.DISPLAY_SETTINGS'),
      IntentActionModel(
          id: 'accessibility',
          buttonText: l10n.intentAccessibility,
          action: 'android.settings.ACCESSIBILITY_SETTINGS'),
      IntentActionModel(
          id: 'device_info',
          buttonText: l10n.intentAboutDevice,
          action: 'android.settings.DEVICE_INFO_SETTINGS'),
      IntentActionModel(
          id: 'notifications',
          buttonText: l10n.intentNotifications,
          action: 'android.settings.NOTIFICATION_SETTINGS'),
      IntentActionModel(
          id: 'default_apps',
          buttonText: l10n.intentDefaultApps,
          action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS'),
      IntentActionModel(
          id: 'sound',
          buttonText: l10n.intentSound, 
          action: 'android.settings.SOUND_SETTINGS'),
      IntentActionModel(
          id: 'storage',
          buttonText: l10n.intentStorage,
          action: 'android.settings.INTERNAL_STORAGE_SETTINGS'),
      IntentActionModel(
          id: 'battery',
          buttonText: l10n.intentBattery,
          action: 'android.settings.BATTERY_SAVER_SETTINGS'),
      IntentActionModel(
          id: 'location',
          buttonText: l10n.intentLocation,
          action: 'android.settings.LOCATION_SOURCE_SETTINGS'),
      IntentActionModel(
          id: 'security',
          buttonText: l10n.intentSecurity,
          action: 'android.settings.SECURITY_SETTINGS'),
      IntentActionModel(
          id: 'privacy',
          buttonText: l10n.intentPrivacy,
          action: 'android.settings.PRIVACY_SETTINGS'),
      IntentActionModel(
          id: 'nfc',
          buttonText: l10n.intentNfc, 
          action: 'android.settings.NFC_SETTINGS'),
      IntentActionModel(
          id: 'accounts',
          buttonText: l10n.intentAccounts, 
          action: 'android.settings.SYNC_SETTINGS'),
      IntentActionModel(
          id: 'search',
          buttonText: l10n.intentSearch,
          action: 'android.search.action.SEARCH_SETTINGS'),
      IntentActionModel(
          id: 'system_update',
          buttonText: l10n.intentSystemUpdate,
          action: 'android.settings.SYSTEM_UPDATE_SETTINGS'),
      IntentActionModel(
          id: 'biometric',
          buttonText: l10n.intentBiometric,
          action: 'android.settings.BIOMETRIC_ENROLL'),
      IntentActionModel(
          id: 'cast',
          buttonText: l10n.intentCast, 
          action: 'android.settings.CAST_SETTINGS'),
      IntentActionModel(
          id: 'webview',
          buttonText: l10n.intentWebview,
          action: 'android.settings.WEBVIEW_SETTINGS'),
    ];
  }

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
        _actions = List.from(_defaultActions(context));
      }
      _isLoading = false;
    });
  }

  List<IntentActionModel> _mergeActionsWithDefaults(List<IntentActionModel> savedActions) {
    final defaultActions = _defaultActions(context);
    final defaultActionMap = {for (var action in defaultActions) action.id: action};
    final savedActionIds = savedActions.map((action) => action.id).toSet();
    
    // Start with saved actions that still exist in defaults
    final mergedActions = <IntentActionModel>[];
    for (var savedAction in savedActions) {
      if (defaultActionMap.containsKey(savedAction.id)) {
        mergedActions.add(defaultActionMap[savedAction.id]!);
      }
    }
    
    // Add any new default actions that weren't in saved list
    for (var defaultAction in defaultActions) {
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
      _actions = List.from(_defaultActions(context));
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
