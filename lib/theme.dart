import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var lightThemeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: CupertinoColors.activeBlue,
      surface: CupertinoColors.systemGrey6,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
        labelLarge: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
        bodyLarge: const TextStyle(color: CupertinoColors.systemGrey6),
        bodyMedium: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
        bodySmall: const TextStyle(color: CupertinoColors.systemGrey6)),
    dialogTheme: const DialogThemeData(
        backgroundColor: CupertinoColors.secondarySystemBackground),
    drawerTheme: const DrawerThemeData(
        backgroundColor: CupertinoColors.systemBackground),
    appBarTheme: const AppBarTheme(
        backgroundColor: CupertinoColors.systemBackground,
        foregroundColor: CupertinoColors.label));

var darkThemeData = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: CupertinoColors.activeBlue,
    surface: CupertinoColors.systemGrey6.darkColor,
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
      labelLarge: TextStyle(color: CupertinoColors.systemGrey6.darkColor),
      bodyLarge: const TextStyle(color: CupertinoColors.systemGrey6),
      bodyMedium: const TextStyle(color: CupertinoColors.systemGrey6),
      bodySmall: const TextStyle(color: CupertinoColors.systemGrey6)),
  dialogTheme: DialogThemeData(
    backgroundColor: CupertinoColors.secondarySystemBackground.darkColor,
  ),
  drawerTheme: DrawerThemeData(
      backgroundColor: CupertinoColors.systemBackground.darkColor),
  appBarTheme: AppBarTheme(
      backgroundColor: CupertinoColors.systemBackground.darkColor,
      foregroundColor: CupertinoColors.white),
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

  Color containerBorderColor() {
    if (brightness == Brightness.dark) {
      return CupertinoColors.activeBlue.withAlpha(180);
    } else {
      return CupertinoColors.activeBlue.withAlpha(100);
    }
  }

  Color toastBackgroundColor() {
    if (brightness == Brightness.dark) {
      return CupertinoColors.activeBlue.withOpacity(0.95);
    } else {
      return CupertinoColors.activeBlue.withOpacity(0.8);
    }
  }

  Color badgeColor() {
    if (brightness == Brightness.dark) {
      return CupertinoColors.activeBlue.darkHighContrastColor;
    } else {
      return CupertinoColors.activeBlue;
    }
  }

  Color badgeShadowColor() {
    if (brightness == Brightness.dark) {
      return CupertinoColors.activeBlue.darkHighContrastColor;
    } else {
      return CupertinoColors.activeBlue;
    }
  }

  Color footerBackgroundColor() {
    if (brightness == Brightness.dark) {
      return CupertinoColors.systemBlue.darkColor;
    } else {
      return CupertinoColors.systemBlue;
    }
  }
}
