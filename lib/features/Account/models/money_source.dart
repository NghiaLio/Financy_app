import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

enum CurrencyType { vnd, usd }

enum TypeMoney { cash, eWallet, bank, other }

class MoneySource {
  String? id;
  String name;
  double balance;
  TypeMoney? type;
  CurrencyType? currency;
  IconData? icon;
  String? color;
  String? description;
  bool isActive;
  MoneySource({
    this.id,
    required this.name,
    required this.balance,
     this.type,
     this.currency,
    this.icon,
    this.color,
    this.description,
    required this.isActive,
  });

  /// Factory constructor for backend data (no icon/color)
  factory MoneySource.fromJson(Map<String, dynamic> json) {
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
      icon: MoneySourceIconColorMapper.iconFor(json['accountType']),
      color: json['color'] as String? ?? ColorUtils.colorToHex(AppColors.blue), 
      // Default color if not provided
      description: json['description'] as String? ?? '',
      isActive: json['active'] as bool? ?? true, // Default to true if not provided
    );
  }

  Map<String, dynamic> toJson() => {
    'accountName': name,
    "accountBalance": balance,
    'accountType': type?.toString().split('.').last,
    'currency': currency?.toString().split('.').last,
    'color': color ?? ColorUtils.colorToHex(AppColors.blue), // Default color if not provided
    'description': description ?? '',
    'active': isActive,
  };
}

/// Mapping tên nguồn tiền sang icon và màu mặc định
class MoneySourceIconColorMapper {
  static const Map<String, IconData> _iconMap = {
    'cash': Icons.payments,
    'ewallet': Icons.account_balance_wallet,
    'banking': Icons.account_balance,
    'default': Icons.account_balance_wallet,
  };

 

  static IconData iconFor(String name) {
    final key = name.toLowerCase();
    return _iconMap.entries
        .firstWhere(
          (e) => key.contains(e.key),
          orElse: () => const MapEntry('default', Icons.account_balance_wallet),
        )
        .value;
  }

  
}
