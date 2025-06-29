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
    if (colorString.length == 6) colorString = 'FF' + colorString;
    return Color(int.parse(colorString, radix: 16));
  }

  /// Convert a Color to a string like '0xFF2196F3'
  static String colorToHex(Color color) {
    return '0x${color.value.toRadixString(16).toUpperCase()}';
  }
}
