import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/utils/default_logger.dart';
import '/functions/functions.dart';
import '/utils/sized_utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../utils/my_toasts.dart';

class SendViaScanQRViewWidget extends StatefulWidget {
  const SendViaScanQRViewWidget({Key? key, required this.onDataScanned})
      : super(key: key);

  final Function(Barcode? barcode) onDataScanned;
  @override
  State<StatefulWidget> createState() => _SendViaScanQRViewWidgetState();
}

class _SendViaScanQRViewWidgetState extends State<SendViaScanQRViewWidget> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildQrView(context),
          Positioned(
              bottom: spaceDefault,
              left: spaceDefault,
              right: spaceDefault,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        IconData iconData = Icons.flash_off_outlined;

                        if (snapshot.data == true) {
                          iconData = Icons.flash_on_outlined;
                        } else if (snapshot.data == false) {
                          iconData = Icons.flash_off_outlined;
                        } else {
                          iconData = Icons.flash_auto_outlined;
                        }

                        return IconButton.filledTonal(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            icon: Icon(iconData, color: Colors.white));
                      }),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 500 ||
            MediaQuery.of(context).size.height < 500)
        ? 250.0
        : 400.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: getTheme.colorScheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 7,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      infoLog(result?.code.toString() ?? "");
      setState(() {
        result = scanData;
      });
      bool? isAddress = validateWalletAddress(result?.code ?? "");
      if (isAddress != null && isAddress && (result?.code ?? "").isNotEmpty) {
        infoLog(result?.code.toString() ?? "", 'validatedWalletAddress');

        widget.onDataScanned(result);
        // if (result != null) {
        //   context.pop();
        controller.pauseCamera();
        // }
      } else if (isAddress != null && !isAddress) {
        Toasts.fToast('Invalid address');
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
