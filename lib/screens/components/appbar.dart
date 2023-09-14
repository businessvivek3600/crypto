import 'package:flutter/material.dart';

import '../../utils/color.dart';
import '../../utils/sized_utils.dart';

buildCustomAppBar({
  double? height,
  double elevation = 0,
  List<Color>? colors,
  Color? backgroundColor,
  List<Widget>? actions,
  Widget? title,
  Widget? leading,
  PreferredSizeWidget? bottom,
  bool centerTitle = true,
  bool? automaticallyImplyLeading,
  bool isSliver = false,
  double? leadingWidth,
  bool useGradient = true,
  RoundedRectangleBorder? shape,
  double? expandedHeight,
  bool? pinned,
}) {
  automaticallyImplyLeading = automaticallyImplyLeading;

  var sliverAppBar = SliverAppBar(
    pinned: pinned ?? false,
    elevation: elevation,
    expandedHeight: height ?? kToolbarHeight,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: buildAppbarGradient(colors: colors),
      ),
    ),
    title: title,
    actions: actions,
    bottom: bottom,
    centerTitle: centerTitle,
    automaticallyImplyLeading: automaticallyImplyLeading ?? true,
    leadingWidth: leadingWidth,
  );

  return isSliver
      ? sliverAppBar
      : PreferredSize(
          preferredSize: Size.fromHeight(height ?? kToolbarHeight),
          child: Builder(builder: (context) {
            return Container(
              decoration: BoxDecoration(
                gradient:
                    useGradient ? buildAppbarGradient(colors: colors) : null,
                color: useGradient ? null : getTheme.colorScheme.primary,
                borderRadius: shape?.borderRadius,
              ),
              child: AppBar(
                shape: shape,
                elevation: elevation,
                backgroundColor: backgroundColor ?? Colors.transparent,
                title: title,
                actions: actions,
                leading: leading,
                bottom: bottom,
                centerTitle: centerTitle,
                automaticallyImplyLeading: automaticallyImplyLeading ?? true,
                leadingWidth: leadingWidth,
              ),
            );
          }),
        );
}
