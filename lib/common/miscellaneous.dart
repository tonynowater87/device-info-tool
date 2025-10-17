import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:device_info_tool/theme.dart';

Decoration getDecoration(String text, BuildContext context) => RotatedCornerDecoration.withColor(
    color: Theme.of(context).badgeColor(),
    badgePosition: BadgePosition.topStart,
    badgeSize: const Size(56, 56),
    badgeCornerRadius: const Radius.circular(8),
    badgeShadow:
        BadgeShadow(color: Theme.of(context).badgeShadowColor(), elevation: 2),
    textSpan: TextSpan(
      text: text,
      style: const TextStyle(fontSize: 12),
    ));


T? tryCast<T>(object) {
  if (object is T) {
    return object;
  }
  return null;
}