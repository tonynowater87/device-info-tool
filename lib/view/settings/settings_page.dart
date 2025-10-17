import 'dart:io';

import 'package:device_info_tool/data/AppVersionProvider.dart';
import 'package:device_info_tool/data/default_page_provider.dart';
import 'package:device_info_tool/theme.dart';
import 'package:device_info_tool/view/appinfo/appinfo_cubit.dart';
import 'package:device_info_tool/view/appinfo/appinfo_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

class SettingsPage extends StatefulWidget {
  final List<String> pageNames;
  final DefaultPageSettings? currentDefaultPage;
  final AppVersionProvider appVersionProvider;

  const SettingsPage({
    Key? key,
    required this.pageNames,
    this.currentDefaultPage,
    required this.appVersionProvider,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DefaultPageProvider _defaultPageProvider = DefaultPageProvider();
  String? _selectedPageTitle;

  @override
  void initState() {
    super.initState();
    _loadDefaultPage();
  }

  Future<void> _loadDefaultPage() async {
    final defaultPage = await _defaultPageProvider.getDefaultPage();
    if (mounted) {
      setState(() {
        _selectedPageTitle = defaultPage?.pageTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogBackgroundColor =
        Theme.of(context).dialogTheme.backgroundColor!;
    final dialogCancelTextStyle = Theme.of(context).dialogCancelTextStyle();
    final dialogCancelIconColor = Theme.of(context).dialogCancelIconColor();
    final dialogConfirmTextStyle = Theme.of(context).dialogConfirmTextStyle();
    final dialogConfirmIconColor = Theme.of(context).dialogConfirmIconColor();
    final dialogConfirmButtonBackgroundColor =
        Theme.of(context).dialogConfirmButtonBackgroundColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'General',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Default Start Page'),
            subtitle: Text(_selectedPageTitle ?? 'None (First Page)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPageSelectionDialog(
                context,
                dialogBackgroundColor,
                dialogCancelTextStyle,
                dialogCancelIconColor,
                dialogConfirmTextStyle,
                dialogConfirmIconColor,
                dialogConfirmButtonBackgroundColor,
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BlocProvider(
                          create: (context) => AppInfoCubit(
                              widget.appVersionProvider),
                          child: const AppInfoPage())));
            },
          ),
        ],
      ),
    );
  }

  void _showPageSelectionDialog(
    BuildContext context,
    Color dialogBackgroundColor,
    TextStyle dialogCancelTextStyle,
    Color dialogCancelIconColor,
    TextStyle dialogConfirmTextStyle,
    Color dialogConfirmIconColor,
    Color dialogConfirmButtonBackgroundColor,
  ) {
    int? selectedIndex = widget.currentDefaultPage?.pageIndex;

    Dialogs.bottomMaterialDialog(
      color: dialogBackgroundColor,
      context: context,
      customView: StatefulBuilder(
        builder: (context, setDialogState) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.pageNames.length,
              itemBuilder: (context, index) {
                final pageName = widget.pageNames[index];
                return RadioListTile<int>(
                  title: Text(pageName),
                  value: index,
                  groupValue: selectedIndex,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedIndex = value;
                    });
                  },
                );
              },
            ),
          );
        },
      ),
      actions: [
        IconsOutlineButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          text: 'Cancel',
          iconData: Icons.cancel_outlined,
          textStyle: dialogCancelTextStyle,
          iconColor: dialogCancelIconColor,
        ),
        IconsButton(
          onPressed: () async {
            if (selectedIndex != null) {
              final selectedTitle = widget.pageNames[selectedIndex!];
              await _defaultPageProvider.saveDefaultPage(
                selectedIndex!,
                selectedTitle,
              );
              setState(() {
                _selectedPageTitle = selectedTitle;
              });
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Default page set to: $selectedTitle'),
                  backgroundColor: Theme.of(context).containerBorderColor(),
                ),
              );
            }
          },
          text: 'Confirm',
          iconData: Icons.check,
          color: dialogConfirmButtonBackgroundColor,
          textStyle: dialogConfirmTextStyle,
          iconColor: dialogConfirmIconColor,
        ),
      ],
    );
  }
}
