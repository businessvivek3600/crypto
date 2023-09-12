import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/sized_utils.dart';
import '/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';

class DashBottomNav extends StatefulWidget {
  const DashBottomNav({super.key});

  @override
  State<DashBottomNav> createState() => _DashBottomNavState();
}

class _DashBottomNavState extends State<DashBottomNav> {
  @override
  Widget build(BuildContext context) {
    const List<TabItem> items = [
      TabItem(
        icon: Icons.wallet,
        title: 'Wallet',
      ),
      TabItem(
        icon: Icons.chat_rounded,
        title: 'Chat',
      ),
      TabItem(
        icon: Icons.swap_horiz_rounded,
        title: 'Swap',
      ),
      // TabItem(
      //   icon: Icons.chat,
      //   title: 'Chats',
      // ),
      // TabItem(
      //   icon: Icons.settings,
      //   title: 'Settings',
      // ),
    ];
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return BottomBarInspiredInside(
          items: items,
          backgroundColor: Theme.of(context).colorScheme.background,
          color: Colors.grey,
          colorSelected: Theme.of(context).colorScheme.primary,
          indexSelected: provider.bottomIndex,
          onTap: provider.setBottomIndex,
          elevation: 10,
          chipStyle: ChipStyle(
              convexBridge: true,
              background:
                  Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          itemStyle: ItemStyle.hexagon,
          animated: false,
        );
      },
    );
  }
}
