import '/route_management/route_name.dart';

class RoutePath {
  RouteName routeName = RouteName();
  static const String splash = '/${RouteName.splash}';
  static const String notFoundScreen = '/${RouteName.notFoundScreen}';
  static const String onBoarding = '/${RouteName.onBoarding}';

  //wallet
  static const String createNewWallet = '/${RouteName.createNewWallet}';
  static const String createUsername = '/${RouteName.createUsername}';
  static const String importWallet = '/${RouteName.importWallet}';

  //auth
  static const String login = '/${RouteName.login}';
  static const String phoneAuth = '/${RouteName.phoneAuth}';
  static const String verifyPhoneOTP = '/${RouteName.verifyPhoneOTP}';
  static const String registration = '/${RouteName.registration}';
  static const String home = '/${RouteName.home}';

  ///sub-paths
  static const String explore = RouteName.explore;
  static const String search = RouteName.search;
  static const String sendCoin = RouteName.sendCoin;
  static const String coinChat = RouteName.coinChat;
  static const String tx = RouteName.tx;
  static const String chart = RouteName.chart;

  static const String categories = RouteName.categories;
  static const String categoryDetail = RouteName.categoryDetail;
  static const String services = RouteName.services;
  static const String service = RouteName.service;
  static const String slotBooking = RouteName.slotBooking;
  static const String bookingDetail = RouteName.bookingDetail;
  static const String shop = RouteName.shop;
  static const String about = RouteName.about;

  //main setting
  static const String dashSetting = RouteName.dashSetting;
  static const String notificationPage = RouteName.notificationPage;
  static const String addressMainPage = RouteName.addressMainPage;
  static const String addNewAddress = RouteName.addNewAddress;
  static const String notificationSettingsScreen =
      RouteName.notificationSettings;
  static const String paymentMethodsPage = RouteName.paymentMethodsPage;
  static const String profile = RouteName.profile;
  static const String helpAndSupportPage = RouteName.helpAndSupportPage;
  static const String appSetting = RouteName.appSetting;
  static const String gallery = RouteName.gallery;
  static const String contact = RouteName.contact;

  ///MLM
  ///drawer pages
  static const String mLMTransactionPage = '/${RouteName.mLMTransactionPage}';
  // static const String mLMFlutterSideMenu = '/mLMFlutterSideMenu';

  ///Ecommerce
  static const String ecomCategoryPage = RouteName.ecomCategoryPage;
}
