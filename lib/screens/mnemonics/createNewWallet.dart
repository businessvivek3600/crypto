// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/widgets/MultiStageButton.dart';
import '/models/user/user_data_model.dart';
import '/services/auth_service.dart';
import '../../utils/color.dart';
import '../../utils/global_ui_widgets.dart';
import '/providers/WalletProvider.dart';
import '/utils/default_logger.dart';
import '/utils/my_toasts.dart';
import 'package:provider/provider.dart';
import '../../repo_injection.dart';
import '../../utils/loader.dart';
import '/functions/functions.dart';
import '/route_management/route_name.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';

import '../../widgets/FadeScaleTransitionWidget.dart';

class CreateNewWallet extends StatefulWidget {
  const CreateNewWallet({super.key, required this.data});
  final List data;
  @override
  State<CreateNewWallet> createState() => _CreateNewWalletState();
}

class _CreateNewWalletState extends State<CreateNewWallet> {
  WalletProvider provider = sl.get<WalletProvider>();
  bool savedIt = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: globalPageGradient()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          title: bodyLargeText(
            'Create New Wallet',
            context,
            color: Colors.white,
          ),
          actions: const [ToggleBrightnessButton()],
        ),
        body: FutureBuilder(
            future: future(200),
            builder: (context, a) {
              if (a.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              return _BodyWidget(
                  savedIt: savedIt,
                  data: widget.data.map((e) => e.toString()).toList(),
                  onSave: () async {
                    await future(1000);
                    setState(() {
                      savedIt = true;
                    });
                  });
            }),
      ),
    );
  }
}

class _BodyWidget extends StatefulWidget {
  const _BodyWidget({
    super.key,
    required this.savedIt,
    required this.data,
    required this.onSave,
  });
  final bool savedIt;
  final List<String> data;
  final VoidCallback onSave;

