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

  /// Get localized category name from icon name
  static String getLocalizedCategoryName(String iconName, dynamic l10n) {
    if (l10n == null) return iconName;

    // Map icon names to localized names using l10n keys
    final Map<String, String> localizedNames = <String, String>{};

    // Expense Icons
    localizedNames['home'] = l10n.iconHome ?? 'Home';
    localizedNames['shopping_cart'] = l10n.iconShoppingCart ?? 'Shopping';
    localizedNames['fastfood'] = l10n.iconFastfood ?? 'Food';
    localizedNames['pets'] = l10n.iconPets ?? 'Pets';
    localizedNames['work'] = l10n.iconWork ?? 'Work';
    localizedNames['music_note'] = l10n.iconMusicNote ?? 'Music';
    localizedNames['movie'] = l10n.iconMovie ?? 'Entertainment';
    localizedNames['sports_soccer'] = l10n.iconSportsSoccer ?? 'Sports';
    localizedNames['flight'] = l10n.iconFlight ?? 'Travel';
    localizedNames['school'] = l10n.iconSchool ?? 'Education';
    localizedNames['local_cafe'] = l10n.iconLocalCafe ?? 'Coffee';
    localizedNames['fitness_center'] = l10n.iconFitnessCenter ?? 'Fitness';
    localizedNames['directions_car'] = l10n.iconDirectionsCar ?? 'Transport';
    localizedNames['beach_access'] = l10n.iconBeachAccess ?? 'Leisure';
    localizedNames['camera_alt'] = l10n.iconCameraAlt ?? 'Photography';
    localizedNames['brush'] = l10n.iconBrush ?? 'Art';
    localizedNames['nature'] = l10n.iconNature ?? 'Nature';
    localizedNames['healing'] = l10n.iconHealing ?? 'Health';
    localizedNames['cake'] = l10n.iconCake ?? 'Celebration';
    localizedNames['favorite'] = l10n.iconFavorite ?? 'Favorites';
    localizedNames['wb_sunny'] = l10n.iconWbSunny ?? 'Weather';
    localizedNames['nightlight_round'] = l10n.iconNightlightRound ?? 'Night';
    localizedNames['local_florist'] = l10n.iconLocalFlorist ?? 'Flowers';
    localizedNames['lightbulb'] = l10n.iconLightbulb ?? 'Utilities';
    localizedNames['book'] = l10n.iconBook ?? 'Books';
    localizedNames['luggage'] = l10n.iconLuggage ?? 'Travel';
    localizedNames['event'] = l10n.iconEvent ?? 'Events';
    localizedNames['payment'] = l10n.iconPayment ?? 'Payment';
    localizedNames['credit_card'] = l10n.iconCreditCard ?? 'Credit Card';
    localizedNames['access_time'] = l10n.iconAccessTime ?? 'Time';
    localizedNames['people'] = l10n.iconPeople ?? 'Social';
    localizedNames['public'] = l10n.iconPublic ?? 'Public';
    localizedNames['security'] = l10n.iconSecurity ?? 'Security';
    localizedNames['wine_bar'] = l10n.iconWineBar ?? 'Drinks';
    localizedNames['local_bar'] = l10n.iconLocalBar ?? 'Bar';
    localizedNames['restaurant'] = l10n.iconRestaurant ?? 'Restaurant';
    localizedNames['local_grocery_store'] =
        l10n.iconLocalGroceryStore ?? 'Grocery';
    localizedNames['baby_changing_station'] =
        l10n.iconBabyChangingStation ?? 'Baby';
    localizedNames['bug_report'] = l10n.iconBugReport ?? 'Maintenance';
    localizedNames['build'] = l10n.iconBuild ?? 'Tools';

    // Income Icons
    localizedNames['attach_money'] = l10n.iconAttachMoney ?? 'Money';
    localizedNames['card_giftcard'] = l10n.iconCardGiftcard ?? 'Gift';
    localizedNames['trending_up'] = l10n.iconTrendingUp ?? 'Investment';
    localizedNames['storefront'] = l10n.iconStorefront ?? 'Business';
    localizedNames['house'] = l10n.iconHouse ?? 'Real Estate';
    localizedNames['savings'] = l10n.iconSavings ?? 'Savings';
    localizedNames['redeem'] = l10n.iconRedeem ?? 'Rewards';
    localizedNames['refresh'] = l10n.iconRefresh ?? 'Refresh';
    localizedNames['school_income'] =
        l10n.iconSchoolIncome ?? 'Education Income';
    localizedNames['monetization_on'] =
        l10n.iconMonetizationOn ?? 'Monetization';
    localizedNames['currency_bitcoin'] =
        l10n.iconCurrencyBitcoin ?? 'Cryptocurrency';
    localizedNames['work_outline'] = l10n.iconWorkOutline ?? 'Work Income';
    localizedNames['more_horiz'] = l10n.iconMoreHoriz ?? 'More';

    return localizedNames[iconName] ?? iconName;
  }

  /// Get localized category name from Category object
  static String getLocalizedCategoryNameFromCategory(
    Category category,
    dynamic l10n,
  ) {
    // Nếu là category do người dùng tạo (userId hoặc uid có giá trị), luôn trả về tên do người dùng đặt
    if (category.userId != null || category.uid != null) {
      return category.name;
    }
    // Nếu là category mặc định, trả về tên l10n theo icon
    return getLocalizedCategoryName(category.icon, l10n);
  }

  /// Get original category name from localized name
  static String getOriginalCategoryNameFromLocalized(
    String localizedName,
    List<Category> categories,
    dynamic l10n,
  ) {
    // First check if it's "All Categories"
    if (localizedName == (l10n?.allCategories ?? 'All Categories')) {
      return localizedName;
    }

    // Find the category that matches the localized name
    for (var category in categories) {
      if (getLocalizedCategoryNameFromCategory(category, l10n) ==
          localizedName) {
        return category.name;
      }
    }

    // If not found, return the localized name as fallback
    return localizedName;
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
    return groupedEntries.map(
      (key, value) => MapEntry(key, value.map((entry) => entry.value).toList()),
    );
  }

  /// Group categories by their type and icon category
  static Map<String, List<Category>> groupCategoriesByType(
    List<Category> categories,
  ) {
    return _groupByIconCategory<Category>(
      categories,
      (category) => category.icon,
    );
  }
}
