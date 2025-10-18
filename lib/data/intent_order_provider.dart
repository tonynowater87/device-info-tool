import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_tool/view/intentbuttons/intent_action_model.dart';

class IntentOrderProvider {
  static const String _keyIntentOrder = 'intent_actions_order';

  Future<void> saveIntentOrder(List<IntentActionModel> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = actions.map((action) => action.toJson()).toList();
    await prefs.setString(_keyIntentOrder, jsonEncode(jsonList));
  }

  Future<List<IntentActionModel>?> getIntentOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyIntentOrder);
    
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => IntentActionModel.fromJson(json)).toList();
    }
    return null;
  }

  Future<void> clearIntentOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIntentOrder);
  }
}