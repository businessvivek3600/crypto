// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_global_tools/models/coin_model.dart';
import '../components/select_coin.dart';
import '/route_management/route_name.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/default_logger.dart';
import 'package:provider/provider.dart';
import '../../functions/functions.dart';
import '../../models/recent_users.dart';
import '../../providers/dashboard_provider.dart';
import '../../repo_injection.dart';
import '../../utils/my_toasts.dart';
import '../../widgets/MultiStageButton.dart';
import '../../widgets/skeleton.dart';
import '/utils/sized_utils.dart';

import '../../constants/asset_constants.dart';
import '../../utils/picture_utils.dart';
import '../../utils/text.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key, this.query});
  final String? query;
  // final List? recentUsers;
  // final WalletModel? wallet;
  @override
  _SearchUsersPageState createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  List<RecentUsers> recentUsers = [];
  var provider = sl.get<DashboardProvider>();
  Coin? wallet;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    provider.getRecentUsers(context);
    try {
      if (widget.query != null) {
        _searchController.text = widget.query!;
      }
      // if (widget.recentUsers != null && widget.recentUsers!.isNotEmpty) {
      //   for (var element in widget.recentUsers!) {
      //     recentUsers.add(element);
      //   }
      // }
    } catch (e) {}

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        filterSearchResults(_searchController.text);
      }
    });
    // wallet = widget.wallet;
    setState(() {});
  }

  void filterSearchResults(String query) {
    provider.searchUsers(context, query);
  }

  void clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: buildAppBar(context),
          body: Column(
            // padding: const EdgeInsetsDirectional.symmetric(
            //     horizontal: 10, vertical: 0),
            children: [
              // buildWalletTile(context),
              _searchController.text.isEmpty
                  ? buildRecentUsers(context, provider)
                  : buildSearchedUsers(context, provider),
              height100(),
            ],
          ),
        );
      },
    );
  }

  ListTile buildWalletTile(BuildContext context) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          isScrollControlled: true,
          builder: (context) {
            return SelectCoinWidget(
              onWalletSelect: (Coin walletModel, double balance) {
                successLog(walletModel.toJson().toString());
                setState(() {
                  // wallet = null;
                  context.pop();
                  wallet = walletModel;
                });
              },
            );
          },
        );
      },
      leading: wallet == null
          ? null
          : CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: buildCachedImageWithLoading(wallet!.imageUrl ?? '',
                  loadingMode: ImageLoadingMode.shimmer),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              titleLargeText(
                  wallet != null ? '${wallet!.name}' : 'Select Wallet',
                  context),
            ],
          ),
          if (wallet != null)
            capText('${wallet!.symbol}', context,
                color: Colors.grey, fontWeight: FontWeight.w500),
        ],
      ),
      trailing: wallet != null
          ? bodyMedText('Change', context,
              color: getTheme.colorScheme.primary, fontWeight: FontWeight.bold)
          : const Icon(Icons.arrow_forward_ios_rounded, size: 15),
    );
  }

  Widget buildSearchedUsers(BuildContext context, DashboardProvider provider) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildSearched(provider),
      ),
    );
  }

  Widget buildRecentUsers(BuildContext context, DashboardProvider provider) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                bodyLargeText('Recent', context,
                    fontWeight: FontWeight.bold, color: Colors.grey),
                TextButton(
                    onPressed: () {},
                    child: capText('History', context,
                        color: getTheme.colorScheme.primary))
              ],
            ),
            Expanded(child: buildRecent(provider)),
          ],
        ),
      ),
    );
  }

  Widget buildSearched(DashboardProvider provider) {
    return Container(
      child: (provider.loadingSearchUsers == ButtonLoadingState.loading) ||
              (provider.loadingSearchUsers == ButtonLoadingState.idle &&
                  provider.searchedUsers.isNotEmpty)
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 0),
              shrinkWrap: true,
              // controller: scrollController,
              itemBuilder: (context, i) {
                bool loading =
                    provider.loadingSearchUsers == ButtonLoadingState.loading;
                RecentUsers? user;
                if (!loading) {
                  user = provider.searchedUsers[i];
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // bodyMedText('Etherium', context,
                    //     color: Colors.grey, fontWeight: FontWeight.w500),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onTap: provider.loadingSearchUsers ==
                              ButtonLoadingState.loading
                          ? null
                          : () {
                              selectWallet(context);

                              /*  if ((user!.disabled ?? true) == false) {
                                  // context.pop();
                                  // widget.onWalletSelect(
                                  //     wallet, provider.recentUsers);
                                } else {
                                  Toasts.fToast('This user is disabled');
                                }*/
                            },
                      leading: loading
                          ? buildShimmer(
                              w: 50.0, h: 50.0, shape: BoxShape.circle)
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: getTheme.colorScheme.primary
                                  .withOpacity(0.05),
                              child: Icon(CupertinoIcons.person,
                                  color: getTheme.colorScheme.primary
                                      .withOpacity(0.7))),
                      title: loading
                          ? Row(
                              children: [
                                buildShimmer(radius: 2, w: 100, h: 13),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                bodyMedText(user!.username ?? '', context,
                                    fontWeight: FontWeight.bold),
                              ],
                            ),
                      /*    subtitle: loading
                          ? Row(
                              children: [
                                buildShimmer(radius: 2, w: 70, h: 13),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: capText(
                                      (user!.walletAddress ?? ''), context,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                                width5(),
                                GestureDetector(
                                  onTap: () {
                                    Toasts.fToast('Wallet Address copied');
                                  },
                                  child: const Icon(
                                    Icons.copy,
                                    size: 13,
                                  ),
                                )
                              ],
                            ),*/
                    ),
                    if (i <
                        (provider.loadingRecentUsers ==
                                    ButtonLoadingState.loading
                                ? 7
                                : provider.recentUsers.length) -
                            1)
                      Divider(color: Colors.grey[200]),
                  ],
                );
              },
              itemCount:
                  provider.loadingSearchUsers == ButtonLoadingState.loading
                      ? 7
                      : provider.searchedUsers.length,
            )
          : assetImages(PNGAssets.appLogo, height: 700),
    );
  }

  Widget buildRecent(DashboardProvider provider) {
    return Container(
      child: (provider.loadingRecentUsers == ButtonLoadingState.loading) ||
              (provider.loadingRecentUsers == ButtonLoadingState.idle &&
                  provider.recentUsers.isNotEmpty)
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 0),
              shrinkWrap: true,
              // controller: scrollController,
              itemBuilder: (context, i) {
                bool loading =
                    provider.loadingRecentUsers == ButtonLoadingState.loading;
                RecentUsers? user;
                if (!loading) {
                  user = provider.recentUsers[i];
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // bodyMedText('Etherium', context,
                    //     color: Colors.grey, fontWeight: FontWeight.w500),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onTap: provider.loadingRecentUsers ==
                              ButtonLoadingState.loading
                          ? null
                          : () {
                              selectWallet(context);
                              /*  if ((user!.disabled ?? true) == false) {
                                  // context.pop();
                                  // widget.onWalletSelect(
                                  //     wallet, provider.recentUsers);
                                } else {
                                  Toasts.fToast('This user is disabled');
                                }*/
                            },
                      leading: loading
                          ? buildShimmer(
                              w: 60.0, h: 60.0, shape: BoxShape.circle)
                          : CircleAvatar(
                              radius: 25,
                              backgroundColor: getTheme.colorScheme.primary
                                  .withOpacity(0.05),
                              child: Icon(CupertinoIcons.person,
                                  color: getTheme.colorScheme.primary
                                      .withOpacity(0.7))),
                      title: loading
                          ? Row(
                              children: [
                                buildShimmer(radius: 2, w: 100, h: 13),
                              ],
                            )
                          : Row(
                              children: [
                                bodyMedText(user!.username ?? '', context,
                                    fontWeight: FontWeight.bold),
                              ],
                            ),
                      subtitle: loading
                          ? Row(
                              children: [
                                buildShimmer(radius: 2, w: 70, h: 13),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: capText(
                                      (user!.walletAddress ?? ''), context,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                                width5(),
                                GestureDetector(
                                  onTap: () {
                                    Toasts.fToast('Wallet Address copied');
                                  },
                                  child: const Icon(
                                    Icons.copy,
                                    size: 13,
                                  ),
                                )
                              ],
                            ),
                    ),
                    if (i <
                        (provider.loadingRecentUsers ==
                                    ButtonLoadingState.loading
                                ? 7
                                : provider.recentUsers.length) -
                            1)
                      Divider(color: Colors.grey[200]),
                  ],
                );
              },
              itemCount:
                  provider.loadingRecentUsers == ButtonLoadingState.loading
                      ? 7
                      : provider.recentUsers.length,
            )
          : assetImages(PNGAssets.appLogo, height: 700),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: SizedBox(
        height: 35,
        child: TextFormField(
          controller: _searchController,
          style: const TextStyle(fontSize: 15),
          showCursor: true,
          autofocus: true,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search username',
            contentPadding:
                EdgeInsets.symmetric(vertical: 0, horizontal: paddingDefault),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: clearSearch,
                    child: const Icon(CupertinoIcons.clear_circled_solid),
                  ),
                width10(),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); // Hide keyboard
                    filterSearchResults(_searchController.text);
                  },
                  child: const Icon(CupertinoIcons.search),
                ),
                width10(),
              ],
            ),
          ),
          textInputAction: TextInputAction.search,
          onSaved: (_) {
            FocusScope.of(context).unfocus(); // Hide keyboard
            filterSearchResults(_searchController.text);
          },
        ),
      ),
      actions: [width10(paddingDefault), const ToggleBrightnessButton()],
    );
  }

  selectWallet(BuildContext routeCTX) {
    primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return SelectCoinWidget(
          onWalletSelect: (Coin walletModel, double balance) {
            // successLog(walletModel.toJson().toString());
            // successLog(users.toString());
            setState(() {
              // wallet = null;
              context.pop();
              wallet = walletModel;
              if (wallet != null) {
                provider.initTransaction(context, {
                  "parentWallet": wallet!.parentWallet,
                  "symbol": wallet!.symbol
                }).then((value) async {
                  // successLog(value.toString());
                  // successLog(users.toString());
                  if (value != null) {
                    await future(1000);
                    _searchController.clear();
                    routeCTX.pushNamed(RouteName.sendCoin, extra: value);
                  }
                });
              }
            });
          },
        );
      },
    );
  }
}
