// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class ColorUtils {
  /// Parse a string like '0xFF2196F3' to a Color
  static Color? parseColor(String? colorString) {
    if (colorString == null) return null;

    if (colorString.startsWith('0x')) {
      return Color(int.parse(colorString));
    }
    // fallback: parse hex string like '#2196F3' or '2196F3'
    colorString = colorString.replaceAll('#', '');
    if (colorString.length == 6) colorString = 'FF$colorString';
    return Color(int.parse(colorString, radix: 16));
  }

  /// Convert a Color to a string like '0xFF2196F3'
  static String colorToHex(Color color) {
    return '0x${color.value.toRadixString(16).toUpperCase()}';
  }

  /// Choose a readable foreground color (typically white or black)
  /// that maximizes contrast against the given [background].
  /// Uses WCAG contrast ratio with black and white and returns the better one.
  static Color bestOnColor(Color background,
      {Color light = Colors.white, Color dark = Colors.black}) {
    final double bgLum = background.computeLuminance();
    final double contrastWhite = (1.05) / (bgLum + 0.05);
    final double contrastBlack = (bgLum + 0.05) / 0.05;
    return contrastWhite >= contrastBlack ? light : dark;
  }

  /// Convenience to get a foreground color with opacity for overlays/borders.
  static Color bestOnColorWithOpacity(Color background, double opacity,
      {Color light = Colors.white, Color dark = Colors.black}) {
    return bestOnColor(background, light: light, dark: dark)
        .withOpacity(opacity);
  }
}
