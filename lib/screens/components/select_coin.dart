import 'package:flutter/material.dart';
import '../../utils/default_logger.dart';
import '/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/asset_constants.dart';
import '../../models/coin_model.dart';
import '../../models/user/user_data_model.dart';
import '../../providers/WalletProvider.dart';
import '../../repo_injection.dart';
import '../../utils/my_toasts.dart';
import '../../utils/picture_utils.dart';
import '../../utils/sized_utils.dart';
import '../../utils/text.dart';
import '../../widgets/MultiStageButton.dart';
import '../../widgets/skeleton.dart';
import '../BottomNav/dash_setting_page.dart';
import 'empty_list_widget.dart';

class SelectCoinWidget extends StatefulWidget {
  const SelectCoinWidget(
      {super.key,
      required this.onWalletSelect,
      this.token = true,
      this.import = false});
  final bool token;
  final bool import;
  final void Function(Coin walletModel, double balance) onWalletSelect;
  @override
  State<SelectCoinWidget> createState() => _SelectCoinWidgetState();
}

class _SelectCoinWidgetState extends State<SelectCoinWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      sl.get<WalletProvider>().selectCoin(context, token: widget.token);
    });
    /* future(2000,(){
      context.pop();
      context.goNamed(RouteName.search);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                color: getTheme.brightness == Brightness.light
                    ? Colors.white
                    : null,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsetsDirectional.symmetric(
                                  vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:
                                      getTheme.textTheme.displayLarge?.color),
                              height: 5,
                              width: 30,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            displayMedium('Select Your Asset', context)
                          ],
                        ),
                        height20(),
                        Expanded(
                          child: buildBody(provider, scrollController),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [ToggleBrightnessButton()],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildBody(WalletProvider provider, ScrollController scrollController) {
    List<Coin> coins = [];
    List<Wallet> userWallets = sl.get<AuthProvider>().user.wallet ?? [];
    if (widget.token && !widget.import) {
      for (var element in provider.coins) {
        if (userWallets
            .any((wallet) => wallet.tokenName == element.parentWallet)) {
          coins.add(element);
        }
      }
    } else {
      coins = provider.coins;
      if (widget.import) {
        coins.insert(
            0, Coin(symbol: 'all', name: 'Multi Import', disabled: false));
      }
    }

    return Container(
      child: (provider.loadingWallets == ButtonLoadingState.loading) ||
              (provider.loadingWallets == ButtonLoadingState.idle &&
                  provider.coins.isNotEmpty)
          ? ListView.builder(
              controller: scrollController,
              itemBuilder: (context, i) {
                bool loading =
                    provider.loadingWallets == ButtonLoadingState.loading;
                Coin? coin;
                if (!loading) {
                  coin = coins[i];
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // bodyMedText('Etherium', context,
                      //     color: Colors.grey, fontWeight: FontWeight.w500),
                      _CoinTileWidget(
                          loading: loading,
                          coin: coin,
                          multiImport: !loading && widget.import && i == 0,
                          onWalletSelect: widget.onWalletSelect),
                    ],
                  ),
                );
              },
              itemCount: provider.loadingWallets == ButtonLoadingState.loading
                  ? 7
                  : coins.length,
            )
          : const EmptyListWidget(
              text: 'Coins not Found',
              asset: LottieAssets.emptyBox,
              height: 700),
    );
  }
}

class _CoinTileWidget extends StatelessWidget {
  const _CoinTileWidget(
      {super.key,
      required this.onWalletSelect,
      required this.loading,
      this.coin,
      this.multiImport = false});
  final void Function(Coin walletModel, double balance) onWalletSelect;
  final bool loading;
  final Coin? coin;
  final bool multiImport;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        enabled: loading ? false : ((coin!.disabled ?? true) == false),
        onTap: loading
            ? null
            : () async {
                if ((coin!.disabled ?? true) == false) {
                  // context.pop();
                  onWalletSelect(coin!, 10);
                } else {
                  Toasts.fToast('This wallet is disabled');
                }
              },
        leading: loading
            ? buildShimmer(w: 60.0, h: 60.0, shape: BoxShape.circle)
            : multiImport
                ? const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    child: buildCachedImageWithLoading(coin!.imageUrl ?? '',
                        loadingMode: ImageLoadingMode.shimmer),
                  ),
        title: loading
            ? buildShimmer(radius: 2, w: 100, h: 13)
            : titleLargeText(
                multiImport ? coin!.name!.toUpperCase() : (coin!.symbol ?? ''),
                context),
        subtitle: loading
            ? buildShimmer(radius: 2, w: 70, h: 13)
            : !multiImport
                ? capText((coin!.name ?? ''), context,
                    color: Colors.grey, fontWeight: FontWeight.w500)
                : null,
        trailing: loading
            ? null
            : Icon(Icons.arrow_forward_ios_rounded,
                size: 15,
                color:
                    ((coin!.disabled ?? true) == true) ? Colors.grey : null));
  }
}
