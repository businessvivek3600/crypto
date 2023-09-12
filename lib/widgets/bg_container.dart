import 'package:flutter/material.dart';
import '/constants/asset_constants.dart';
import '/utils/picture_utils.dart';

class BgContainer extends StatelessWidget {
  ///change showBg according to app requirement here
  const BgContainer(
      {super.key,
      required this.child,
      this.image,
      this.showBg = false,
      this.opacity = 1});
  final Widget child;
  final String? image;
  final bool showBg;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
        image: showBg
            ? DecorationImage(

                ///implement conditional [Image Provider] or default or null
                // image: userAppBgImageProvider(context),
                image: assetImageProvider(image ?? PNGAssets.appLogo),
                fit: BoxFit.cover,
                opacity: opacity)
            : null,
      ),
      child: child,
    );
  }
}
