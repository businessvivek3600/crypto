// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../models/coin_model.dart';
import '../../utils/sp_utils.dart';
import '../components/select_coin.dart';
import '/providers/auth_provider.dart';
import '/widgets/MultiStageButton.dart';
import '../../models/user/user_data_model.dart';
import '../../services/auth_service.dart';
import '../../utils/color.dart';
import '/providers/WalletProvider.dart';
import '/utils/default_logger.dart';
import '/utils/my_toasts.dart';
import 'package:provider/provider.dart';
import '../../repo_injection.dart';
import '../../utils/loader.dart';
import '/route_management/route_name.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';

import '../../widgets/FadeScaleTransitionWidget.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen(
      {super.key, this.token = false, this.import = false});
  final bool token;
  final bool import;

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  AuthProvider provider = sl.get<AuthProvider>();
  TextEditingController mnemonics = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Coin? coin;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        showSelectCoinSheet();
      }
    });
  }

  String? mnemonicValidator(String? val) {
    RegExp pattern = RegExp(r'^[a-zA-Z\s]*$');
    if (val != null) {
      bool hasMatch = pattern.hasMatch(val.trim());
      if (!hasMatch) {
        return 'Mnemonics should only contain alphanumeric,_.';
      }
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Container(
        decoration: BoxDecoration(gradient: globalPageGradient()),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            title: bodyLargeText('Import your Wallet', context,
                color: Colors.white),
            actions: const [ToggleBrightnessButton()],
          ),
          body: Consumer<WalletProvider>(
            builder: (context, provider, child) {
              return Container(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: spaceDefault),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyCustomAnimatedWidget(
                              child: headLineText6(
                                  "Import your existing wallet", context,
                                  color: Colors.white),
                            ),
                            height10(),
                            MyCustomAnimatedWidget(
                              child: bodyLargeText(
                                  "This is how you you see wallet details and make payment, buy coins.",
                                  context,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  opacity: 0.3),
                            ),
                            height20(),
                            ListTile(
                              onTap: () async {
                                showSelectCoinSheet();
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: paddingDefault,
                                  vertical: paddingDefault / 2),
                              leading: coin != null && coin!.symbol != 'all'
                                  ? Image.network(coin!.imageUrl ?? '',
                                      height: 30, width: 30)
                                  : const Icon(Icons.mode_standby_sharp,
                                      color: Colors.white),
                              title: coin != null
                                  ? bodyLargeText(coin!.name ?? '', context,
                                      color: Colors.white)
                                  : bodyLargeText('Select Coin', context,
                                      color: Colors.white),
                              trailing: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                            ),
                            height20(),
                            MyCustomAnimatedWidget(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: TextFormField(
                                      controller: mnemonics,
                                      autovalidateMode: AutovalidateMode.always,
                                      textInputAction: TextInputAction.newline,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        hintText: 'Enter mnemonics',
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                      ),
                                      validator: mnemonicValidator,
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Positioned(
                                      top: 0,
                                      right: paddingDefault / 2,
                                      child: IconButton(
                                        onPressed: pasteFromClipboard,
                                        icon: const Icon(
                                            Icons.content_paste_rounded,
                                            color: Colors.amber,
                                            size: 15),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyCustomAnimatedWidget(
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
                                            backgroundColor:
                                                getTheme.colorScheme.primary),
                                        onPressed: provider
                                                        .verifyingMnemonics !=
                                                    ButtonLoadingState
                                                        .loading &&
                                                mnemonics.text.isNotEmpty
                                            ? () async {
                                                primaryFocus?.unfocus();
                                                infoLog((_formKey.currentState
                                                        ?.validate())
                                                    .toString());
                                                if (_formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  setState(() {});
                                                  verify(
                                                    mnemonics.text.split(' '),
                                                  );
                                                }
                                              }
                                            : null,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            bodyLargeText('Confirm', context,
                                                color: Colors.white),
                                            if (provider.verifyingMnemonics ==
                                                ButtonLoadingState.loading)
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
                      ),
                      height20(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool verifying = false;
  verify(List<String> str) async {
    if (coin != null) {
      verifying = true;
      setState(() {});

      (Map<String, dynamic>, bool)? data = await sl
          .get<WalletProvider>()
          .verifyMnemonics(str, imported: true, chain: coin!.contractAddress);
      if (data != null && data.$2) {
        try {
          if (!widget.token) {
            UserData user = UserData.fromJson(data.$1);
            String token = data.$1['token'];
            await StreamAuth().signIn(user, token);
            Toasts.fToast('You have verified successfully!');
            context.goNamed(RouteName.createUsername);
          } else {
            List<Wallet> wallets = (data.$1['wallets'] ?? [])
                .map<Wallet>((e) => Wallet.fromJson(e))
                .toList();
            if (wallets.isNotEmpty) {
              if ((sl.get<AuthProvider>().user.wallet ?? [])
                  .any((w) => w.walletAddress != wallets.first.walletAddress)) {
                await addNewWalletToUser(wallets, str.join(' '));
              } else {
                Toasts.fToast('Wallet already exists!');
              }
            }
          }
        } catch (e) {
          errorLog(e.toString());
          Toasts.fToast('Some thing happened wrong!');
        }
      }
      verifying = false;
      setState(() {});
    } else {
      Toasts.fToast('Please select coin');
    }

    return;
  }

  Future<void> addNewWalletToUser(List<Wallet> wallets, String mnemonic) async {
    List<Wallet> myWallets = sl.get<AuthProvider>().user.wallet ?? [];
    try {
      for (var element in wallets) {
        myWallets.add(element);
        sl.get<AuthProvider>().user.wallet = myWallets;
        await sl.get<AuthProvider>().updateUser(sl.get<AuthProvider>().user);
        await SpUtils().setMnemonic(mnemonic);
        context.pop();
        Toasts.fToast('Wallet imported successfully!');
      }
    } catch (e) {
      errorLog(e.toString(), 'addNewWalletToUser');
      // Toasts.fToast('Some thing happened wrong!');
    }
  }

  Future<void> pasteFromClipboard() async {
    primaryFocus?.unfocus();
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        mnemonics.text = data.text!;
        setState(() {});
      } else {
        Toasts.fToast('Nothing to paste');
      }
    } catch (e) {
      Toasts.fToast('Failed to paste from clipboard');
    }
  }

  Future<void> showSelectCoinSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return SelectCoinWidget(
          token: widget.token,
          import: widget.import,
          onWalletSelect: (Coin coin, double balance) async {
            this.coin = coin;
            context.pop();
            setState(() {});
          },
        );
      },
    );
  }
}
