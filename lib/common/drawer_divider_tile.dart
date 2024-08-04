import 'package:flutter/material.dart';

class DrawerDividerTile extends StatelessWidget {
  final String title;

  const DrawerDividerTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(title),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
