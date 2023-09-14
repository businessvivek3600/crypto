import 'package:flutter/material.dart';
import '/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/asset_constants.dart';
import '../../models/user/user_data_model.dart';
import '../../providers/WalletProvider.dart';
import '../../repo_injection.dart';
import '../../utils/picture_utils.dart';
import '../../utils/sized_utils.dart';
import '../../utils/text.dart';
import '../../widgets/skeleton.dart';
import '../BottomNav/dash_setting_page.dart';
import 'empty_list_widget.dart';

class SelectWalletWidget extends StatefulWidget {
  const SelectWalletWidget({super.key, required this.onWalletSelect});
  final void Function(Wallet walletModel) onWalletSelect;
  @override
  State<SelectWalletWidget> createState() => _SelectWalletWidgetState();
}

class _SelectWalletWidgetState extends State<SelectWalletWidget> {
  var authProvider = sl.get<AuthProvider>();
  List<Wallet> wallets = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      wallets = authProvider.user.wallet ?? [];
      setState(() {
        loading = false;
      });
    });
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
                          children: [displayMedium('Select Wallet', context)],
                        ),
                        height20(),
                        Expanded(
                          child: buildBody(loading, scrollController),
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

  Widget buildBody(bool loading, ScrollController scrollController) {
    return Container(
      child: !loading && wallets.isNotEmpty
          ? ListView.builder(
              controller: scrollController,
              itemBuilder: (context, i) {
                Wallet? wallet;
                if (!loading) {
                  wallet = wallets[i];
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // bodyMedText('Etherium', context,
                      //     color: Colors.grey, fontWeight: FontWeight.w500),
                      ListTile(
                          // enabled: loading
                          //     ? false
                          //     : ((wallet!.disabled ?? true) == false),
                          onTap: loading
                              ? null
                              : () {
                                  // if ((wallet!.disabled ?? true) == false) {
                                  //   // context.pop();
                                  widget.onWalletSelect(wallet!);
                                  // } else {
                                  //   Toasts.fToast('This wallet is disabled');
                                  // }
                                },
                          leading: loading
                              ? buildShimmer(
                                  w: 60.0, h: 60.0, shape: BoxShape.circle)
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  child: buildCachedImageWithLoading(
                                      wallet!.imageUrl ?? '',
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
                                            wallet!.tokenName ?? '', context),
                                      ],
                                    ),
                              height10(),
                              loading
                                  ? Row(
                                      children: [
                                        buildShimmer(radius: 2, w: 70, h: 13),
                                      ],
                                    )
                                  : capText(
                                      (wallet!.walletAddress ?? ''), context,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                            ],
                          ),
                          trailing: loading
                              ? null
                              : Icon(Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                  color: !loading ? Colors.grey : null)),
                    ],
                  ),
                );
              },
              itemCount: loading ? 7 : wallets.length,
            )
          : const EmptyListWidget(
              text: 'No Wallets Found',
              asset: LottieAssets.wallet,
              height: 700),
    );
  }
}
