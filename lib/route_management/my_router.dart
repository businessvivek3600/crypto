import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '../screens/App/coin_chart.dart';
import '../screens/App/transaction_details.dart';
import '../screens/chat/ChatPageExample.dart';
import '/screens/App/coint_transfer/send_coin.dart';
import '/screens/mnemonics/import_wallet.dart';
import '../screens/App/Booking/slot_booking.dart';
import '../screens/App/Service/service_detail_page.dart';
import '../screens/App/Shop/shopDetailsPage.dart';
import '../screens/Bookings/booking_details_page.dart';
import '../screens/Splash/splash_screen.dart';
import '../screens/mnemonics/createNewWallet.dart';
import '../screens/mnemonics/create_usename.dart';
import '/screens/App/Service/services_page.dart';
import '../screens/App/Category/categoryDetailsPage.dart';
import '/screens/User_Preferences/about_page.dart';
import '/screens/User_Preferences/contact_page.dart';
import '/screens/Settings/app_setting_page.dart';
import '/screens/auth/email_registaration_page.dart';
import '../screens/Addresses/AddressMainPage.dart';
import '../screens/Addresses/add_new_address.dart';
import '../screens/App/Category/categories_page.dart';
import '../screens/App/search_users_page.dart';
import '../screens/Notifications/notifications.dart';
import '../screens/Onboardings/on_boarding_page.dart';
import '../screens/Payments/PaymentMethodsMainPage.dart';
import '../screens/Settings/notificationSettingsScreen.dart';
import '../screens/User_Preferences/HelpAndSupport/help_and_support_page.dart';
import '../screens/User_Preferences/profile_screen_page.dart';
import '../screens/auth/PhoneAuthPage.dart';
import '../screens/gallery_page.dart';
import '../widgets/page_not_found.dart';
import 'route_animation.dart';
import 'route_name.dart';
import 'route_path.dart';

import '../screens/auth/login_screen.dart';
import '../screens/App/LandingPage.dart';
import '../services/auth_service.dart';
import '../utils/default_logger.dart';
import '../widgets/app_web_view_page.dart';

class MyRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: Get.key,
    initialLocation: RoutePath.splash,
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
          name: RouteName.home,
          path: RoutePath.home,
          builder: (BuildContext context, GoRouterState state) => const Home(),
          routes: [
            _newRoute2(RouteName.search, (GoRouterState state) {
              // WalletModel? wallet = state.queryParameters['wallet'] != null
              //     ? WalletModel.fromJson(
              //         jsonDecode(state.queryParameters['wallet']!))
              //     : null;
              // List<dynamic>? recentUsers =
              //     state.queryParameters['recentUsers'] != null
              //         ? jsonDecode(state.queryParameters['recentUsers']!)
              //         : null;
              // infoLog(
              //     'going to search page recent users are $recentUsers  ***');
              return SearchUsersPage(
                query: state.queryParameters['query'],
                // recentUsers: recentUsers,
                // wallet: wallet,
              );
            }, null),
            _newRoute2(RouteName.tx, (GoRouterState state) {
              return TransactionDetailsScreen(
                data: state.extra as Map<String, dynamic>?,
              );
            }, null),

            _newRoute2(RouteName.chart, (GoRouterState state) {
              return CoinChartPage(
                symbol: state.queryParameters['symbol'],
              );
            }, null),
            _newRoute2(
                RouteName.sendCoin,
                (GoRouterState state) => SendCoinPage(
                      data: state.extra as Map<String, dynamic>?,
                    ),
                null),

            _newRoute2(
                RouteName.coinChat,
                (GoRouterState state) => CoinChatScreen(
                    // data: state.extra as Map<String, dynamic>?,
                    ),
                null),

            ///
            _newRoute2(
                RouteName.categories,
                (GoRouterState state) => AllCategoriesPage(
                      query: state.queryParameters['category'],
                    ),
                null),
            _newRoute2(RouteName.categoryDetail,
                (GoRouterState state) => const CategoryDetailsPage(), null),
            _newRoute2(
                RouteName.services,
                (GoRouterState state) => AllServicesPage(
                      query: state.queryParameters['service'],
                      category: state.queryParameters['cat'],
                    ),
                null),
            _newRoute2(
                RouteName.service,
                (GoRouterState state) => ServiceDetailsPage(
                      query: state.queryParameters['service'] ?? 'none',
                      shop: state.queryParameters['shop'] ?? 'none',
                    ),
                null,
                routes: [
                  _newRoute2(
                    RouteName.slotBooking,
                    (GoRouterState state) => SlotBookingPage(
                      service: state.queryParameters['service'] ?? 'none',
                      shop: state.queryParameters['shop'] ?? 'none',
                    ),
                    null,
                  ),
                  _newRoute2(
                    RouteName.bookingDetail,
                    (GoRouterState state) => BookingDetailPage(
                        // service: state.queryParameters['service'] ?? 'none',
                        // shop: state.queryParameters['shop'] ?? 'none',
                        ),
                    null,
                  ),
                ]),
            _newRoute2(
                RouteName.shop,
                (GoRouterState state) => ShopDetailPage(
                    shop: state.queryParameters['service'] ?? 'none'),
                null),
            _newRoute2(
                RouteName.explore,
                (GoRouterState state) => WebViewExample(
                    url: state.queryParameters['url'],
                    showAppBar: state.queryParameters['showAppBar'] ?? '1',
                    showToast: state.queryParameters['showToast'] ?? '1',
                    enableSearch: state.queryParameters['enableSearch'] == '1',
                    allowBack: state.queryParameters['allowBack'] == '1',
                    allowCopy: state.queryParameters['allowCopy'] == '1',
                    changeOrientation:
                        state.queryParameters['changeOrientation'] ?? '0'),
                null),
            _newRoute2(RouteName.notificationPage,
                (GoRouterState state) => const NotificationPage(), null),
            _newRoute2(RouteName.addressMainPage,
                (GoRouterState state) => const AddressMainPage(), null,
                routes: [
                  _newRoute2(RouteName.addNewAddress,
                      (GoRouterState state) => const AddNewAddress(), null)
                ]),
            _newRoute2(RouteName.paymentMethodsPage,
                (GoRouterState state) => const PaymentMethodsPage(), null),

            _newRoute2(RouteName.profile,
                (GoRouterState state) => const ProfileScreenPage(), null),

            //preferences
            _newRoute2(RouteName.helpAndSupportPage,
                (GoRouterState state) => const HelpAndSupportPage(), null),
            _newRoute2(RouteName.contact,
                (GoRouterState state) => const ContactPage(), null),
            _newRoute2(RouteName.gallery,
                (GoRouterState state) => const GalleryPage(), null),
            _newRoute2(RouteName.appSetting,
                (GoRouterState state) => const AppSettingsPage(), null,
                routes: [
                  _newRoute2(
                      RouteName.notificationSettings,
                      (GoRouterState state) =>
                          const NotificationSettingsScreen(),
                      null)
                ]),
            _newRoute2(RouteName.about,
                (GoRouterState state) => const AboutPage(), null),
            _newRoute2(RouteName.dashSetting,
                (GoRouterState state) => const DashSettingPage(), null),
          ]),

      ///authentication
      _newRoute2(RouteName.createNewWallet, (GoRouterState state) {
        infoLog('data: ${state.queryParameters['data'] ?? '[]'}');
        return CreateNewWallet(
          data: jsonDecode(state.queryParameters['data'] ?? '[]'),
          // data: [],
        );
      }, null, subPath: false),
      _newRoute2(RouteName.createUsername, (GoRouterState state) {
        return const CreateUserName();
      }, null, subPath: false),
      _newRoute2(RouteName.importWallet, (GoRouterState state) {
        return ImportWalletScreen(
            token: state.queryParameters['token'] == '1',
            import: state.queryParameters['import'] == '1');
      }, null, subPath: false),

      ///authentication
      _newRoute2(
          RouteName.login, (GoRouterState state) => const LoginScreen(), null,
          subPath: false),
      _newRoute2(RouteName.phoneAuth,
          (GoRouterState state) => const PhoneAuthPage(), null,
          subPath: false),
      _newRoute2(RouteName.verifyPhoneOTP,
          (GoRouterState state) => const VerifyPhoneOTPPage(), null,
          subPath: false),
      _newRoute2(RouteName.registration,
          (GoRouterState state) => const EmailRegistrationForm(), null,
          subPath: false),
      _newRoute2(
          RouteName.splash, (GoRouterState state) => const SplashScreen(), null,
          subPath: false),
      _newRoute2(RouteName.onBoarding,
          (GoRouterState state) => const OnBoardingPage(), null,
          subPath: false),
    ],
    errorPageBuilder: (context, state) =>
        animatedRoute(state, NotFoundScreen(state: state, uri: state.location)),
    redirect: _redirect,
  );
}

FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  // Using `of` method creates a dependency of StreamAuthScope. It will
  // cause go_router to reparse current route if StreamAuth has new sign-in
  // information.
  String path = state.location;
  final (loggedIn, user) = await StreamAuthScope.of(context).isSignedIn();
  final bool loggingIn = path == RoutePath.login;

  ///check for on-boarding

  infoLog(
      'path is $path  , user is logged in $loggedIn showOnBoarding($showOnBoarding) on boarding: ${(!loggedIn && showOnBoarding && path == RoutePath.onBoarding)}');

  infoLog('state is ---> ${state.location}');
  //splash and on-boarding
  if (path == RoutePath.splash) {
    return RoutePath.splash;
  } else if (!loggedIn && showOnBoarding && path == RoutePath.onBoarding) {
    return RoutePath.onBoarding;
  }

  //wallet

  else if (!loggedIn &&
      (path.startsWith(RoutePath.createNewWallet) ||
          path.startsWith(RoutePath.importWallet))) {
    return path;
  } else
  /*
  //auth
  else if (!loggedIn && path == RoutePath.registration) {
    return RoutePath.registration;
  } else if (!loggedIn && path == RoutePath.phoneAuth) {
    return RoutePath.phoneAuth;
  } else if (!loggedIn && path == RoutePath.verifyPhoneOTP) {
    return RoutePath.verifyPhoneOTP;
  } else*/
  if (!loggedIn) {
    return RoutePath.onBoarding;
  } else

  /// if the user is logged in but still on the login page, send them to the home page
  if (loggedIn) {
    infoLog(
        'path is $path   *contains home  ${path.startsWith(RoutePath.home)}',
        'User is logged in');
    if (path.startsWith(RoutePath.home) ||
        (path == RoutePath.createUsername) ||
        path.startsWith(RoutePath.importWallet)) {
      return path;
    } else {
      return RoutePath.home;
    }
  }
  infoLog('path is $path  and passed all');

  // no need to redirect at all
  return null;
}

GoRoute _newRoute(String name, Widget page, String transition,
        {bool subPath = true}) =>
    GoRoute(
        name: name,
        path: '${!subPath ? '/' : ''}$name',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            animatedRoute(state, page));

GoRoute _newRoute2(String name, Widget Function(GoRouterState state) page,
        RouteTransition? transition,
        {bool subPath = true, List<RouteBase>? routes}) =>
    GoRoute(
        name: name,
        path: '${!subPath ? '/' : ''}$name',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            animatedRoute2(state, page, transition: transition),
        routes: routes ?? []);
