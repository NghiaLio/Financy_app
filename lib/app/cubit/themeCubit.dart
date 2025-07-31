
// ignore_for_file: file_names

import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/locale_utils.dart';
import 'package:financy_ui/shared/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ThemeState {
  final Color? color;
  final double? fontSize;
  final String? fontFamily;
  final ThemeMode? themeMode;
  final Locale? lang;

  ThemeState({
    required this.color,
    required this.fontFamily,
    required this.fontSize,
    required this.themeMode,
    required this.lang,
  });

  ThemeState copyWith({
    Color? color,
    double? fontSize,
    String? fontFamily,
    ThemeMode? themeMode,
    Locale? lang,
  }) {
    return ThemeState(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
      lang: lang ?? this.lang,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  final Box box = Hive.box('settings');

  ThemeCubit()
    : super(
        ThemeState(
          color: ColorUtils.parseColor(
            Hive.box('settings').get('color', defaultValue: '0xFF2196F3'),
          ),
          fontFamily: Hive.box(
            'settings',
          ).get('fontFamily', defaultValue: 'Roboto'),
          fontSize: Hive.box('settings').get('fontSize', defaultValue: 16.0),
          themeMode: ThemeUtils.staticThemeDataFromString(
            Hive.box('settings').get('themeMode', defaultValue: 'Light'),
          ),
          lang: LocaleUtils.stringToLocale(
            Hive.box('settings').get('lang', defaultValue: 'vi'),
          ),
        ),
      );
  void changeThemeMode(String mode) {
    emit(state.copyWith(themeMode: ThemeUtils.staticThemeDataFromString(mode)));
  }

  void changeSetting(
    String? lang,
    String? font,
    String? themeMode,
    double? fontSize,
    String? color,
  ) {
    // Lưu vào Hive nếu có giá trị mới
    if (lang != null) box.put('lang', lang);
    if (font != null) box.put('fontFamily', font);
    if (themeMode != null) box.put('themeMode', themeMode);
    if (fontSize != null) box.put('fontSize', fontSize);
    if (color != null) box.put('color', color);

    // Lấy giá trị hiện tại nếu tham số là null
    final String newLang = lang ?? LocaleUtils.localeToString(state.lang ?? Locale('vi'));
    final String? newFont = font ?? state.fontFamily;
    final String newThemeMode =
        themeMode ??
        ThemeUtils.themeModeToString(state.themeMode ?? ThemeMode.light);
    final double? newFontSize = fontSize ?? state.fontSize;
    final String newColor =
        color ?? ColorUtils.colorToHex(state.color ?? Color(0xFF2196F3));

    emit(
      state.copyWith(
        lang: LocaleUtils.stringToLocale(newLang),
        color: ColorUtils.parseColor(newColor),
        fontFamily: newFont,
        fontSize: newFontSize,
        themeMode: ThemeUtils.staticThemeDataFromString(newThemeMode),
      ),
    );
  }
}
