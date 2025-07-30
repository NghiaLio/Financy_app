import 'package:flutter/material.dart';

class ThemeUtils {
  static ThemeMode? staticThemeDataFromString(String? mode) {
    if (mode == null) {
      return null;
    }
    switch (mode) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
      return 'System';
    }
  }
}
