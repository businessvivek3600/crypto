import 'package:flutter/material.dart';

import '../../utils/picture_utils.dart';
import '../../utils/sized_utils.dart';
import '../../utils/text.dart';

class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({
    super.key,
    this.height = 300,
    required this.text,
    this.asset = 'empty_box.json',
  });
  final String text;
  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: Column(
          children: [
            height5(),
            Expanded(child: assetLottie(asset)),
            titleLargeText(
              text,
              context,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
            height50(),
          ],
        ));
  }
}
