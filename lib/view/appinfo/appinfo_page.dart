import 'package:device_info_tool/theme.dart';
import 'package:device_info_tool/view/appinfo/appinfo_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  State<AppInfoPage> createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppInfoCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppInfoCubit>().state;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogBackgroundColor =
        Theme.of(context).dialogTheme.backgroundColor!;
    final dialogCancelTextStyle = Theme.of(context).dialogCancelTextStyle();
    final dialogCancelIconColor = Theme.of(context).dialogCancelIconColor();
    final dialogConfirmTextStyle = Theme.of(context).dialogConfirmTextStyle();
    final dialogConfirmIconColor = Theme.of(context).dialogConfirmIconColor();
    final dialogConfirmButtonBackgroundColor =
        Theme.of(context).dialogConfirmButtonBackgroundColor();

    String appName = "";
    String appVersion = "";
    String githubLink = "";

    if (state is AppInfoLoaded) {
      appName = state.appName;
      appVersion = state.appVersion;
      githubLink = state.githubLink;
    }

    String appIconAssetPath;
    if (Theme.of(context).brightness == Brightness.dark) {
      appIconAssetPath = 'assets/images/launch-icon-dark.png';
    } else {
      appIconAssetPath = 'assets/images/launch-icon-light.png';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Stack(alignment: Alignment.center, children: [
        Positioned(
            top: screenHeight / 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Image.asset(appIconAssetPath),
                const SizedBox(height: 20),
                Visibility(
                    visible: appName.isNotEmpty && appVersion.isNotEmpty,
                    child: Text(
                      '$appName $appVersion',
                      style: Theme.of(context).textTheme.titleLarge,
                    )),
              ],
            )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  OutlinedButton(
                  onPressed: () {
                    Dialogs.materialDialog(
                        color: dialogBackgroundColor,
                        context: context,
                        msg:
                            'Are you sure to open the web-link?\n\n$githubLink',
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AppInfoCubit>().openGithubUrl();
                            },
                            text: 'Yes',
                            iconData: Icons.open_in_browser_outlined,
                            color: dialogConfirmButtonBackgroundColor,
                            textStyle: dialogConfirmTextStyle,
                            iconColor: dialogConfirmIconColor,
                          ),
                        ]);
                  },
                  child: const Text('Github'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () async {
                    if (!mounted) {
                      return;
                    }

                    final thirdPartyLibs =
                        await context.read<AppInfoCubit>().filterLicense();

                    Dialogs.bottomMaterialDialog(
                        color: dialogBackgroundColor,
                        context: context,
                        customView: SizedBox(
                          width: screenWidth,
                          height: screenHeight / 3,
                          child: ListView.builder(
                            itemBuilder: (context, position) {
                              return AboutListTile(
                                applicationLegalese:
                                    thirdPartyLibs[position].description,
                                applicationName: thirdPartyLibs[position].name,
                                applicationVersion:
                                    thirdPartyLibs[position].version,
                                child:
                                    Text(thirdPartyLibs[position].name ?? ''),
                              );
                            },
                            itemCount: thirdPartyLibs.length,
                          ),
                        ),
                        actions: [
                          IconsOutlineButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            text: 'Dismiss',
                            iconData: Icons.cancel_outlined,
                            textStyle: dialogCancelTextStyle,
                            iconColor: dialogCancelIconColor,
                          )
                        ]);
                  },
                  child: const Text('Used Third-Party Packages'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    Dialogs.materialDialog(
                        color: dialogBackgroundColor,
                        context: context,
                        msg: 'Are you sure to show an interstitial ad?',
                        actions: [
                          IconsOutlineButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            text: 'Cancel',
                            textStyle: dialogCancelTextStyle,
                            iconColor: dialogCancelIconColor,
                            iconData: Icons.cancel_outlined,
                          ),
                          IconsButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AppInfoCubit>().loadAdAndShow();
                            },
                            text: 'Yes',
                            color: dialogConfirmButtonBackgroundColor,
                            textStyle: dialogConfirmTextStyle,
                            iconColor: dialogConfirmIconColor,
                            iconData: Icons.monetization_on,
                          ),
                        ]);
                  },
                  child: const Text('Donate'),
                ),
              ],
            ),
          ),
          ),
        )
      ]),
    );
  }
}
