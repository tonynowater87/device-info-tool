import 'package:device_info_tool/theme.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

void showConfirmDialog(
  BuildContext context,
  String? title,
  String? content,
  IconData? cancelIconData,
  IconData? confirmIconData,
  VoidCallback onConfirmClick,
) {
  final dialogBackgroundColor = Theme.of(context).dialogTheme.backgroundColor!;
  final dialogCancelTextStyle = Theme.of(context).dialogCancelTextStyle();
  final dialogCancelIconColor = Theme.of(context).dialogCancelIconColor();
  final dialogConfirmTextStyle = Theme.of(context).dialogConfirmTextStyle();
  final dialogConfirmIconColor = Theme.of(context).dialogConfirmIconColor();
  final dialogConfirmButtonBackgroundColor =
      Theme.of(context).dialogConfirmButtonBackgroundColor();

  Dialogs.materialDialog(
      color: dialogBackgroundColor,
      context: context,
      title: title,
      msg: content,
      actions: [
        IconsOutlineButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          text: 'Cancel',
          iconData: cancelIconData,
          textStyle: dialogCancelTextStyle,
          iconColor: dialogCancelIconColor,
        ),
        IconsButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmClick.call();
          },
          text: 'Yes',
          iconData: confirmIconData,
          color: dialogConfirmButtonBackgroundColor,
          textStyle: dialogConfirmTextStyle,
          iconColor: dialogConfirmIconColor,
        ),
      ]);
}
