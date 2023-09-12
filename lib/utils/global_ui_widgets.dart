
import 'package:flutter/material.dart';

import 'sized_utils.dart';

Card globalCard({required Widget child, Color? color}) {
  return Card(
    color: color ?? getTheme.colorScheme.background,
    margin: EdgeInsets.zero,
    child: child,
  );
}