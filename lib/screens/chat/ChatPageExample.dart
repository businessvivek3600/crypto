// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:go_router/go_router.dart';
import '/models/coin_model.dart';
import '../components/select_coin.dart';
import '/constants/asset_constants.dart';
import '/utils/default_logger.dart';
import '../../functions/functions.dart';
import '../../get_app_theme.dart';
import '../../models/recent_users.dart';
import '../../models/wallet_model.dart';
import '../../route_management/route_name.dart';
import '../../utils/picture_utils.dart';
import '../../utils/sized_utils.dart';
import '../../utils/text.dart';
import '../../widgets/buttonStyle.dart';
import '../../widgets/custom_bottom_sheet_dialog.dart';
import './data.dart';
import 'package:flutter/material.dart';

import 'AppTheme.dart';

class CoinChatScreen extends StatefulWidget {
  const CoinChatScreen({Key? key}) : super(key: key);

  @override
  State<CoinChatScreen> createState() => _CoinChatScreenState();
}

class _CoinChatScreenState extends State<CoinChatScreen> {
  late AppTheme theme;

  bool isDarkTheme = false;
  final currentUser = ChatUser(
    id: '1',
    name: 'Chandan Kumar Singh',
    profilePhoto: Data.profileImage,
  );
  final _chatController = ChatController(
    initialMessageList: Data.messageList as List<Message>,
    scrollController: ScrollController(),
    chatUsers: [
      ChatUser(
        id: '2',
        name: 'Simform',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '3',
        name: 'Jhon',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '4',
        name: 'Mike',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '5',
        name: 'Rich',
        profilePhoto: Data.profileImage,
      ),
    ],
  );

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  @override
  void initState() {
    theme = getAppTheme(getTheme.colorScheme);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        body: ChatView(
          currentUser: currentUser,
          chatController: _chatController,
          onSendTap: _onSendTap,
          featureActiveConfig: const FeatureActiveConfig(
            lastSeenAgoBuilderVisibility: true,
            receiptsBuilderVisibility: true,
            enableSwipeToReply: false,
            enableReactionPopup: true,
            enableTextField: true,
            enableSwipeToSeeTime: true,
            enableCurrentUserProfileAvatar: false,
            enableOtherUserProfileAvatar: true,
            enableReplySnackBar: true,
            enablePagination: true,
            enableChatSeparator: true,
            enableDoubleTapToLike: false,
          ),
          chatViewState: ChatViewState.hasMessages,
          chatViewStateConfig: ChatViewStateConfiguration(
            loadingWidgetConfig: ChatViewStateWidgetConfiguration(
              loadingIndicatorColor: theme.outgoingChatBubbleColor,
            ),
            onReloadButtonTap: () {},
          ),
          typeIndicatorConfig: TypeIndicatorConfiguration(
            flashingCircleBrightColor: theme.flashingCircleBrightColor,
            flashingCircleDarkColor: theme.flashingCircleDarkColor,
          ),
          appBar: ChatViewAppBar(
            elevation: theme.elevation,
            backGroundColor: theme.appBarColor,
            profilePicture: Data.profileImage,
            backArrowColor: theme.backArrowColor,
            chatTitle: currentUser.name,
            chatTitleTextStyle: TextStyle(
              color: theme.appBarTitleTextStyle,
              fontWeight: FontWeight.bold,
              // fontSize: 18,
              // letterSpacing: 0.25,
              overflow: TextOverflow.ellipsis,
            ),
            userStatus: "online",
            userStatusTextStyle:
                TextStyle(color: theme.appBarTitleTextStyle?.withOpacity(0.6)),
            actions: [
              // ToggleBrightnessButton(
              //     onChange: _onThemeIconTap, color: Colors.red),
              ///
              // IconButton(
              //   // onPressed: _onThemeIconTap,
              //   icon: Icon(
              //     isDarkTheme
              //         ? Icons.brightness_4_outlined
              //         : Icons.dark_mode_outlined,
              //     color: theme.themeIconColor,
              //   ),
              // ),
              ///
              // IconButton(
              //   tooltip: 'Toggle TypingIndicator',
              //   onPressed: _showHideTypingIndicator,
              //   icon: const Icon(Icons.keyboard, color: Colors.white),
              // ),
              IconButton(
                tooltip: 'Make Transaction',
                onPressed: () => _makeTransaction(context),
                icon: const Icon(Icons.currency_bitcoin_rounded,
                    color: Colors.white),
              ),
            ],
          ),
          chatBackgroundConfig: ChatBackgroundConfiguration(
            messageTimeIconColor: theme.messageTimeIconColor,
            messageTimeTextStyle: TextStyle(
                color: theme.messageTimeTextColor, fontWeight: FontWeight.bold),
            defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
              textStyle: TextStyle(
                color: theme.chatHeaderColor,
                fontSize: 17,
              ),
            ),
            backgroundColor: theme.backgroundColor,
          ),
          sendMessageConfig: SendMessageConfiguration(
            imagePickerIconsConfig: ImagePickerIconsConfiguration(
              cameraIconColor: theme.cameraIconColor,
              galleryIconColor: theme.galleryIconColor,
            ),
            replyMessageColor: theme.replyMessageColor,
            defaultSendButtonColor: theme.sendButtonColor,
            replyDialogColor: theme.replyDialogColor,
            replyTitleColor: theme.replyTitleColor,
            textFieldBackgroundColor: theme.textFieldBackgroundColor,
            closeIconColor: theme.closeIconColor,
            textFieldConfig: TextFieldConfiguration(
              onMessageTyping: (status) {
                /// Do with status
                debugPrint(status.toString());
              },
              compositionThresholdTime: const Duration(seconds: 1),
              textStyle: TextStyle(color: theme.textFieldTextColor),
            ),
            micIconColor: theme.replyMicIconColor,
            voiceRecordingConfiguration: VoiceRecordingConfiguration(
              backgroundColor: theme.waveformBackgroundColor,
              recorderIconColor: theme.recordIconColor,
              waveStyle: WaveStyle(
                showMiddleLine: false,
                waveColor: theme.waveColor ?? Colors.white,
                extendWaveform: true,
              ),
            ),
          ),
          chatBubbleConfig: ChatBubbleConfiguration(
            outgoingChatBubbleConfig: ChatBubble(
              linkPreviewConfig: LinkPreviewConfiguration(
                backgroundColor: theme.linkPreviewOutgoingChatColor,
                bodyStyle: theme.outgoingChatLinkBodyStyle,
                titleStyle: theme.outgoingChatLinkTitleStyle,
              ),
              receiptsWidgetConfig: const ReceiptsWidgetConfig(
                  showReceiptsIn: ShowReceiptsIn.all),
              color: theme.outgoingChatBubbleColor,
            ),
            inComingChatBubbleConfig: ChatBubble(
              linkPreviewConfig: LinkPreviewConfiguration(
                linkStyle: TextStyle(
                  color: theme.inComingChatBubbleTextColor,
                  decoration: TextDecoration.underline,
                ),
                backgroundColor: theme.linkPreviewIncomingChatColor,
                bodyStyle: theme.incomingChatLinkBodyStyle,
                titleStyle: theme.incomingChatLinkTitleStyle,
              ),
              textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
              onMessageRead: (message) {
                /// send your message reciepts to the other client
                debugPrint('Message Read');
              },
              senderNameTextStyle:
                  TextStyle(color: theme.inComingChatBubbleTextColor),
              color: theme.inComingChatBubbleColor,
            ),
          ),
          replyPopupConfig: ReplyPopupConfiguration(
            backgroundColor: theme.replyPopupColor,
            buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
            topBorderColor: theme.replyPopupTopBorderColor,
          ),
          reactionPopupConfig: ReactionPopupConfiguration(
            shadow: BoxShadow(
              color: isDarkTheme ? Colors.black12 : Colors.grey.shade400,
              blurRadius: 20,
            ),
            backgroundColor: theme.reactionPopupColor,
          ),
          messageConfig: MessageConfiguration(
              messageReactionConfig: MessageReactionConfiguration(
                backgroundColor: theme.messageReactionBackGroundColor,
                borderColor: theme.messageReactionBackGroundColor,
                reactedUserCountTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionCountTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                  backgroundColor: theme.backgroundColor,
                  reactedUserTextStyle: TextStyle(
                    color: theme.inComingChatBubbleTextColor,
                  ),
                  reactionWidgetDecoration: BoxDecoration(
                    color: theme.inComingChatBubbleColor,
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                        offset: const Offset(0, 20),
                        blurRadius: 40,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              imageMessageConfig: ImageMessageConfiguration(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                shareIconConfig: ShareIconConfiguration(
                  defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                  defaultIconColor: theme.shareIconColor,
                ),
              ),
              customMessageBuilder: (msg) {
                Map<String, dynamic> data = jsonDecode(msg.message);
                infoLog(data.toString());
                int action = data['action'];
                int status = data['status'];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.all(paddingDefault),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                        color: theme.appBarColor?.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10)),
                    // height: 30,
                    child: Container(
                      padding: EdgeInsets.all(paddingDefault),
                      decoration: BoxDecoration(
                          color: theme.backgroundColor?.withOpacity(1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleLargeText(
                              action == 0
                                  ? 'Transaction Made'
                                  : 'Transaction Request ',
                              context),
                          height10(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bodyLargeText('\$', context),
                              Expanded(
                                  child: displayLarge(
                                      data['balance'].toStringAsFixed(3),
                                      context)),
                            ],
                          ),
                          height20(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.transparent,
                                child: buildCachedImageWithLoading(
                                    data['coin']['imageUrl'],
                                    loadingMode: ImageLoadingMode.shimmer),
                              ),
                              width10(),
                              titleLargeText(data['coin']['symbol'], context),
                            ],
                          ),
                          height20(),
                          Row(
                            children: [
                              Builder(builder: (context) {
                                // infoLog(msg.toJson().toString());

                                if (msg.sendBy == '1') {
                                  bool send = action == 0;
                                  bool requested = action == 1;
                                  bool canRepay = status == 0;
                                  bool completed = status == 1;
                                  bool failed = status == 2;

                                  return Expanded(
                                    child: FilledButton.icon(
                                      style: buttonStyle(
                                          bgColor: canRepay
                                              ? Colors.amber
                                              : completed
                                                  ? Colors.grey
                                                  : Colors.red),
                                      onPressed: failed ? null : () {},
                                      icon: Icon(
                                          canRepay
                                              ? Icons.replay
                                              : completed
                                                  ? Icons.launch_rounded
                                                  : Icons.error,
                                          color: Colors.white),
                                      label: bodyMedText(
                                          canRepay
                                              ? "Request again"
                                              : completed
                                                  ? "View on Blockchain"
                                                  : 'Failed',
                                          context,
                                          color: Colors.white),
                                    ),
                                  );
                                }
                                bool send = action == 0;
                                bool requested = action == 1;

                                bool pending = status == 0;
                                bool completed = status == 1;
                                bool failed = status == 2;
                                return Expanded(
                                  child: FilledButton.icon(
                                    style: buttonStyle(
                                        bgColor: pending
                                            ? Colors.amber
                                            : completed
                                                ? Colors.grey
                                                : Colors.red),
                                    onPressed: failed ? null : () {},
                                    icon: Icon(
                                        pending
                                            ? Icons.timelapse_rounded
                                            : completed
                                                ? Icons.launch_rounded
                                                : Icons.error,
                                        color: Colors.white),
                                    label: bodyMedText(
                                        pending
                                            ? "Pending"
                                            : completed
                                                ? "View on Blockchain"
                                                : 'Failed',
                                        context,
                                        color: Colors.white),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          profileCircleConfig: const ProfileCircleConfiguration(
            profileImageUrl: Data.profileImage,
          ),
          repliedMessageConfig: RepliedMessageConfiguration(
            backgroundColor: theme.repliedMessageColor,
            verticalBarColor: theme.verticalBarColor,
            repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
              enableHighlightRepliedMsg: true,
              highlightColor: Colors.pinkAccent.shade100,
              highlightScale: 1.1,
            ),
            textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.25),
            replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
            repliedMessageWidgetBuilder: (msg) {
              if (msg == null) {
                return const SizedBox.shrink();
              } else {
                bool custom = msg.messageType == MessageType.custom;
                warningLog(msg.toJson().toString() ?? '');
                Message message = Message(
                    message: msg.message,
                    createdAt: DateTime.now(),
                    sendBy: msg.replyTo,
                    id: '21');
                return custom
                    ? const SizedBox.shrink()
                    // ? ReplyMessageWidget(message: message)
                    : const SizedBox.shrink();
              }
            },
          ),
          swipeToReplyConfig: SwipeToReplyConfiguration(
            replyIconColor: theme.swipeToReplyIconColor,
          ),
        ),
      ),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    final id = int.parse(Data.messageList.last.id) + 1;
    infoLog(replyMessage.toJson().toString());
    _chatController.addMessage(
      Message(
        id: id.toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }

  void onTransactionDone(String message) {
    final id = int.parse(Data.messageList.last.id) + 1;
    _chatController.addMessage(Message(
      id: id.toString(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: currentUser.id,
      replyMessage: const ReplyMessage(),
      messageType: MessageType.custom,
    ));
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }

  void _onThemeIconTap(ThemeMode themeMode) {
    setState(() {
      theme = getAppTheme(Theme.of(context).colorScheme);
      if (themeMode == ThemeMode.light) {
        isDarkTheme = false;
      } else {
        isDarkTheme = true;
      }
    });
  }

  void _makeTransaction(BuildContext routeCTX) async {
    primaryFocus?.unfocus();
    int? transactionType = await CustomBottomSheet.show<int?>(
      context: context,
      // backgroundColor: Colors.transparent,
      showCloseIcon: false,
      enableDrag: true,
      curve: Curves.bounceIn,
      builder: (context) => const _TransferOrRequestDialog(),
    );
    infoLog(
        'User chose to : ${transactionType == 1 ? 'Receive' : transactionType == 0 ? 'Send' : ''}');
    if (transactionType == null) {
      return;
    } else {
      WalletModel? wallet = await showModalBottomSheet<WalletModel>(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        isScrollControlled: true,
        builder: (context) {
          return SelectCoinWidget(
            onWalletSelect: (Coin walletModel, double balance) {
              successLog(walletModel.toJson().toString());
              context.pop(walletModel);
              // setState(() {
              // wallet = null;
              // wallet = walletModel;
              // });
            },
          );
        },
      );
      if (wallet == null) {
        return;
      } else {
        // sl.get<DashboardProvider>().initTransaction(context, {
        //   "parentWallet": wallet.parentWallet,
        //   "symbol": wallet.symbol
        // }).then((value) async {
        // successLog(value.toString());
        // successLog(users.toString());
        // if (value != null) {
        await future(1000);
        var data = {
          "senderId": 'stchokjhgf',
          "receiverId": 'ijhgvcx',
          "action": transactionType,
          "coin": wallet.toJson(),
          'wallet': {
            'walletAddress': 'qsdfghklwxcfgvhbjkwecvhbjnkm',
            "myAddress": 'qsdfgnwaesrdtfyguhjaesrdtfygh'
          },
          "balance": 2346.4567,
        };
        Map<String, dynamic>? res =
            await routeCTX.pushNamed(RouteName.sendCoin, extra: data);
        successLog('send coin result $res');

        // if (res != null) {
        onTransactionDone(
            jsonEncode(data..addAll({'status': Random().nextInt(3)})));
        // }
        // }
        // });
      }
    }
  }
}

class _TransferOrRequestDialog extends StatelessWidget {
  const _TransferOrRequestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        assetImages(PNGAssets.appLogo, width: getWidth * 0.2),
        height10(),
        titleLargeText('Transfer Or Request', context),
        height5(),
        bodyMedText('directly from your chat', context),
        assetLottie(LottieAssets.coinsCollection),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: buttonStyle(bgColor: Colors.green),
                onPressed: () => Navigator.pop(context, 0),
                icon: const Icon(Icons.call_made_rounded, color: Colors.white),
                label: bodyMedText('Send', context, color: Colors.white),
              ),
            ),
            width10(),
            Expanded(
              child: FilledButton.icon(
                style: buttonStyle(bgColor: Colors.blue),
                onPressed: () => Navigator.pop(context, 1),
                icon: const Icon(Icons.call_received_rounded,
                    color: Colors.white),
                label: bodyMedText('Receive', context, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
