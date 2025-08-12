// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:financy_ui/core/constants/icons.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';

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



  /// Generic method to group items by icon category
  static Map<String, List<T>> _groupByIconCategory<T>(
    List<T> items,
    String Function(T) getIconName,
  ) {
    final Map<String, List<T>> grouped = {
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

    for (var item in items) {
      String iconName = getIconName(item);
      
      switch (iconName) {
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
          grouped['Home & Utilities']!.add(item);
          break;

        // Food & Drink
        case 'fastfood':
        case 'local_cafe':
        case 'restaurant':
        case 'wine_bar':
        case 'local_bar':
        case 'cake':
          grouped['Food & Drink']!.add(item);
          break;

        // Shopping
        case 'shopping_cart':
        case 'card_giftcard':
        case 'redeem':
          grouped['Shopping']!.add(item);
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
          grouped['Entertainment & Travel']!.add(item);
          break;

        // Education
        case 'school':
        case 'book':
        case 'school_income':
          grouped['Education']!.add(item);
          break;

        // Health & Fitness
        case 'fitness_center':
        case 'healing':
        case 'favorite':
          grouped['Health & Fitness']!.add(item);
          break;

        // Transport
        case 'directions_car':
          grouped['Transport']!.add(item);
          break;

        // Art & Nature
        case 'brush':
        case 'nature':
        case 'local_florist':
        case 'lightbulb':
        case 'wb_sunny':
        case 'nightlight_round':
          grouped['Art & Nature']!.add(item);
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
          grouped['Finance & Business']!.add(item);
          break;

        // Other
        default:
          grouped['Other']!.add(item);
          break;
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);
    
    return grouped;
  }

  /// Group icons by category (original method, now uses generic method)
  static Map<String, List<IconData>> groupIconsByCategory() {
    final groupedEntries = _groupByIconCategory<MapEntry<String, IconData>>(
      iconMap.entries.toList(),
      (entry) => entry.key,
    );
    
    // Convert MapEntry to IconData
    return groupedEntries.map((key, value) => MapEntry(
      key,
      value.map((entry) => entry.value).toList(),
    ));
  }

  /// Group categories by their type and icon category
  static Map<String, List<Category>> groupCategoriesByType(List<Category> categories) {
    return _groupByIconCategory<Category>(
      categories,
      (category) => category.icon,
    );
  }
}
