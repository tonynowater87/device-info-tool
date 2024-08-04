import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var lightThemeData = ThemeData(
    colorSchemeSeed: CupertinoColors.activeBlue,
    backgroundColor: CupertinoColors.systemGrey6,
    textTheme: TextTheme(
        button: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
        bodyText1: const TextStyle(color: CupertinoColors.systemGrey6),
        bodyText2: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
        caption: const TextStyle(color: CupertinoColors.systemGrey6)),
    brightness: Brightness.light,
    dialogTheme: const DialogTheme(
        backgroundColor: CupertinoColors.secondarySystemBackground));

var darkThemeData = ThemeData(
  colorSchemeSeed: CupertinoColors.activeBlue,
  backgroundColor: CupertinoColors.systemGrey6.darkColor,
  textTheme: TextTheme(
        button: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
        bodyText1: const TextStyle(color: CupertinoColors.systemGrey6),
        bodyText2: const TextStyle(color: CupertinoColors.systemGrey6),
        caption: const TextStyle(color: CupertinoColors.systemGrey6)),
    brightness: Brightness.dark,
    dialogTheme: DialogTheme(
      backgroundColor: CupertinoColors.secondarySystemBackground.darkColor,
    ),);

extension CustomColor on ThemeData {
  Color unselectedBackgroundColor() {
    if (brightness == Brightness.dark) {
      return Colors.black12;
    } else {
      return Colors.white;
    }
  }

  Color selectedBackgroundColor() {
    if (brightness == Brightness.dark) {
      return CupertinoColors.activeBlue;
    } else {
      return CupertinoColors.activeBlue;
    }
  }

  TextStyle unselectedTextStyle() {
    if (brightness == Brightness.dark) {
      return TextStyle(color: CupertinoColors.white.withAlpha(150));
    } else {
      return TextStyle(color: CupertinoColors.label.withAlpha(150));
    }
  }

  TextStyle selectedTextStyle() {
    if (brightness == Brightness.dark) {
      return const TextStyle(color: CupertinoColors.white);
    } else {
      return const TextStyle(color: CupertinoColors.label);
    }
  }

  TextStyle dialogConfirmTextStyle() {
    if (brightness == Brightness.dark) {
      return const TextStyle(color: CupertinoColors.white);
    } else {
      return const TextStyle(color: CupertinoColors.white);
    }
  }

  Color dialogConfirmIconColor() {
    if (brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  TextStyle dialogCancelTextStyle() {
    if (brightness == Brightness.dark) {
      return const TextStyle(color: Colors.grey);
    } else {
      return const TextStyle(color: Colors.grey);
    }
  }

  Color dialogCancelIconColor() {
    if (brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return Colors.grey;
    }
  }

  Color dialogConfirmButtonBackgroundColor() {
    if (brightness == Brightness.dark) {
      return CupertinoColors.activeBlue;
    } else {
      return CupertinoColors.activeBlue;
    }
  }
}
