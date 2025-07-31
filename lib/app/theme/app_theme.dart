import 'package:flutter/material.dart';
import 'package:financy_ui/core/constants/colors.dart';

class AppTheme {
  // Factory method to generate ThemeData dynamically
  static ThemeData lightTheme({
    required Color primaryColor,
    required Color backgroundColor,
    required Color selectedItemColor,
    String fontFamily = 'Roboto',
    double fontSize = 16.0,
  }) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      highlightColor: Colors.black,
      cardColor: const Color(0xFFFDFDFE),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.textDark,
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize,
          color: AppColors.textLight,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize - 2,
          color: AppColors.textLight,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: fontSize - 4,
          color: AppColors.textLight,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: 12.0,
          color: const Color.fromARGB(255, 53, 52, 52),
          fontFamily: fontFamily,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: Colors.black54,
      ),
    );
  }

  static ThemeData darkTheme({
    required Color primaryColor,
    required Color backgroundColor,
    required Color selectedItemColor,
    String fontFamily = 'Roboto',
    double fontSize = 16.0,
  }) {
    return ThemeData(
      brightness: Brightness.dark,
      highlightColor: Colors.white,
      primaryColor: primaryColor,
      cardColor: const Color(0xFF2A2A3E),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: AppColors.textDark,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize,
          color: AppColors.textDark,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize - 2,
          color: AppColors.textDark,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: 14.0,
          color: AppColors.textGrey,
          fontFamily: fontFamily,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: AppColors.textGrey,
      ),
    );
  }
}
