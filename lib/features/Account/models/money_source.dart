import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/money_source_utils.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import 'package:hive/hive.dart';

part 'money_source.g.dart';

@HiveType(typeId: 4)
enum CurrencyType {
  @HiveField(0)
  vnd,
  @HiveField(1)
  usd,
}

@HiveType(typeId: 5)
enum TypeMoney {
  @HiveField(0)
  cash,
  @HiveField(1)
  eWallet,
  @HiveField(2)
  bank,
  @HiveField(3)
  other,
}

@HiveType(typeId: 3)
class MoneySource extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double balance;

  @HiveField(3)
  TypeMoney? type;

  @HiveField(4)
  CurrencyType? currency;

  @HiveField(5)
  String? iconCode; // Store icon as string code instead of IconData

  @HiveField(6)
  String? color;

  @HiveField(7)
  String? description;

  @HiveField(8)
  bool isActive;

  // Getter for IconData
  IconData? get icon {
    if (iconCode == null) return null;
    return _getIconFromCode(iconCode!);
  }

  // Setter for IconData
  set icon(IconData? iconData) {
    iconCode = iconData != null ? _getCodeFromIcon(iconData) : null;
  }

  MoneySource({
    this.id,
    required this.name,
    required this.balance,
    this.type,
    this.currency,
    this.iconCode,
    this.color,
    this.description,
    required this.isActive,
  });

  /// Factory constructor for backend data (no icon/color)
  factory MoneySource.fromJson(Map<String, dynamic> json) {
    final iconData = MoneySourceIconColorMapper.iconFor(json['accountType']);
    return MoneySource(
      id: json['_id'] as String,
      name: json['accountName'] as String,
      balance: (json['accountBalance'] as num).toDouble(),
      type: TypeMoney.values.firstWhere(
        (e) => e.toString() == 'TypeMoney.${json['accountType']}',
        orElse: () => TypeMoney.other,
      ),
      currency: CurrencyType.values.firstWhere(
        (e) => e.toString() == 'CurrencyType.${json['currency']}',
        orElse: () => CurrencyType.vnd,
      ),
      iconCode: _getCodeFromIcon(iconData),
      color: json['color'] as String? ?? ColorUtils.colorToHex(AppColors.blue),
      // Default color if not provided
      description: json['description'] as String? ?? '',
      isActive:
          json['active'] as bool? ?? true, // Default to true if not provided
    );
  }

  Map<String, dynamic> toJson() => {
    'accountName': name,
    "accountBalance": balance,
    'accountType': type?.toString().split('.').last,
    'currency': currency?.toString().split('.').last,
    'color': color ?? ColorUtils.colorToHex(AppColors.blue),
    'icon': _getCodeFromIcon(
      MoneySourceIconColorMapper.iconFor(
        type?.toString().split('.').last ?? '',
      ),
    ), // Default color if not provided
    'description': description ?? '',
    'active': isActive,
  };

  // Helper methods for IconData conversion
  static String _getCodeFromIcon(IconData iconData) {
    // Convert IconData to a string representation
    return '${iconData.codePoint}_${iconData.fontFamily}_${iconData.fontPackage}';
  }

  static IconData _getIconFromCode(String iconCode) {
    try {
      final parts = iconCode.split('_');
      if (parts.length >= 3) {
        final codePoint = int.parse(parts[0]);
        final fontFamily = parts[1];
        final fontPackage = parts[2];
        return IconData(
          codePoint,
          fontFamily: fontFamily,
          fontPackage: fontPackage,
        );
      }
    } catch (e) {
      // Return default icon if parsing fails
      return Icons.account_balance_wallet;
    }
    return Icons.account_balance_wallet;
  }
}


