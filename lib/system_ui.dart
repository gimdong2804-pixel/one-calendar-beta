import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SystemUiOverlayStyle oneUiSystemOverlayStyle({
  required BuildContext context,
  required Color navigationBarColor,
  Color? statusBarColor,
  Brightness? statusBarIconBrightness,
  Brightness? statusBarBrightness,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    statusBarIconBrightness: statusBarIconBrightness,
    statusBarBrightness: statusBarBrightness,
    systemNavigationBarColor: navigationBarColor,
    systemNavigationBarDividerColor: navigationBarColor,
    systemNavigationBarIconBrightness: isDark
        ? Brightness.light
        : Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );
}
