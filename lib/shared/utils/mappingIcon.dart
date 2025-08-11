// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:financy_ui/core/constants/icons.dart';

class IconMapping {
  /// Convert IconData → String
  static String mapIconToString(IconData icon) {
    return iconMap.entries
        .firstWhere(
          (e) => e.value == icon,
          orElse: () => const MapEntry('more_horiz', Icons.more_horiz),
        )
        .key;
  }

  /// Convert String → IconData
  static IconData stringToIcon(String key) {
    return iconMap[key] ?? Icons.more_horiz;
  }

  static Map<String, List<IconData>> groupIconsByCategory() {
    final Map<String, List<IconData>> grouped = {
      'Home & Utilities': [],
      'Food & Drink': [],
      'Shopping': [],
      'Entertainment & Travel': [],
      'Education': [],
      'Health & Fitness': [],
      'Transport': [],
      'Art & Nature': [],
      'Finance & Business': [],
      'Other': [],
    };

    iconMap.forEach((name, icon) {
      switch (name) {
        // Home & Utilities
        case 'home':
        case 'local_grocery_store':
        case 'payment':
        case 'credit_card':
        case 'people':
        case 'security':
        case 'public':
        case 'access_time':
        case 'baby_changing_station':
        case 'build':
          grouped['Home & Utilities']!.add(icon);
          break;

        // Food & Drink
        case 'fastfood':
        case 'local_cafe':
        case 'restaurant':
        case 'wine_bar':
        case 'local_bar':
        case 'cake':
          grouped['Food & Drink']!.add(icon);
          break;

        // Shopping
        case 'shopping_cart':
        case 'card_giftcard':
        case 'redeem':
          grouped['Shopping']!.add(icon);
          break;

        // Entertainment & Travel
        case 'pets':
        case 'music_note':
        case 'movie':
        case 'sports_soccer':
        case 'flight':
        case 'beach_access':
        case 'camera_alt':
        case 'event':
        case 'luggage':
          grouped['Entertainment & Travel']!.add(icon);
          break;

        // Education
        case 'school':
        case 'book':
        case 'school_income':
          grouped['Education']!.add(icon);
          break;

        // Health & Fitness
        case 'fitness_center':
        case 'healing':
        case 'favorite':
          grouped['Health & Fitness']!.add(icon);
          break;

        // Transport
        case 'directions_car':
          grouped['Transport']!.add(icon);
          break;

        // Art & Nature
        case 'brush':
        case 'nature':
        case 'local_florist':
        case 'lightbulb':
        case 'wb_sunny':
        case 'nightlight_round':
          grouped['Art & Nature']!.add(icon);
          break;

        // Finance & Business
        case 'attach_money':
        case 'trending_up':
        case 'monetization_on':
        case 'currency_bitcoin':
        case 'savings':
        case 'storefront':
        case 'house':
        case 'work':
        case 'work_outline':
        case 'refresh':
          grouped['Finance & Business']!.add(icon);
          break;

        // Other
        default:
          grouped['Other']!.add(icon);
          break;
      }
    });

    return grouped;
  }
}
