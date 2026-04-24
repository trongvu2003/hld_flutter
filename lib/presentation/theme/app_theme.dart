import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    primaryColor: AppColors.helloDocYellow,
    scaffoldBackgroundColor: Colors.white,

    colorScheme: ColorScheme.light(
      primary: AppColors.helloDocYellow,
      onPrimary: Colors.black,
      background: Colors.white,
      onBackground: Colors.black,
      secondary: Color(0xFF37474F),
      surface: Colors.white,
      error: Color(0xFFB00020),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.helloDocYellow,
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.helloDocYellow,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  /// DARK THEME
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    primaryColor: AppColors.darkHelloDocYellow,
    scaffoldBackgroundColor: Color(0xFF121212),

    colorScheme: ColorScheme.dark(
      primary: AppColors.darkHelloDocYellow,
      onPrimary: Colors.black,
      background: Color(0xFF121212),
      onBackground: Colors.white,
      secondary: AppColors.helloDocYellow.withOpacity(0.7),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkHelloDocYellow,
        foregroundColor: Colors.black,
      ),
    ),
  );
}