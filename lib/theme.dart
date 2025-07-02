import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var lightThemeData = ThemeData(
    colorSchemeSeed: CupertinoColors.activeBlue,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CupertinoColors.activeBlue,
      surface: CupertinoColors.systemGrey6,
    ),
    textTheme: TextTheme(
        labelLarge: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
        bodyLarge: const TextStyle(color: CupertinoColors.systemGrey6),
        bodyMedium: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
        bodySmall: const TextStyle(color: CupertinoColors.systemGrey6)),
    brightness: Brightness.light,
    dialogTheme: const DialogThemeData(
        backgroundColor: CupertinoColors.secondarySystemBackground));

var darkThemeData = ThemeData(
  colorSchemeSeed: CupertinoColors.activeBlue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: CupertinoColors.activeBlue,
    surface: CupertinoColors.systemGrey6.darkColor,
  ),
  textTheme: TextTheme(
      labelLarge: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
      bodyLarge: const TextStyle(color: CupertinoColors.systemGrey6),
      bodyMedium: const TextStyle(color: CupertinoColors.systemGrey6),
      bodySmall: const TextStyle(color: CupertinoColors.systemGrey6)),
  brightness: Brightness.dark,
  dialogTheme: DialogThemeData(
    backgroundColor: CupertinoColors.secondarySystemBackground.darkColor,
  ),
);

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
