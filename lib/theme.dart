import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var lightThemeData = ThemeData(
    primaryColor: CupertinoColors.activeBlue,
    textTheme: TextTheme(
        button: TextStyle(color: CupertinoColors.systemGrey6.darkColor)),
    brightness: Brightness.light,
    dialogTheme: const DialogTheme(
        backgroundColor: CupertinoColors.secondarySystemBackground),
    accentColor: CupertinoColors.systemBlue);

var darkThemeData = ThemeData(
    primaryColor: CupertinoColors.activeBlue,
    textTheme: TextTheme(
        button: TextStyle(color: CupertinoColors.systemGrey6.darkColor)),
    brightness: Brightness.dark,
    dialogTheme: DialogTheme(
      backgroundColor: CupertinoColors.secondarySystemBackground.darkColor,
    ),
    accentColor: CupertinoColors.systemBlue);

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
      return const TextStyle(color: CupertinoColors.activeBlue);
    } else {
      return const TextStyle(color: CupertinoColors.activeBlue);
    }
  }

  TextStyle selectedTextStyle() {
    if (brightness == Brightness.dark) {
      return const TextStyle(color: CupertinoColors.white);
    } else {
      return const TextStyle(color: CupertinoColors.white);
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
