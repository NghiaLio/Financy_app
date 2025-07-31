import 'package:flutter/material.dart';

/// Mapping tên nguồn tiền sang icon và màu mặc định
class MoneySourceIconColorMapper {
  static const Map<String, IconData> _iconMap = {
    'cash': Icons.payments,
    'eWallet': Icons.account_balance_wallet,
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