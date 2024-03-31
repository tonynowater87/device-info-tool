import 'package:flutter/cupertino.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

Decoration getDecoration(String text) => RotatedCornerDecoration.withColor(
    color: CupertinoColors.activeBlue,
    badgePosition: BadgePosition.topStart,
    badgeSize: const Size(56, 56),
    badgeCornerRadius: const Radius.circular(8),
    badgeShadow:
        const BadgeShadow(color: CupertinoColors.activeBlue, elevation: 2),
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