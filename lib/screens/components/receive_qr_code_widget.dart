// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:my_global_tools/utils/picture_utils.dart';
import '/utils/default_logger.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '/functions/functions.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../constants/asset_constants.dart';
import '../../models/user/user_data_model.dart';
import '../../utils/sized_utils.dart';
import '../../utils/text.dart';

class ReceiveQrCodeWidget extends StatelessWidget {
  ReceiveQrCodeWidget({
    super.key,
    required this.walletModel,
  });
  final Wallet walletModel;
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsetsDirectional.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: getTheme.textTheme.displayLarge?.color),
                height: 5,
                width: 30,
              ),
            ],
          ),
          const Spacer(),
          RepaintBoundary(
            key: _qrKey,
            child: Container(
              padding: EdgeInsets.all(paddingDefault),
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (walletModel.imageUrl != null)
                        Row(
                          children: [
                            buildCachedImageWithLoading(walletModel.imageUrl!,
                                h: 25, w: 25),
                            width5()
                          ],
                        ),
                      displayMedium(walletModel.tokenName ?? '', context,
                          color: Colors.black),
                    ],
                  ),
                  height20(),
                  Center(
                    child: PrettyQr(
                      image: const AssetImage(
                          'assets/images/${PNGAssets.appLogo}'),
                      typeNumber: 3,
                      size: 200,
                      data: walletModel.walletAddress ?? '',
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                      elementColor: Colors.black,
                      roundEdges: true,
                    ),
                  ),
                  height20(),
                ],
              ),
            ),
          ),
          height20(),
          Row(
            children: [
              const Spacer(),
              IconButton.filledTonal(
                  onPressed: () {
                    shareQRImage(
                        _qrKey, walletModel, walletModel.walletAddress ?? '');
                  },
                  icon: const Icon(Icons.share, color: Colors.white)),
              width20(),
              IconButton.filledTonal(
                  onPressed: () {
                    copyToClipboard(walletModel.walletAddress ?? '',
                        'Wallet Address Copied');
                  },
                  icon: const Icon(Icons.copy, color: Colors.white)),
              const Spacer(),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

Future<Uint8List?> capturePng(RenderRepaintBoundary boundary) async {
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}

Future<void> shareQRImage(GlobalKey key, data, String additionalData) async {
  // Capture the QR code image as a Uint8List.
  RenderObject? boundary = key.currentContext?.findRenderObject();
  RenderRepaintBoundary? repaintBoundary = findRenderRepaintBoundary(boundary!);

  // Wait for the boundary to be painted.
  // context.pop();
  await Future.delayed(const Duration(milliseconds: 200));
  Uint8List? qrCodeImage = await capturePng(repaintBoundary!);
  infoLog(qrCodeImage.toString());

  final filePath = await writeImageFileToStorage('share.png', qrCodeImage!);

  const String appLink =
      'https://play.google.com/store/apps/details?id=com.mycarclub&hl=en&gl=US';
  const String message =
      'Check out our awesome app on the Google Play Store! Download it now: $appLink';

  const String shareMessage = r'''
🚀 Receive Crypto via QR Code 🚀

Hello!
 
I'm excited to share my cryptocurrency wallet address with you.

📲 How to Use This QR Code 📲

Open your cryptocurrency wallet app.
Find the "Send" or "Send Funds" option.
Choose to scan a QR code.
Point your camera at the QR code below.
🔒 Safety and Security 🔒

Happy crypto transactions! 🌟
¯
''';

  await Share.shareFiles([filePath],
      text:
          '$shareMessage\n You can use this address to send me cryptocurrency. * $additionalData *\n $message',
      subject: additionalData);
}

RenderRepaintBoundary? findRenderRepaintBoundary(RenderObject renderObject) {
  if (renderObject is RenderRepaintBoundary) {
    return renderObject;
  }
  AbstractNode? parent = renderObject.parent;
  while (parent != null) {
    if (parent is RenderRepaintBoundary) {
      return parent;
    }

    parent = parent.parent;
  }

  return null;
}

  // await Share.shareXFiles([
  //   XFile(
  //     child:Image.memory(qrCodeImage)
  //     'qr_code.png',
  //     qrCodeImage,
  //     mimeType: 'image/png',
  //   ),
  //   ShareFile(
  //   'qr_code_additional_data.txt',
  //   additionalData.codeUnits,
  //   mimeType: 'text/plain',
  //   // ),
  // ], text: additionalData);