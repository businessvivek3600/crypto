// ignore_for_file: use_build_context_synchronously

import 'package:elegant_notification/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_global_tools/utils/color.dart';
import '/screens/components/appbar.dart';
import '/utils/global_ui_widgets.dart';
import '/constants/app_const.dart';
import '/functions/functions.dart';
import '/route_management/route_name.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/setting_provider.dart';
import '../../route_management/route_animation.dart';
import '../../services/auth_service.dart';
import '../../utils/default_logger.dart';
import '../../widgets/buttonStyle.dart';
import '../../widgets/custom_bottom_sheet_dialog.dart';
import '../../widgets/social_login_buttons.dart';

class DashSettingPage extends StatefulWidget {
  const DashSettingPage({super.key});

  @override
  State<DashSettingPage> createState() => _DashSettingPageState();
}

class _DashSettingPageState extends State<DashSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashProvider, child) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Consumer<SettingProvider>(
              builder: (context, settingProvider, child) {
                return Scaffold(
                  appBar: buildAppBar(context),
                  body: ListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: paddingDefault * 2),
                    children: [
                      height10(spaceDefault),
                      buildCategoryCard(context, 'Preferences', [
                        buildSettingTile(
                            context, Icons.settings, 'App Settings', onTap: () {
                          context.pushNamed(RouteName.appSetting);
                        }),
                        buildSettingTile(context, Icons.help, 'Help & Support',
                            onTap: () => context.pushNamed(
                                    RouteName.helpAndSupportPage,
                                    queryParameters: {
                                      'anim': RouteTransition.fromBottom.name
                                    })),
                        buildSettingTile(
                            context, Icons.rule, 'Terms & Conditions',
                            onTap: () {}),
                        buildSettingTile(context, Icons.privacy_tip_outlined,
                            'Privacy Policy',
                            onTap: () {}),
                        buildSettingTile(
                            context, Icons.poll_outlined, 'Refund Policy',
                            onTap: () {}),
                      ]),
                      height10(spaceDefault),
                      buildCategoryCard(context, 'Others', [
                        buildSettingTile(
                            context, Icons.info_outline_rounded, 'About Us',
                            onTap: () {}),
                        buildSettingTile(
                            context, Icons.share, 'Share ${AppConst.appName}',
                            onTap: () => shareApp()),
                        buildSettingTile(
                            context, Icons.star_border_sharp, 'Rate Us',
                            leadingColor: Colors.amber, onTap: () {}),
                        buildSettingTile(context, Icons.logout, 'Logout',
                            leadingColor: Colors.red, onTap: () async {
                          bool? logout = await CustomBottomSheet.show<bool>(
                            context: context,
                            showCloseIcon: false,
                            curve: Curves.bounceIn,
                            builder: (context) => Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                titleLargeText(
                                    'Do you really want to logout?', context),
                                const Divider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton(
                                        style: buttonStyle(
                                            bgColor: Colors.transparent),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: bodyMedText('Cancel', context,
                                            color: Colors.red),
                                      ),
                                    ),
                                    width10(),
                                    Expanded(
                                      child: FilledButton(
                                        // style:
                                        //     buttonStyle(bgColor: Colors.green),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: bodyMedText('Confirm', context,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                          logD('will pop scope $logout');
                          if (logout != null && logout) {
                            StreamAuthScope.of(context)
                                .signOut(onBoarding: true);
                          }
                        }),
                      ]),
                      height50(),
                      height30(),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: paddingDefault),
                        child: Column(
                          children: [
                            bodyMedText('App Version: 1.0.0', context),
                            height10(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.scale(
                                    scale: 0.8,
                                    child: FlutterSocialButton(
                                      onTap: () {},
                                      mini: true,
                                      buttonType: ButtonType.facebook,
                                    )),
                                Transform.scale(
                                    scale: 0.8,
                                    child: FlutterSocialButton(
                                      onTap: () {},
                                      mini: true,
                                      buttonType: ButtonType.twitter,
                                    )),
                                Transform.scale(
                                    scale: 0.8,
                                    child: FlutterSocialButton(
                                      onTap: () {},
                                      mini: true,
                                      buttonType: ButtonType.whatsapp,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      height50(),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildSettingTile(BuildContext context, IconData leading, String title,
      {IconData trailing = Icons.arrow_forward_ios_rounded,
      Color? leadingColor,
      required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingDefault),
      child: Material(
        elevation: 2,
        // surfaceTintColor: Colors.transparent,
        // color: Colors.red,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

          // splashColor: Theme.of(context).colorScheme.onSecondary,
          // tileColor: Colors.white,

          contentPadding: EdgeInsets.symmetric(horizontal: paddingDefault),
          onTap: onTap,
          leading: Icon(leading,
              color: leadingColor ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.8)),
          title: bodyMedText(title, context),
          trailing: Icon(trailing, size: 15),
        ),
      ),
    );
  }

  Card buildCategoryCard(
      BuildContext context, String name, List<Widget> tiles) {
    return globalCard(
      elevation: 0,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceColor: Colors.transparent,
      child: Container(
        // padding: EdgeInsets.all(paddingDefault),
        decoration: const BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(0),
              child: bodyLargeText(name, context, color: Colors.grey),
            ),
            height10(),
            // const Divider(height: 0, color: Colors.grey),
            ...tiles.map((tile) {
              int index = tiles.indexOf(tile);
              return Column(
                children: [
                  tile,
                  // if (index < tiles.length - 1) const MySeparator(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return buildCustomAppBar(
      title: titleLargeText('Settings', context, color: Colors.white),
      actions: [
        IconButton(
            onPressed: () => context.pushNamed(RouteName.notificationPage,
                queryParameters: {'anim': RouteTransition.fromBottom.name}),
            icon: const Badge(child: Icon(Icons.notifications_outlined))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_outline)),
        const ToggleBrightnessButton()
      ],
    );
  }
}

class ToggleBrightnessButton extends StatelessWidget {
  const ToggleBrightnessButton({super.key, this.color, this.onChange});
  final Color? color;
  final Function(ThemeMode mode)? onChange;
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
      builder: (context, settingProvider, child) {
        return IconButton(
            onPressed: () async {
              ThemeMode mode = await settingProvider.setThemeMode(context);
              if (onChange != null) {
                onChange!(mode);
              }
            },
            icon: Icon(
                settingProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: color));
      },
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color, this.width = 2})
      : super(key: key);
  final double height;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = width;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: color ??
                        Theme.of(context).dividerColor.withOpacity(0.3)),
              ),
            );
          }),
        );
      },
    );
  }
}
