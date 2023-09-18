// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../components/appbar.dart';
import '/utils/color.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../functions/sqlDatabase.dart';
import '/providers/auth_provider.dart';
import '/route_management/route_name.dart';
import '/screens/App/scan_qr_code_page.dart';
import '/utils/date_utils.dart';
import '/widgets/MultiStageButton.dart';
import '/widgets/buttonStyle.dart';
import 'package:provider/provider.dart';
import '../../../functions/functions.dart';
import '../../../providers/WalletProvider.dart';
import '../../../repo_injection.dart';
import '../../../utils/loader.dart';
import '/constants/asset_constants.dart';
import '/utils/default_logger.dart';
import '/screens/BottomNav/dash_setting_page.dart';
import '/utils/my_toasts.dart';
import '/utils/picture_utils.dart';
import '/utils/sized_utils.dart';
import '/utils/text.dart';

class SendCoinPage extends StatefulWidget {
  const SendCoinPage({super.key, this.data});
  final Map<String, dynamic>? data;

  @override
  State<SendCoinPage> createState() => _SendCoinPageState();
}

class _SendCoinPageState extends State<SendCoinPage> {
  var provider = sl.get<WalletProvider>();
  final amount = TextEditingController();
  final recipientAddress = TextEditingController();
  double balance = 0;
  double? percentVal;
  List<double> percents = [30, 50, 70, 100];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    provider.loadingConfirmation = ButtonLoadingState.completed;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      infoLog(widget.data.toString());
      sl
          .get<WalletProvider>()
          .getBalance(
              widget.data!['wallet']['tokenName'] ?? '',
              widget.data!['wallet']['walletAddress'] ?? '',
              widget.data!['coin']['contractAddress'] ?? '')
          .then((value) {
        if (value != null) {
          balance = value['balance'].toDouble();
          // balance = 234534567856789067.1234567890;
          if (balance > 0) {
            percentVal = percents.first;
            amount.text = (balance * percentVal! / 100).toStringAsFixed(6);
          }
        }
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: buildAppBar(context, provider),
            body: buildForm(context, provider),
            bottomNavigationBar: buildSendButton(context, provider),
          ),
        );
      },
    );
  }

  Form buildForm(BuildContext context, WalletProvider provider) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spaceDefault),
          child: Column(
            children: [
              height20(),
              bodyMedText('Wallet Balance', context,
                  fontWeight: FontWeight.bold, color: Colors.grey),
              height10(),
              provider.gettingBalance == ButtonLoadingState.loading
                  ? loaderWidget(radius: 10)
                  : displayLarge(balance.toStringAsFixed(6), context,
                      textAlign: TextAlign.center),
              height30(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bodyMedText('Amount', context,
                      fontWeight: FontWeight.bold, color: Colors.grey),
                  height10(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TextFormField(
                      controller: amount,
                      inputFormatters: [
                        NoDoubleDecimalFormatter(allowOneDecimal: 1)
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: 'Enter Amount',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          prefixIcon:
                              const Icon(Icons.account_balance_wallet_rounded),
                          suffix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              width10(),
                              CircleAvatar(
                                  radius: 10,
                                  backgroundColor: getTheme.colorScheme.primary
                                      .withOpacity(0.05),
                                  child: buildCachedNetworkImage(
                                      widget.data!['coin']['imageUrl'] ?? '')),
                              width5(),
                              bodyMedText(
                                  widget.data!['coin']['symbol'], context,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ],
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  height10(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...percents.map(
                        (e) {
                          bool selected = percentVal == e;
                          return GestureDetector(
                            onTap: () => onSelectPercent(e),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                    padding: EdgeInsets.all(paddingDefault),
                                    color: selected
                                        ? getTheme.colorScheme.primary
                                            .withOpacity(0.7)
                                        : getTheme.colorScheme.secondary
                                            .withOpacity(0.3),
                                    child: capText('$e%', context,
                                        color: selected
                                            ? Colors.white
                                            : getTheme.brightness ==
                                                    Brightness.dark
                                                ? Colors.grey
                                                : Colors.black54))),
                          );
                        },
                      )
                    ],
                  ),
                  height20(),
                  bodyMedText('Wallet Address', context,
                      fontWeight: FontWeight.bold, color: Colors.grey),
                  height10(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Builder(builder: (context) {
                      String address =
                          (widget.data!['wallet']['walletAddress']);
                      return TextFormField(
                        initialValue:
                            (address.split('').sublist(0, 5)).join('') +
                                ('......') +
                                (address.split('').sublist(
                                        address.length - 5, address.length))
                                    .join(''),
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  copyToClipboard(
                                      address, 'Wallet address copied');
                                  // Toasts.fToast('Wallet address copied');
                                },
                                icon: Icon(
                                  Icons.copy,
                                  color: getTheme.brightness == Brightness.dark
                                      ? Colors.white
                                      : const Color(0xC01B279F),
                                )),
                            disabledBorder: InputBorder.none,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none),
                      );
                    }),
                  ),
                  height20(),
                  bodyMedText('Recipient Address', context,
                      fontWeight: FontWeight.bold, color: Colors.grey),
                  height10(),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Builder(builder: (context) {
                          // String address =
                          // (widget.data!['wallet']['walletAddress']);
                          return TextFormField(
                            // initialValue:
                            //     (address.split('').sublist(0, 5)).join('') +
                            //         ('......') +
                            //         (address.split('').sublist(
                            //                 address.length - 5, address.length))
                            //             .join(''),
                            readOnly: true,
                            controller: recipientAddress,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              AlphaNumericFormatter(allowOneDecimal: 0)
                            ],
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                prefixIcon: const Icon(Icons.person),
                                suffixIcon: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    width10(),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        recipientAddress.text = '';
                                      }),
                                      child: const Icon(Icons.cancel_rounded,
                                          size: 15),
                                    ),
                                    IconButton(
                                      onPressed: pasteFromClipboard,
                                      icon: const Icon(
                                          Icons.content_paste_rounded,
                                          color: Colors.amber,
                                          size: 15),
                                    ),
                                  ],
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter recipient address';
                              }
                              return null;
                            },
                          );
                        }),
                      ),
                    ),
                    width10(),
                    //create qr code with same height as textfield
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => SendViaScanQRViewWidget(
                                  onDataScanned: (barcode) {
                                    if (barcode != null) {
                                      String address = '';
                                      if ((barcode.code ?? '').contains(':')) {
                                        address =
                                            (barcode.code ?? '').split(':')[1];
                                      } else {
                                        address = barcode.code ?? '';
                                      }
                                      recipientAddress.text = address;
                                      infoLog(barcode.code ?? '',
                                          'complete address');
                                      infoLog(recipientAddress.text,
                                          'filterd address');
                                      context.pop();
                                    }
                                  },
                                ));
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color:
                                getTheme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.qr_code_rounded),
                      ),
                    ),
                  ])
                ],
              ),
            ],
          ),
        ));
  }

  Padding buildSendButton(BuildContext context, WalletProvider provider) {
    return Padding(
      padding: EdgeInsets.all(spaceDefault),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
                onPressed: provider.loadingConfirmation ==
                        ButtonLoadingState.loading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          var data = {
                            "parentWallet": widget.data!['coin']
                                ['parentWallet'],
                            "contractAddress": widget.data!['coin']
                                ['contractAddress'],
                            "address": widget.data!['wallet']['walletAddress'],
                            "privateKey": widget.data!['wallet']['privateKey'],
                            "amount": amount.text.trim(),
                            "toAddress": recipientAddress.text.trim(),
                          };
                          successLog(data.toString());

                          provider.confirmTransaction(data).then((value) {
                            if (value != null) {
                              data.addAll(value.$1);
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                enableDrag: true,
                                isScrollControlled: true,
                                elevation: 10,
                                barrierColor: getTheme
                                    .textTheme.displayLarge?.color
                                    ?.withOpacity(0.2),
                                builder: (BuildContext context) {
                                  return _SendConfirmationSheet(
                                      data: data, coin: widget.data!['coin']);
                                },
                              );
                            }
                          });
                        }

                        ///
                        //   successLog(data.toString());
                        //   showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return ReceiptDialog(h: 500, w: Get.width);
                        //     },
                        //   );
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    bodyLargeText('Verify', context, color: Colors.white),
                    if (provider.loadingConfirmation ==
                        ButtonLoadingState.loading)
                      Row(
                        children: [
                          width10(),
                          loaderWidget(radius: 8),
                        ],
                      )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Future<void> pasteFromClipboard() async {
    primaryFocus?.unfocus();
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        recipientAddress.text = data.text!;
        setState(() {});
      } else {
        Toasts.fToast('Nothing to paste');
      }
    } catch (e) {
      Toasts.fToast('Failed to paste from clipboard');
    }
  }

  PreferredSize buildAppBar(BuildContext context, WalletProvider provider) {
    return buildCustomAppBar(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20))),
      title: titleLargeText('Send', context, color: Colors.white),
      actions: const [ToggleBrightnessButton()],
      height: kToolbarHeight + 30,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: widget.data != null
            ? Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCachedImageWithLoading(
                        widget.data!['coin']['imageUrl'] ?? '',
                        h: 25,
                        w: 25),
                    width10(),
                    bodyLargeText(widget.data!['coin']['symbol'], context,
                        fontWeight: FontWeight.bold, color: Colors.white)
                  ],
                ))
            : const SizedBox.shrink(),
      ),
    );
  }

  onSelectPercent(double e) {
    // if (balance > 0) {
    percentVal = e;
    amount.text = (balance * percentVal! / 100).toStringAsFixed(6);
    setState(() {});
    // }
  }
}

