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

class MoneySourceBackgrounds {
  static const String basePath = 'assets/background';

  static const Map<String, String> nameToBackground = {
    // E-wallets
    'shopeepay': '$basePath/shoppe.png',
    'viettelpay': '$basePath/viettel.png',
    'vnpay': '$basePath/vn.png',
    'zalopay': '$basePath/zalo.png',
    'momo': '$basePath/momo.png',

    // Banks
    'tpbank': '$basePath/tp.png',
    'acb': '$basePath/acb.png',
    'mbbank': '$basePath/mb.png',
    'vpbank': '$basePath/vp.png',
    'vietcombank': '$basePath/vcb.png',
    'vietinbank': '$basePath/vettin.png',
    'bidv': '$basePath/bidv.png',
    'techcombank': '$basePath/tech.png',
    'agribank': '$basePath/agri.png',
  };

  static String? backgroundFor(String name) {
    final key = _normalizeName(name);
    return nameToBackground[key];
  }

  static String? backgroundForNullable(String? name) {
    if (name == null) return null;
    return backgroundFor(name);
  }

  static bool hasBackgroundFor(String name) {
    return backgroundFor(name) != null;
  }

  static String _normalizeName(String name) {
    final lower = name.toLowerCase();
    return lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
