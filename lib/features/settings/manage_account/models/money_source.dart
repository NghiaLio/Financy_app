import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class MoneySource {
  String id;
  String name;
  double balance;
  String type;
  String currency;
  IconData icon;
  Color color;
  MoneySource({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.currency,
    required this.icon,
    required this.color,
  });

  /// Factory constructor for backend data (no icon/color)
  factory MoneySource.fromJson(Map<String, dynamic> json) {
    return MoneySource(
      id: json['_id'] as String,
      name: json['accountName'] as String,
      balance: (json['accountBalance'] as num).toDouble(),
      type: json['accountType'] as String,
      currency: json['currency'] as String,
      icon: MoneySourceIconColorMapper.iconFor(json['accountType']),
      color: MoneySourceIconColorMapper.colorFor(json['accountType']),
    );
  }
}

/// Mapping tên nguồn tiền sang icon và màu mặc định
class MoneySourceIconColorMapper {
  static const Map<String, IconData> _iconMap = {
    'Cash': Icons.payments,
    'E_Wallet': Icons.account_balance_wallet,
    'Banking': Icons.account_balance,
    'default': Icons.account_balance_wallet,
  };

  static const Map<String, Color> _colorMap = {
    'Cash': AppColors.positiveGreen,
    'E_Wallet': AppColors.accentPink,
    'Banking': AppColors.primaryBlue,
    'default': AppColors.blue,
  };

  static IconData iconFor(String name) {
    return _iconMap.entries
        .firstWhere(
          (e) => name.contains(e.key),
          orElse: () => const MapEntry('default', Icons.account_balance_wallet),
        )
        .value;
  }

  static Color colorFor(String name) {
    return _colorMap.entries
        .firstWhere(
          (e) => name.contains(e.key),
          orElse: () => const MapEntry('default', Colors.blueGrey),
        )
        .value;
  }
}