  @override
  State<_BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<_BodyWidget> {
  WalletProvider provider = sl.get<WalletProvider>();
  List<String> newMnemonics = [];
  bool verifying = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      refreshOptions(true);
    });
  }

  refreshOptions(bool loading) async {
    List<String> newList = [];
    newMnemonics.clear();
    for (var element in widget.data) {
      newList.add(element.toString());
    }
    newMnemonics = newList;
    provider
        .generateUniAndOptionsForVerifyNewWallet(widget.data, loading)
        .then((data) {})
        .then((value) => setState(() {}));
  }

  verify() async {
    if (checkListMatch()) {
      verifying = true;
      setState(() {});
      (Map<String, dynamic>, bool)? data =
          await provider.verifyMnemonics(newMnemonics, imported: false);
      if (data != null && data.$2) {
        try {
          warningLog(data.$1.toString());
          UserData user = UserData.fromJson(data.$1);
          String token = data.$1['token'];
          await StreamAuth().signIn(user, token);
          Toasts.fToast('You have verified successfully!');
          context.goNamed(RouteName.createUsername);
        } catch (e) {
          errorLog(e.toString());
          Toasts.fToast('Some thing happened wrong!');
        }
      }
      verifying = false;
      setState(() {});
      return;
    }
    verifying = false;
    setState(() {});
    refreshOptions(false);
  }

  bool checkListMatch() {
    bool match = false;
    for (var element in newMnemonics) {
      var i = newMnemonics.indexOf(element);
      warningLog(
          'ele: $element --> real: ${widget.data[i]}  (${element == widget.data[i]})');
      match = element == widget.data[i];
      if (!match) return match;
    }
    return match;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: spaceDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyCustomAnimatedWidget(
                child: headLineText6(
                    widget.savedIt
                        ? 'Fill in the missing gaps'
                        : "Let's Get You Secure",
                    context,
                    color: Colors.white),
              ),
              MyCustomAnimatedWidget(
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: bodyLargeText(
                      widget.savedIt
                          ? "Click on the missing words in the right sequence to create your wallet"
                          : "These are your mnemonics and the password to your wallet. Store it safely.",
                      context,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      opacity: 0.3),
                ),
              ),
              !provider.loadingInit &&
                      provider.creatingMnemonics ==
                          ButtonLoadingState.completed &&
                      newMnemonics.length == 12
                  ? MyCustomAnimatedWidget(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // height50(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: spaceDefault * 2),
                                  child: buildMnemonicText(
                                      context,
                                      newMnemonics.sublist(0, 4),
                                      provider.specificIndex,
                                      0,
                                      provider.uniqueNumbers
                                          .where((element) => element < 4)
                                          .toList()),
                                ),
                              ),
                              width10(),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: buildMnemonicText(
                                      context,
                                      newMnemonics.sublist(4, 8),
                                      provider.specificIndex,
                                      4,
                                      provider.uniqueNumbers
                                          .where((element) =>
                                              element < 8 && element >= 4)
                                          .toList()),
                                ),
                              ),
                              width10(),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: spaceDefault * 2),
                                  child: buildMnemonicText(
                                      context,
                                      newMnemonics.sublist(8, 12),
                                      provider.specificIndex,
                                      8,
                                      provider.uniqueNumbers
                                          .where((element) =>
                                              element < 12 && element >= 8)
                                          .toList()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                      child: MyCustomAnimatedWidget(
                        child: Center(child: loaderWidget()),
                      ),
                    ),
              const Spacer(),
              if (!widget.savedIt &&
                  !provider.loadingInit &&
                  provider.creatingMnemonics == ButtonLoadingState.completed)
                MyCustomAnimatedWidget(
                  child: FilledButton.tonalIcon(
                      onPressed: () {
                        copyToClipboard(newMnemonics.join(' '),
                            'Mnemonics copied to clipboard');
                      },
                      icon:
                          const Icon(Icons.copy, size: 15, color: Colors.white),
                      label: capText('Copy', context,
                          fontSize: 15, color: Colors.white)),
                ),
              if (widget.savedIt)
                MyCustomAnimatedWidget(
                  child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: [
                      ...provider.options.map((e) {
                        var i = provider.options.indexOf(e);
                        return GestureDetector(
                            onTap: () {
                              newMnemonics[provider.specificIndex!] = e;
                              provider.uniqueNumbers
                                  .remove(provider.specificIndex);
                              if (provider.uniqueNumbers.isNotEmpty) {
                                provider.specificIndex =
                                    provider.uniqueNumbers.first;
                              }
                              provider.options.remove(e);
                              setState(() {});
                            },
                            child: globalCard(
                              color: Colors.transparent,
                              child: Container(
                                  padding: EdgeInsetsDirectional.symmetric(
                                      horizontal: paddingDefault,
                                      vertical: paddingDefault),
                                  decoration: const BoxDecoration(),
                                  child: capText(e, context,
                                      fontSize: 15, color: Colors.white)),
                            ));
                      }),
                    ],
                  ),
                ),
              height10(),
              widget.savedIt &&
                      provider.creatingMnemonics == ButtonLoadingState.completed
                  ? buildVerifyWidget(context, provider)
                  : buildSavedItWidget(context),
            ],
          ),
        );
      },
    );
  }

  MyCustomAnimatedWidget buildVerifyWidget(
      BuildContext context, WalletProvider provider) {
    return MyCustomAnimatedWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          height20(),
          Padding(
            padding: EdgeInsets.all(spaceDefault),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: getTheme.colorScheme.primary),
                      onPressed: provider.uniqueNumbers.isEmpty &&
                              !provider.loadingInit &&
                              !verifying
                          ? () async {
                              verify();
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          bodyLargeText('Verify', context, color: Colors.white),
                          if (verifying)
                            Row(
                              children: [
                                width10(),
                                loaderWidget(radius: 8),
                              ],
                            )
                        ],
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Card buildMnemonicText(BuildContext context, List sublist, int? specificIndex,
      int startIndex, List<int> uniqueNumber) {
    return globalCard(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(paddingDefault),
          child: Wrap(
            children: [
              ...sublist.map((e) {
                int i = sublist.indexOf(e);
                int orgIndex = (i + startIndex);
                bool selected = specificIndex == orgIndex && widget.savedIt;
                bool fillIt =
                    uniqueNumber.any((element) => element == orgIndex) &&
                        widget.savedIt;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (uniqueNumber.contains(orgIndex)) {
                          provider.setSpecificIndex(orgIndex);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: selected
                                ? Border.all(
                                    color: getTheme.colorScheme.primary)
                                : null),
                        child: Row(
                          children: [
                            capText('${orgIndex + 1}. ', context,
                                color: Colors.white),
                            Expanded(
                              child: capText(
                                  (fillIt ? '-  -  -  -  - ' : e), context,
                                  color: Colors.white,
                                  maxLines: 1,
                                  fontWeight: fillIt ? FontWeight.w900 : null,
                                  textAlign: fillIt ? TextAlign.center : null),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i != sublist.length - 1)
                      const Divider(color: Colors.white)
                  ],
                );
              }).toList()
            ],
          ),
        ));
  }

  MyCustomAnimatedWidget buildSavedItWidget(BuildContext context) {
    return MyCustomAnimatedWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          height20(),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 2 * spaceDefault),
              child: bodyMedText(
                  '*If you lose your mnemonics phrase your wallet cannot be recovered.',
                  context,
                  textAlign: TextAlign.center,
                  color: Colors.red)),
          Padding(
            padding: EdgeInsets.all(spaceDefault),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: getTheme.colorScheme.primary),
                      onPressed: () async {
                        widget.onSave();
                        /*context.pushNamed(RouteName.createNewWallet,
                                          queryParameters: {
                                            'data': jsonEncode(widget.data),
                                            'saved': savedIt ? '1' : '0'
                                          });*/
                        setState(() {});
                      },
                      child: bodyLargeText('Ok, I saved it', context,
                          color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