class _SendConfirmationSheet extends StatefulWidget {
  const _SendConfirmationSheet(
      {super.key, required this.data, required this.coin});
  final Map<String, dynamic> data;
  final Map<String, dynamic> coin;

  @override
  State<_SendConfirmationSheet> createState() => __SendConfirmationSheetState();
}

class __SendConfirmationSheetState extends State<_SendConfirmationSheet> {
  @override
  Widget build(BuildContext context) {
    print(widget.data);
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: Container(
            height: 500,
            decoration: BoxDecoration(color: getTheme.colorScheme.background),
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
                              color: getTheme.textTheme.displayLarge?.color),
                          height: 5,
                          width: 30,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        displayMedium('Confirm Details', context,
                            color: getTheme.colorScheme.primary)
                      ],
                    ),
                    height20(),
                    Expanded(
                      child: buildBody(provider, widget.data),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: getTheme.colorScheme.background,
                    padding: EdgeInsets.all(spaceDefault),
                    child: Row(
                      children: [
                        Expanded(
                            child: FilledButton(
                                onPressed: () {
                                  context.pop();
                                  Toasts.fToast('Transaction rejected');
                                },
                                style: buttonStyle(bgColor: Colors.red),
                                child: bodyLargeText('Reject', context,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        width10(),
                        Expanded(
                            child: FilledButton.icon(
                                onPressed: provider.loadingInitTrans ==
                                        ButtonLoadingState.loading
                                    ? null
                                    : () async {
                                        provider
                                            .initTransaction(
                                                context, widget.data)
                                            .then((value) async {
                                          if (value != null) {
                                            context.pop();
                                            await future(1000);
                                            var successData = widget.data;
                                            successData.addAll(value);
                                            successData
                                                .addAll({'coin': widget.coin});
                                            successLog(successData.toString());
                                            // save transaction to sqldb

                                            Map<String, dynamic> data = {
                                              "address": widget.data['address'],
                                              "amount": widget.data['amount'],
                                              "toAddress":
                                                  widget.data['toAddress'],
                                              "name": widget.coin['name'],
                                              "symbol": widget.coin['symbol'],
                                              "parentWallet":
                                                  widget.coin['parentWallet'],
                                              "imageUrl":
                                                  widget.coin['imageUrl'],
                                              "transactionId":
                                                  value['transactionId'],
                                              "url": value['url'],
                                              "gasFee": widget.data['gasFee'],
                                              "gasLimit":
                                                  widget.data['gasLimit'],
                                              "userGasPrice":
                                                  widget.data['userGasPrice'],
                                              "status": value['status'],
                                            };

                                            // coin, transaction details, transaction time
                                            SqlDb().insert('send',
                                                data.cast<String, dynamic>());

                                            showDialog(
                                                context: Get.context!,
                                                builder: (_) => ReceiptDialog(
                                                      h: 500,
                                                      w: Get.width,
                                                      data: successData,
                                                    ));
                                            // _searchController.clear();
                                            // routeCTX.pushNamed(RouteName.sendCoin, extra: value);
                                          }
                                        });
                                      },
                                style: buttonStyle(bgColor: Colors.green),
                                label: provider.loadingInitTrans ==
                                        ButtonLoadingState.loading
                                    ? loaderWidget(radius: 8)
                                    : const SizedBox.shrink(),
                                icon: bodyLargeText('Confirm', context,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  right: 10,
                  top: 10,
                  child: ToggleBrightnessButton(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  buildBody(WalletProvider provider, Map<String, dynamic> data) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: paddingDefault),
      // controller: scrollController,
      children: [
        titleLargeText('Your wallet address', context,
            fontWeight: FontWeight.bold, color: Colors.grey),
        height5(),
        bodyLargeText(
            (data['address']).split('').sublist(0, 5).join('') +
                ('......') +
                (data['address'].split('').sublist(
                        data['address'].length - 5, data['address'].length))
                    .join(''),
            context,
            textAlign: TextAlign.end,
            fontWeight: FontWeight.bold),
        height10(),
        titleLargeText('Parent-Wallet', context,
            fontWeight: FontWeight.bold, color: Colors.grey),
        height5(),
        bodyLargeText((data['parentWallet']), context,
            textAlign: TextAlign.end, fontWeight: FontWeight.bold),
        height10(),
        titleLargeText('To Address', context,
            fontWeight: FontWeight.bold, color: Colors.grey),
        height5(),
        bodyLargeText(
            (data['toAddress']).split('').sublist(0, 5).join('') +
                ('......') +
                (data['toAddress'].split('').sublist(
                        data['toAddress'].length - 5, data['toAddress'].length))
                    .join(''),
            context,
            textAlign: TextAlign.end,
            fontWeight: FontWeight.bold),
        height10(),
        titleLargeText('Gas-Fee', context,
            fontWeight: FontWeight.bold, color: Colors.grey),
        height5(),
        bodyLargeText((data['userGasPrice']).toString(), context,
            textAlign: TextAlign.end, fontWeight: FontWeight.bold),
        height10(),
        titleLargeText('Gas-Limit', context,
            fontWeight: FontWeight.bold, color: Colors.grey),
        height5(),
        bodyLargeText((data['gasLimit']).toString(), context,
            textAlign: TextAlign.end, fontWeight: FontWeight.bold),
        height10(),
        height50(),
      ],
    );
  }
}

class ReceiptDialog extends StatelessWidget {
  const ReceiptDialog({
    super.key,
    required this.h,
    required this.w,
    required this.data,
  });
  final double h;
  final double w;
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: LayoutBuilder(builder: (context, bound) {
        double headerH = w * 0.3;
        Color cardColor = getTheme.colorScheme.background;
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          insetPadding: EdgeInsets.symmetric(horizontal: spaceDefault * 2),
          child: SizedBox(
            height: h,
            width: w,
            child: Stack(
              children: [
                SizedBox(height: h, width: w),
                Positioned(
                  top: headerH / 2,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipPath(
                    clipper: TriangleClipper(count: 15, sideGap: 20),
                    child: Container(
                      height: h * 0.5,
                      padding: EdgeInsets.all(paddingDefault),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: cardColor),
                      child: Column(
                        children: [
                          height10((headerH / 2)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              width10(),
                              CircleAvatar(
                                  radius: 15,
                                  backgroundColor: getTheme.colorScheme.primary
                                      .withOpacity(0.05),
                                  child: buildCachedNetworkImage(
                                      data['coin']['imageUrl'] ?? '')),
                              width5(),
                              bodyMedText(data['coin']['symbol'], context,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 20),
                            ],
                          ),
                          // bodyLargeText('Transaction Successful', context,
                          //     fontWeight: FontWeight.bold, color: Colors.green),
                          const Spacer(),
                          const MySeparator(width: 5),
                          height20(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              bodyMedText('Date', context,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              bodyLargeText(
                                  MyDateUtils.formatDate(
                                      DateTime.now(), 'dd MMM yyyy'),
                                  context,
                                  fontWeight: FontWeight.bold),
                            ],
                          ),

                          // height20(),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     bodyLargeText('Status', context,
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.grey),
                          //     bodyLargeText('Pending', context,
                          //         fontWeight: FontWeight.bold),
                          //   ],
                          // ),
                          height10(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              bodyMedText('Recipient Address', context,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              bodyLargeText(
                                  '${data['toAddress'].toString().substring(0, 5)}....${data['toAddress'].toString().substring(data['toAddress'].toString().length - 5)}',
                                  context,
                                  fontWeight: FontWeight.bold),
                            ],
                          ),
                          height10(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              bodyMedText('Transaction Id', context,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              Row(
                                children: [
                                  bodyLargeText(
                                      '${data['transactionId'].toString().substring(0, 5)}....${data['transactionId'].toString().substring(data['transactionId'].toString().length - 5)}',
                                      context,
                                      fontWeight: FontWeight.bold),
                                  width5(),
                                  GestureDetector(
                                      onTap: () {
                                        copyToClipboard(data['transactionId'],
                                            'Transaction id copied');
                                      },
                                      child: Icon(
                                        Icons.copy,
                                        color: getTheme.brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : const Color(0xC01B279F),
                                        size: 15,
                                      )),
                                ],
                              ),
                            ],
                          ),
                          height20(),
                          const MySeparator(width: 5),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // launch url
                                    launchUrl(Uri.parse(data['url']));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      bodyMedText('View on Blockchain', context,
                                          decoration: TextDecoration.underline),
                                      width5(),
                                      const Icon(Icons.launch,
                                          color: linkColor, size: 15),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          height10(),
                          TextButton(
                            onPressed: () {
                              sl.get<AuthProvider>().refreshMyWallets(wallets: [
                                sl.get<AuthProvider>().user.wallet!.firstWhere(
                                    (element) =>
                                        element.walletAddress ==
                                        data['address'])
                              ]);
                              context.goNamed(RouteName.home);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(headerH),
                        child: Container(
                          height: headerH,
                          width: headerH,
                          decoration: BoxDecoration(
                              color: cardColor, shape: BoxShape.circle),
                          child: assetLottie(LottieAssets.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [ToggleBrightnessButton()],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width, 0, size.width, size.height / 2);
    path.cubicTo(size.width, size.height / 2, size.width - size.height / 4,
        size.height, size.width - size.height / 2, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class TriangleClipper extends CustomClipper<Path> {
  TriangleClipper({this.count = 20, this.gap = 20, this.sideGap = 20});
  final int count;
  final double gap;
  final double sideGap;
  @override
  Path getClip(Size size) {
    double h = size.height;
    double w = size.width;
    final path = Path();
    path.lineTo(0, h);
    // path.quadraticBezierTo(w / 2, h, w, h);
    path.lineTo(20, h);
    //design here

    double wd = ((w - 2 * sideGap) / (count));
    double up = 15;
    double _x1 = sideGap + wd / 2;
    // infoLog(wd.toString());
    for (int i = 0; i < count; i++) {
      //first curve
      if (_x1 <= w - sideGap) {
        double x1 = _x1;
        double y1 = (h - up);
        double x2 = (x1 + wd / 2);
        double y2 = h;
        // infoLog('x1: $x1  y1: $y1  x2: $x2 y2: $y2');
        path.quadraticBezierTo(x1, y1, x2, y2);
        path.lineTo(x2 + wd / 2, h);
        _x1 = x2 + wd;
        // infoLog((_x1).toString());
      }
      // _x1 = x2 + wd / 2;
      // x1 = _x1 + wd / 2;
      // y1 = (h - up);
      // x2 = (x1 + wd / 2);
      // y2 = h;
      // path.quadraticBezierTo(x1, y1, x2, y2);
      // path.lineTo(x2 + wd / 2, h);
      // infoLog((x2 + wd).toString());
    }

    path.lineTo(w - 20, h);
    path.lineTo(w, h);
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
