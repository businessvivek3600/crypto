import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/constants/asset_constants.dart';
import '/utils/color.dart';

late ColorScheme colorScheme;
late ColorScheme darkColorScheme;
Future<ColorScheme> generateColorSchemeFromImage(Brightness brt) async =>
    await ColorScheme.fromImageProvider(
        provider: const AssetImage('assets/images/${PNGAssets.appLogo}'),
        brightness: brt);
final lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'ubantu',
  brightness: Brightness.light,
  colorScheme: AppColorSchemes.lightColorScheme,
  inputDecorationTheme: buildInputDecorationTheme(Brightness.light),
  textTheme: myTextTheme,

// Set the app bar background color
  appBarTheme: getAppBarTheme(Brightness.light),
  iconTheme: const IconThemeData(color: lightPrimary),

  // primaryColor: lightPrimary,
  // primarySwatch: generateMaterialColor(lightPrimary),
);
final darkTheme = ThemeData(
  appBarTheme: getAppBarTheme(Brightness.dark),
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'ubantu',
  inputDecorationTheme: buildInputDecorationTheme(Brightness.dark),
  textTheme: myTextTheme,
  colorScheme: AppColorSchemes.darkColorScheme,
  iconTheme: const IconThemeData(color: darkPrimary),
);
MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

MaterialColor generateMaterialColor2(Color color) =>
    MaterialColor(color.value, {
      50: color.withOpacity(0.05),
      100: color.withOpacity(0.1),
      200: color.withOpacity(0.2),
      300: color.withOpacity(0.3),
      400: color.withOpacity(0.4),
      500: color.withOpacity(0.5),
      600: color.withOpacity(0.6),
      700: color.withOpacity(0.7),
      800: color.withOpacity(0.8),
      900: color.withOpacity(0.9),
    });

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);

//input decoration
AppBarTheme getAppBarTheme(Brightness brightness) {
  Color bgColor = brightness == Brightness.light ? lightPrimary : darkPrimary;
  Color iconColor =
      brightness == Brightness.light ? Colors.white : Colors.white;
  TextStyle textStyle = const TextStyle(color: Colors.white);
  IconThemeData iconThemeData = IconThemeData(color: iconColor);
  return AppBarTheme(
      backgroundColor: bgColor,
      titleTextStyle: textStyle,
      iconTheme: iconThemeData);
}

InputDecorationTheme buildInputDecorationTheme(Brightness brightness) {
  Color labelColor =
      brightness == Brightness.dark ? Colors.white : Colors.black;
  Color hintColor =
      brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color focusedBorderColor =
      brightness == Brightness.dark ? Colors.white54 : Colors.black54;
  Color fillColor =
      brightness != Brightness.dark ? Colors.grey[100]! : Colors.white24;
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(10.0));
  InputBorder focus({Color? color}) => OutlineInputBorder(
      borderSide: BorderSide(color: color ?? focusedBorderColor),
      borderRadius: borderRadius);
  InputBorder enable({Color? color}) => OutlineInputBorder(
      borderSide: BorderSide(color: color ?? focusedBorderColor),
      borderRadius: borderRadius);
  InputBorder error({Color? color}) => OutlineInputBorder(
      borderSide: BorderSide(color: color ?? focusedBorderColor),
      borderRadius: borderRadius);
  InputBorder disable({Color? color}) => OutlineInputBorder(
      borderSide: BorderSide(color: color ?? focusedBorderColor),
      borderRadius: borderRadius);
  return InputDecorationTheme(
      contentPadding:
          const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
      filled: true,
      fillColor: fillColor,
      labelStyle: TextStyle(
          color: labelColor, fontWeight: FontWeight.normal, fontSize: 17),
      hintStyle: TextStyle(
          color: hintColor, fontWeight: FontWeight.normal, fontSize: 17),
      focusedBorder: focus(),
      enabledBorder: enable(),
      errorBorder: error(color: Colors.red),
      disabledBorder: disable(color: Colors.grey));
}

/// decoration
// switchTheme: SwitchThemeData(
//   thumbColor: MaterialStateProperty.resolveWith((states) {
//     if (states.contains(MaterialState.selected)) {
//       return appLogoColor;
//     } else if (states.contains(MaterialState.disabled)) {
//       return Colors.white10;
//     }
//     return null;
//   }),
//   trackColor: MaterialStateProperty.resolveWith((states) {
//     if (states.contains(MaterialState.selected)) {
//       return appLogoColor.withOpacity(0.5);
//     } else {
//       return Colors.white70;
//     }
//   }),
// ),

/// Define the default TextStyle
final TextStyle _defaultTextStyle = GoogleFonts.ubuntu();

// Create a new TextTheme by configuring the default TextStyle with the provided properties
TextTheme myTextTheme = TextTheme(
  displayLarge:
      _defaultTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
  displayMedium:
      _defaultTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
  displaySmall:
      _defaultTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
  headlineLarge:
      _defaultTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
  headlineMedium:
      _defaultTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
  headlineSmall:
      _defaultTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
  titleLarge:
      _defaultTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
  titleMedium:
      _defaultTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
  titleSmall:
      _defaultTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
  bodyLarge: _defaultTextStyle,
  bodyMedium: _defaultTextStyle,
  bodySmall: _defaultTextStyle,
  labelLarge: _defaultTextStyle.copyWith(
      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
  labelMedium: _defaultTextStyle.copyWith(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
  labelSmall: _defaultTextStyle.copyWith(
      fontWeight: FontWeight.bold, color: Colors.blue),
);

class AppColorSchemes {
  // Light Mode Color Scheme
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: lightPrimary,
    secondary: lightAccent,
    background: lightBackground,
    onBackground: lightText,
    surface: lightBackground,
    onSurface: lightText,
    error: errorRed,
  );

  // Dark Mode Color Scheme
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: darkPrimary,
    secondary: darkAccent,
    background: darkBackground,
    onBackground: darkText,
    surface: darkBackground,
    onSurface: darkText,
    error: errorRed,
  );

  // Additional Custom Colors
  static final Color mainColor = mainColor;
  static final Color appLogoColor = appLogoColor;
  static final Color appLogoColor2 = appLogoColor2;
  static final Color lightAppLogoColor = lightAppLogoColor;
  static final Color secondaryColorShaded = secondaryColorShaded;
  static final Color secondaryColor2 = secondaryColor2;
  static final Color colorGreen = colorGreen;
  static final Color colorYellow = colorYellow;
  static final Color colorBlue = colorBlue;
  static final Color yearlyPackColor = yearlyPackColor;
  static final Color monthlyPackColor = monthlyPackColor;

  // Text Colors
  static final Color titleTextColor = titleTextColor;
  static final Color mTitleTextColor = mTitleTextColor;
  static final Color capTextColor = capTextColor;

  // Tool Colors
  static final Color cursorColor = cursorColor;
  static final Color linkColor = linkColor;
  static final Color purpleLight = purpleLight;
  static final Color purpleDark = purpleDark;
  static final Color orangeLight = orangeLight;
  static final Color orangeDark = orangeDark;
  static final Color redLight = redLight;
  static final Color redDark = redDark;
  static final Color blueLight = blueLight;
  static final Color greenLight = greenLight;
  static final Color defaultBottomSheetColor = defaultBottomSheetColor;
}
