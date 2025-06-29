import 'package:flutter/material.dart';

class LocaleUtils {
  static String localeToString(Locale locale) {
    // Nếu là en thì có en_US, UK,...mở rộng sau 
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty && locale.languageCode == 'en') {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    // Trả về mã ngôn ngữ, ví dụ: 'vi', 'en', ...
    return locale.languageCode;
  }

  static Locale? stringToLocale(String? code) {
    if(code == null) return null;
    // Có thể mở rộng cho nhiều ngôn ngữ nếu cần
    switch (code) {
      case 'vi':
        return const Locale('vi');
      case 'en_US':
        return const Locale('en','US');
      case 'en_GB':
        return const Locale('en', 'GB');
      case 'ja':
        return const Locale('ja');
      case 'ru':
        return const Locale('ru');
      case 'fr':
        return const Locale('fr');
      default:
        return Locale(code);
    }
  }
}
