import 'package:flutter/material.dart';
import '/screens/chat/AppTheme.dart';

AppTheme getAppTheme(ColorScheme cs) {
  Color p = cs.primary;
  Color p2 = cs.primary.withOpacity(0.2);
  Color p4 = cs.primary.withOpacity(0.4);
  Color p5 = cs.primary.withOpacity(0.5);
  Color p7 = cs.primary.withOpacity(0.7);

  Color b = cs.background;
  Color b2 = cs.background.withOpacity(0.2);
  Color b4 = cs.background.withOpacity(0.4);
  Color b5 = cs.background.withOpacity(0.5);
  Color b7 = cs.background.withOpacity(0.7);

  Color t = cs.brightness == Brightness.dark ? Colors.white : Colors.black;
  Color s = cs.onBackground.withOpacity(0.1);

  return AppTheme(
    flashingCircleDarkColor: Colors.grey,
    flashingCircleBrightColor: t,
    incomingChatLinkTitleStyle: TextStyle(color: b),
    outgoingChatLinkTitleStyle: TextStyle(color: t),
    outgoingChatLinkBodyStyle: TextStyle(color: t),
    incomingChatLinkBodyStyle: TextStyle(color: t),
    elevation: 0,
    repliedTitleTextColor: t,
    swipeToReplyIconColor: t,
    textFieldTextColor: t,
    appBarColor: p,
    backArrowColor: t,
    backgroundColor: b,
    replyDialogColor: p4,
    linkPreviewOutgoingChatColor: p4,
    linkPreviewIncomingChatColor: p,
    linkPreviewIncomingTitleStyle: const TextStyle(),
    linkPreviewOutgoingTitleStyle: const TextStyle(),
    replyTitleColor: t,
    textFieldBackgroundColor: b,
    outgoingChatBubbleColor: p,
    inComingChatBubbleColor: p2,
    reactionPopupColor: Colors.white,
    replyPopupColor: b,
    replyPopupButtonColor: t,
    replyPopupTopBorderColor: Colors.black54,
    reactionPopupTitleColor: t,
    inComingChatBubbleTextColor: t,
    repliedMessageColor: p,
    closeIconColor: t,
    shareIconBackgroundColor: p2,
    sendButtonColor: p,
    cameraIconColor: const Color(0xff757575),
    galleryIconColor: const Color(0xff757575),
    recordIconColor: const Color(0xff757575),
    stopIconColor: const Color(0xff757575),
    replyMessageColor: Colors.grey,
    appBarTitleTextStyle: t,
    messageReactionBackGroundColor: p2,
    messageReactionBorderColor: p4,
    verticalBarColor: p2,
    chatHeaderColor: t,
    themeIconColor: t,
    shareIconColor: t,
    messageTimeIconColor: t,
    messageTimeTextColor: t,
    waveformBackgroundColor: p2,
    waveColor: t,
    replyMicIconColor: t,
  );
}
