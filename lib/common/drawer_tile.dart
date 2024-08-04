import 'package:device_info_tool/theme.dart';
import 'package:flutter/material.dart';

typedef Callback = void Function(String parameter);
class DrawerTile extends StatelessWidget {
  final bool selected;
  final Widget icon;
  final String title;
  final Callback onTap;

  const DrawerTile(
      {super.key,
      required this.selected,
      required this.icon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Row(
          children: [
            Visibility(
              visible: selected,
              child: icon,
            ),
            Padding(
              padding: selected ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
              child: Text(title,
                  style: selected
                      ? Theme.of(context).selectedTextStyle().copyWith(
                          decoration: TextDecoration.underline,
                          decorationThickness: 4.0,
                          decorationColor:
                              Theme.of(context).selectedBackgroundColor())
                      : Theme.of(context).unselectedTextStyle()),
            ),
          ],
        ),
        selected: selected,
        onTap: () => onTap(title));
  }
}
