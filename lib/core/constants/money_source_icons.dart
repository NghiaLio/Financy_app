import 'package:flutter/material.dart';

class MoneySourceIcons {
  static const List<IconData> all = [
    Icons.account_balance_wallet,
    Icons.account_balance,
    Icons.payments,
    Icons.wallet,
    Icons.credit_card,
    Icons.savings,
    Icons.monetization_on,
    Icons.attach_money,
  ];
}

class MoneySourceImages {
  static const String basePath = 'assets/image';

  static const Map<String, String> nameToAsset = {
    // E-wallets
    'shopeepay': '$basePath/Shopee-Pay-Logo-Vector.svg-.png',
    'viettelpay': '$basePath/logo-viettelpay-inkythuatso-3-14-08-56-36.jpg',
    'vnpay': '$basePath/Icon-VNPAY-QR.webp',
    'zalopay': '$basePath/zalopay.jpg',
    'momo': '$basePath/MoMo_Logo.png',

    // Banks
    'tpbank': '$basePath/Icon-TPBank.webp',
    'acb': '$basePath/Logo-ACB.webp',
    'mbbank': '$basePath/Icon-MB-Bank-MBB.webp',
    'vpbank': '$basePath/Icon-VPBank.webp',
    'vietcombank': '$basePath/Icon-Vietcombank.webp',
    'vietinbank': '$basePath/Logo-VietinBank-CTG-Ori.webp',
    'bidv': '$basePath/Logo-BIDV-.webp',
    'techcombank': '$basePath/Logo-TCB-V.webp',
    'agribank': '$basePath/Icon-Agribank.webp',

    // Misc
    'google': '$basePath/google.png',
  };

  static String? assetFor(String name) {
    final key = _normalizeName(name);
    return nameToAsset[key];
  }

  static String? assetForNullable(String? name) {
    if (name == null) return null;
    return assetFor(name);
  }

  static bool hasAssetFor(String name) {
    return assetFor(name) != null;
  }

  static String _normalizeName(String name) {
    final lower = name.toLowerCase();
    return lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class MoneySourceColors {
  static const Map<String, Color> nameToColor = {
    // E-wallets
    'shopeepay': Color(0xFFEE4D2D), // Shopee orange-red
    'viettelpay': Color(0xFF1BA345), // Viettel green
    'vnpay': Color(0xFF0066CC), // VNPay blue
    'zalopay': Color(0xFF0068FF), // ZaloPay blue
    'momo': Color(0xFFD82D8B), // MoMo pink

    // Banks
    'tpbank': Color(0xFFFFD700), // TPBank yellow/gold
    'acb': Color(0xFF00A651), // ACB green
    'mbbank': Color(0xFF1E3A8A), // MB Bank blue
    'vpbank': Color(0xFF00A86B), // VPBank green
    'vietcombank': Color(0xFF007AC3), // Vietcombank blue
    'vietinbank': Color(0xFF1E40AF), // VietinBank blue
    'bidv': Color(0xFF0066CC), // BIDV blue
    'techcombank': Color(0xFF00B14F), // Techcombank green
    'agribank': Color(0xFF00A651), // Agribank green

    // Misc
    'google': Color(0xFF4285F4), // Google blue
  };

  static Color? colorFor(String name) {
    final key = _normalizeName(name);
    return nameToColor[key];
  }

  static Color? colorForNullable(String? name) {
    if (name == null) return null;
    return colorFor(name);
  }

  static Color colorForWithFallback(String name, {Color fallback = const Color(0xFF6B7280)}) {
    return colorFor(name) ?? fallback;
  }

  static bool hasColorFor(String name) {
    return colorFor(name) != null;
  }

  static String _normalizeName(String name) {
    final lower = name.toLowerCase();
    return lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}