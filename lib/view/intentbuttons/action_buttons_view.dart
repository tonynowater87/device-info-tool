import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_tool/view/intentbuttons/intent_action_model.dart';
import 'package:flutter/material.dart';

class ActionButtonsView extends StatelessWidget {
  final List<IntentActionModel> actions;
  final Function(int, int)? onReorder;

  const ActionButtonsView({
    Key? key, 
    required this.actions,
    this.onReorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onReorder != null) {
      return ReorderableListView.builder(
        onReorder: onReorder!,
        itemCount: actions.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            key: ValueKey(actions[index].id),
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              leading: const Icon(Icons.drag_handle),
              title: Text(actions[index].buttonText),
              subtitle: Text(
                actions[index].action,
                style: const TextStyle(fontSize: 10),
              ),
              onTap: () {
                AndroidIntent intent = AndroidIntent(
                  action: actions[index].action,
                );
                intent.launch();
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      );
    } else {
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
            trailing: const Icon(Icons.arrow_forward_ios),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
        itemCount: actions.length,
      );
    }
  }
}
