import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color vkartPrimary = Color(0xFFFF6530);
const Color vkartPrimaryDark = Color(0xFFD9501A);
const Color vkartPrimaryLight = Color(0xFFFF8A5B);
const Color vkartAccent = Color(0xFF2E7D32);
const Color vkartSuccess = Color(0xFF43A047);
const Color vkartWarning = Color(0xFFFFA726);
const Color vkartError = Color(0xFFB71C1C);
const Color vkartInfo = Color(0xFF2979FF);

final ThemeData vkartTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: vkartPrimary,
    brightness: Brightness.light,
    primary: vkartPrimary,
    secondary: vkartAccent,
    error: vkartError,
  ),
  // Applying a Google Font globally can break the MaterialIcons font,
  // causing icons to render as □ placeholders. Keeping the default font
  // family (null) ensures Material icons render correctly.
  fontFamily: null,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    foregroundColor: Colors.black,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(elevation: 0),
  textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
);

// Typography Styles (Google Fonts for regular text only — not global family).
TextStyle vkartHeadingLarge = GoogleFonts.roboto(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: vkartPrimary,
);

// TextField Styles
InputDecoration vkartTextFieldStyle = const InputDecoration(
  hintStyle: TextStyle(color: Colors.grey),
  labelStyle: TextStyle(color: vkartPrimary),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  errorStyle: TextStyle(color: vkartError),
  prefixIconConstraints: BoxConstraints(maxWidth: 24),
);

