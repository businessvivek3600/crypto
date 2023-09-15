import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/material.dart';
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
    List<TabItem> items = [
      const TabItem(icon: Icons.wallet, title: 'Wallet'),
      const TabItem(icon: Icons.history, title: 'Transactions'),
      const TabItem(icon: Icons.swap_horiz_rounded, title: 'Swap'),
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
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 5, 35, 41)
              : Theme.of(context).colorScheme.background,
          color: Colors.grey,
          colorSelected: Colors.white,
          indexSelected: provider.bottomIndex,
          onTap: provider.setBottomIndex,
          elevation: 10,
          chipStyle: ChipStyle(
              convexBridge: true,
              background:
                  Theme.of(context).colorScheme.primary.withOpacity(0.8)),
          itemStyle: ItemStyle.hexagon,
          animated: false,
        );
      },
    );
  }
}
