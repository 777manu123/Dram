import 'package:flutter/material.dart';

// Dreamy Dark Theme Colors
const Color kPrimaryColor = Color(0xFF100B20); // Deep Indigo
const Color kPurpleGradientStart = Color(0xFF8B5CF6); // Purple
const Color kPurpleGradientEnd = Color(0xFF6366F1); // Indigo
const Color kBackgroundColor = Color(0xFF181A20); // Modern Dark Gray
const Color kSurfaceColor = Color(0xFF23272F); // Deep Gray
const Color kTextColor = Color(0xFFD1D5DB); // Light Gray

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kBackgroundColor,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kPurpleGradientEnd,
    surface: kSurfaceColor,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: kTextColor),
    bodyMedium: TextStyle(color: kTextColor),
    bodySmall: TextStyle(color: kTextColor),
  ),
);
