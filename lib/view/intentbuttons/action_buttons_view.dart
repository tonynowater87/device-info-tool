import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_tool/view/intentbuttons/intent_action_model.dart';
import 'package:flutter/material.dart';

class ActionButtonsView extends StatelessWidget {
  List<IntentActionModel> actions;

  ActionButtonsView({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text(actions[index].buttonText),
              subtitle: Text(actions[index].action,
                  style: const TextStyle(fontSize: 10)),
              onTap: () {
                AndroidIntent intent = AndroidIntent(
                  action: actions[index].action,
                );
                intent.launch();
              },
              trailing: const Icon(Icons.arrow_forward_ios));
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: actions.length);
  }
}
