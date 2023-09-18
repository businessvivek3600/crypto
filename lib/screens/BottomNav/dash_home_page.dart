// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../utils/color.dart';
import '../components/appbar.dart';
import '/models/user/user_data_model.dart';
import '/utils/loader.dart';
import '/utils/sp_utils.dart';
import '../../providers/WalletProvider.dart';
import '../components/receive_qr_code_widget.dart';
import '../components/select_coin.dart';
import '../components/select_wallet.dart';
import '/models/coin_model.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/widgets/skeleton.dart';
import '../../repo_injection.dart';
import '/constants/asset_constants.dart';
import '/route_management/route_name.dart';
import '/utils/picture_utils.dart';
import 'package:random_avatar/random_avatar.dart';
import '/functions/functions.dart';
import '/providers/auth_provider.dart';
import '/providers/dashboard_provider.dart';
import '/utils/default_logger.dart';

import '/utils/sized_utils.dart';
import '/widgets/custom_bottom_sheet_dialog.dart';
import '/widgets/MultiStageButton.dart';
import '/widgets/buttonStyle.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import 'transaction.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tag = 1;
  final _dashProvider = sl.get<DashboardProvider>();
  final walletProvider = sl.get<WalletProvider>();
  final authProvider = sl.get<AuthProvider>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _dashProvider.getCoins(context, true);
      // authProvider.refreshMyWallets();
      // _dashProvider.scrollController.addListener(_dashProvider.onScroll);
    });
  }

  @override
  void dispose() {
    // _dashProvider.scrollController.removeListener(_dashProvider.onScroll);
    // _dashProvider.scrollController.dispose();
    super.dispose();
  }

  Future<bool> _loadMore() async {
    // _dashProvider.getCoins(context, false);
    await authProvider.refreshMyWallets();
    // await Future.delayed(const Duration(seconds: 3));
    // load();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    infoLog(SpUtils().getMnemonics.toString(), 'mnemonics');
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<DashboardProvider>(
          builder: (context, dashProvider, child) {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: _loadMore,
                child: CustomScrollView(
                  controller:
                      Provider.of<DashboardProvider>(context, listen: true)
                          .scrollController,
                  slivers: [
                    buildAppBar(context, authProvider),
                    buildBody(dashProvider),
                    SliverToBoxAdapter(child: height50()),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  SliverStickyHeader buildBody(DashboardProvider provider) {
    CoinGraphType graphType = provider.graphType;
    double height = 150;
    return SliverStickyHeader.builder(
      builder: (context, state) => buildHeader(height, provider),
      sliver: (provider.loadingCoins == ButtonLoadingState.loading) ||
              (provider.loadingCoins == ButtonLoadingState.idle &&
                  provider.coinModel != null &&
                  (provider.coinModel!.coins ?? []).isNotEmpty)
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  bool loading =
                      provider.loadingCoins == ButtonLoadingState.loading;
                  Coin? coins;
                  double priceChange = 0;
                  Color? priceChangeColor;
                  if (!loading) {
                    coins = provider.coinModel!.coins![i];
                    String? colorText;
                    switch (graphType) {
                      case CoinGraphType.day:
                        priceChange = coins.graphData!.oneDay!.priceChange ?? 0;
                        colorText = coins.graphData!.oneDay!.priceChangeColor;
                        break;
                      case CoinGraphType.week:
                        priceChange =
                            coins.graphData!.oneWeek!.priceChange ?? 0;
                        colorText = coins.graphData!.oneWeek!.priceChangeColor;
                        break;
                      case CoinGraphType.month:
                        priceChange =
                            coins.graphData!.oneMonth!.priceChange ?? 0;
                        colorText = coins.graphData!.oneMonth!.priceChangeColor;
                        break;
                      case CoinGraphType.year:
                        // priceChange = coins.graphData!.oneYear!.priceChange ?? 0;
                        colorText = coins.graphData!.oneYear!.priceChangeColor;
                        break;
                    }
                    priceChangeColor =
                        (colorText ?? '') == 'red' ? Colors.red : Colors.green;
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: !loading
                          ? () {
                              infoLog(coins!.toJson().toString(), 'coins');
                              context.pushNamed(RouteName.chart,
                                  queryParameters: {
                                    'symbol': '${coins.symbol}${'usdt'}'
                                  });
                            }
                          : null,
                      leading: loading
                          ? buildShimmer(
                              w: 60.0, h: 60.0, shape: BoxShape.circle)
                          : CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              child: buildCachedImageWithLoading(
                                  coins!.imageUrl ?? '',
                                  loadingMode: ImageLoadingMode.shimmer),
                            ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          loading
                              ? Row(
                                  children: [
                                    buildShimmer(radius: 2, w: 100, h: 13),
                                  ],
                                )
                              : Row(
                                  children: [
                                    titleLargeText(
                                        coins!.symbol ?? '', context),
                                  ],
                                ),
                          height10(),
                          loading
                              ? Row(
                                  children: [
                                    buildShimmer(radius: 2, w: 70, h: 13),
                                  ],
                                )
                              : capText((coins!.name ?? ''), context,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (provider.graphType != CoinGraphType.year)
                            loading
                                ? buildShimmer(radius: 2, w: 70, h: 13)
                                : capText('${priceChange.toStringAsFixed(3)}%',
                                    context,
                                    color: priceChangeColor,
                                    fontWeight: FontWeight.w500),
                          height10(),
                          loading
                              ? buildShimmer(radius: 2, w: 40, h: 13)
                              : capText(
                                  '\$${(coins!.price ?? 0).toStringAsFixed(4)}',
                                  context,
                                  color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
                childCount: provider.loadingCoins == ButtonLoadingState.loading
                    ? 7
                    : provider.coinModel!.coins!.length,
              ),
            )
          : SliverToBoxAdapter(
              child: assetImages(PNGAssets.appLogo, height: 700)),
    );
  }

  Widget buildHeader(double height, DashboardProvider provider) {
    Color textColor =
        getTheme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(height: height, width: double.maxFinite),
              Positioned(
                top: 0,
                bottom: height / 2,
                left: 0,
                right: 0,
                child: Container(
                    decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.primary,
                  gradient: buildAppbarGradient(),

                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                )),
              ),
              Positioned(
                top: height / 4,
                bottom: height / 4,
                left: 20,
                right: 20,
                child: Container(
                  height: 100,
                  width: double.maxFinite,
                  padding: EdgeInsets.all(paddingDefault),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(3, 3))
                      ]),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // context.goNamed(RouteName.search, queryParameters: {
                            //   // 'recentUsers': jsonEncode(users),
                            //   // 'wallet': jsonEncode(walletModel),
                            // });
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              isScrollControlled: true,
                              builder: (context) {
                                return SelectCoinWidget(
                                  onWalletSelect:
                                      (Coin coin, double balance) async {
                                    successLog(coin.toJson().toString());
                                    if ([
                                      sl.get<AuthProvider>().user.wallet ?? []
                                    ].isNotEmpty) {
                                      Wallet wallet = sl
                                          .get<AuthProvider>()
                                          .user
                                          .wallet!
                                          .firstWhere((element) =>
                                              element.tokenName ==
                                              coin.parentWallet);
                                      context.pop();
                                      context.pushNamed(RouteName.sendCoin,
                                          extra: {
                                            "wallet": wallet.toJson(),
                                            "coin": coin.toJson()
                                          });

                                      // context.pop();
                                      // context.goNamed(RouteName.sendCoin,
                                      //     extra: {
                                      //       "wallet": wallet.toJson(),
                                      //       "coin": coin.toJson()
                                      //     });

                                      //                   await sl.get<WalletProvider>().getBalance(
                                      // context,
                                      // coin!.parentWallet ?? '',
                                      // coin!.symbol ?? '',
                                      // coin!.name ?? '',
                                      // coin!.imageUrl ?? '');
                                    }
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                assetImages(PNGAssets.send,
                                    width: 30, height: 30),
                                bodyMedText('Send', context, color: textColor)
                              ],
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(color: Colors.grey),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              isScrollControlled: true,
                              builder: (context) {
                                return SelectWalletWidget(
                                  onWalletSelect: (Wallet walletModel) {
                                    successLog(walletModel.toJson().toString());
                                    context.pop();
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20))),
                                      isScrollControlled: false,
                                      builder: (context) {
                                        return ReceiveQrCodeWidget(
                                            walletModel: walletModel);
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                assetImages(PNGAssets.recieve,
                                    width: 30, height: 30),
                                bodyMedText('Receive', context,
                                    color: textColor)
                              ],
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(color: Colors.grey),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            String url =
                                'https://onramp.money/main/buy/?appId=1&walletAddress=0x79a8c0bDdb40Efbf0B461F0403f9A148f0d6a800&fiatAmount=1000&fiatType=1&region=1&paymentMethod=1&redirectUrl=https://zeblock.io/order?address=0x79a8c0bDdb40Efbf0B461F0403f9A148f0d6a800';

                            context
                                .pushNamed(RouteName.explore, queryParameters: {
                              'url': url,
                              "enableSearch": '1',
                              "allowBack": '1',
                              "allowCopy": '0',
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                assetImages(PNGAssets.buy,
                                    width: 30, height: 30),
                                bodyMedText('Buy', context, color: textColor)
                              ],
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(color: Colors.grey),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              assetImages(PNGAssets.swap,
                                  width: 30, height: 30),
                              bodyMedText('Swap', context, color: textColor)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: height / 4,
                bottom: -(height / 1.8),
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        titleLargeText('Coins', context),
                        width10(),
                        PopupMenuButton<CoinGraphType>(
                          offset: const Offset(10, 15),
                          elevation: 1,
                          color: getTheme.colorScheme.background,
                          shadowColor: getTheme.colorScheme.onBackground,
                          surfaceTintColor: getTheme.colorScheme.background,
                          onSelected: provider.setGraphType,
                          position: PopupMenuPosition.under,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          itemBuilder: (context) =>
                              <PopupMenuItem<CoinGraphType>>[
                            ...CoinGraphType.values.map((e) => PopupMenuItem(
                                  value: e,
                                  child: bodyMedText(e.name, context),
                                ))
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 0),
                            decoration: BoxDecoration(
                              //     color: getTheme.colorScheme.primary
                              //         .withOpacity(0.1),
                              //     borderRadius: BorderRadius.circular(5),
                              border: Border(
                                  bottom: BorderSide(
                                      color: getTheme.colorScheme.primary)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                bodyMedText(provider.graphType.name.capitalize!,
                                    context,
                                    fontWeight: FontWeight.w500),
                                Icon(Icons.arrow_drop_down_rounded,
                                    color: getTheme.colorScheme.primary)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context.pushNamed(RouteName.importWallet,
                            queryParameters: {'token': '1'});
                        /* showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return SafeArea(
                                child: Column(
                              children: [
                                height50(),
                                const Expanded(child: CoinChatScreen()),
                              ],
                            ));
                          },
                        );*/
                      },
                      icon: const Icon(Icons.add),
                      label: bodyLargeText('Import', context,
                          color: getTheme.colorScheme.primary),
                    )
                  ],
                ),
              ),
            ],
          ),
          height10(),
        ],
      ),
    );
  }

  buildAppBar(BuildContext context, AuthProvider authProvider) {
    double walletBalance = 0;
    if (authProvider.user.wallet != null) {
      for (var wallet in authProvider.user.wallet!) {
        walletBalance += wallet.balance ?? 0;
      }
    }
    return buildCustomAppBar(
      // title: Text(getLang.helloWorld),
      // expandedHeight: 100,
      height: 120,
      pinned: false,
      isSliver: true,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getLang.helloWorld,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bodyLargeText('Wallet Balance', context,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9)),
            Provider.of<WalletProvider>(context, listen: true).gettingBalance ==
                    ButtonLoadingState.loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: loaderWidget(radius: 10),
                  )
                : displayLarge(
                    NumberFormat.currency(
                            locale: "en_US", symbol: '\$', decimalDigits: 6)
                        .format(walletBalance),
                    context,
                    textAlign: TextAlign.center,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
          ],
        ),
      ),
      actions: [
        const ToggleBrightnessButton(),
        IconButton(
            onPressed: () => context.pushNamed(RouteName.dashSetting),
            icon: const Icon(Icons.settings)),
      ],
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  List<String> get suggestions => ["One", "Two", "Three"];

  @override
  Widget buildResults(BuildContext context) {
    // This is where you would build the search results UI.
    return const Text("This is the search results page");
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    throw UnimplementedError();
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    throw UnimplementedError();
  }
}

void showCustomBottomSheet(BuildContext context) {
  CustomBottomSheet.show(
    context: context,
    curve: Curves.bounceIn,
    duration: 200,
    dismissible: false,
    onDismiss: () async {
      bool? willPop = await CustomBottomSheet.show<bool>(
        context: context,
        // backgroundColor: Colors.transparent,
        showCloseIcon: false,
        curve: Curves.bounceIn,
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: buttonStyle(bgColor: Colors.green),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: buttonStyle(bgColor: Colors.red),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      logD('will pop scope $willPop');
      return willPop ?? false;
    },
    builder: (context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Custom Bottom Sheet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const FlutterLogo(size: 100),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      );
    },
  );
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverPersistentHeaderDelegate({required this.child});
  final Widget child;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        height: 50,
        // decoration: BoxDecoration(gradient: buildAppbarGradient()),
        child: child);
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    throw UnimplementedError();
  }
}
