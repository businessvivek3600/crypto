import 'package:cherry_toast/resources/colors.dart';
import 'package:flutter/material.dart';
import '/utils/color.dart';

import 'sized_utils.dart';

Card globalCard(
    {required Widget child,
    Color? color,
    double elevation = 1,
    Color? shadowColor,
    Color? surfaceColor,
    RoundedRectangleBorder? shape}) {
  return Card(
    shape: shape,
    elevation: elevation,
    shadowColor: defaultShadowColor,
    surfaceTintColor: surfaceColor,
    color: color ??
        (getTheme.brightness == Brightness.light ? Colors.white : darkBlueGrey),
    margin: EdgeInsets.zero,
    child: child,
  );
}
