import 'package:flutter/material.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
      fontSize: 16,
      height: 1.5, // ~ lineHeight 24 / 16
      letterSpacing: 0.5,
    ),

    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),

    labelSmall: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 11,
      letterSpacing: 0.5,
    ),
  );
}