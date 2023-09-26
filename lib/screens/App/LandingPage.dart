import 'package:flutter/material.dart';
import '../Bookings/booking_details_page.dart';
import '../BottomNav/dash_home_page.dart';
import '../BottomNav/swapCoinsPage.dart';
import '../BottomNav/transaction.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/providers/setting_provider.dart';
import '/screens/BottomNav/dash_bottom_nav.dart';
import '../BottomNav/dash_setting_page.dart';

import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import 'Booking/slot_booking.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final StreamAuth info = StreamAuthScope.of(context);

    return Consumer<DashboardProvider>(
      builder: (context, dashProvider, child) {
        return WillPopScope(
          onWillPop: () async => await willPopScope(dashProvider),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Consumer<SettingProvider>(
                builder: (context, settingProvider, child) {
                  return Scaffold(
                    // drawer: const MainDrawer(),
                    body: dashProvider.bottomIndex == 4
                        ? const DashSettingPage()
                        : dashProvider.bottomIndex == 3
                            ? BookingDetailPage()
                            : dashProvider.bottomIndex == 2
                                ? const SwapCoinsPage()
                                : dashProvider.bottomIndex == 1
                                    ? const TransactionsPage()
                                    : HomePage(),
                    bottomNavigationBar: const DashBottomNav(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> willPopScope(DashboardProvider dashProvider) async {
    if (dashProvider.bottomIndex == 0) {
      return true;
    } else {
      dashProvider.setBottomIndex(0);
      return false;
    }
  }
}
