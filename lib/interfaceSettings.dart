// ignore_for_file: file_names, deprecated_member_use

import 'dart:developer';
import 'package:financy_ui/app/cubit/themeCubit.dart';
import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class InterfaceSettings extends StatefulWidget {
  const InterfaceSettings({super.key});

  @override
  State<InterfaceSettings> createState() => _InterfaceSettingsState();
}

class _InterfaceSettingsState extends State<InterfaceSettings> {
  // Theme settings
  late String _selectedTheme;
  late String _selectedFont;
  late double _fontSize;
  late ThemeMode _preThemeMode;
  bool _isSaveChange = false;
  bool _enableAnimations = true;
  bool _enableVibration = true;

  // Color themes
  final Map<String, Color> _colorThemes = {
    '0xFF2196F3': AppColors.blue,
    '0xFF4CAF50': AppColors.green,
    '0xFF9C27B0': AppColors.accentPink,
    '0xFFFF9800': AppColors.orange,
    '0xFFF44336': AppColors.red,
    'Cyan': AppColors.cyan,
  };
  late String _selectedColorTheme;
  @override
  void initState() {
    _selectedColorTheme = ColorUtils.colorToHex(
      context.read<ThemeCubit>().state.color!,
    );
    _preThemeMode = context.read<ThemeCubit>().state.themeMode!;
    _selectedTheme = ThemeUtils.themeModeToString(_preThemeMode);

    _fontSize = context.read<ThemeCubit>().state.fontSize!;
    _selectedFont = context.read<ThemeCubit>().state.fontFamily!;

    log(_selectedTheme);
    super.initState();
  }

  // chọn chế độ theme
  void selectedModeTheme(String? newValue) {
    setState(() {
      log(newValue!);
      _selectedTheme = newValue;
      // Chỉ đổi trạng thái theme, không lưu vào box
      context.read<ThemeCubit>().changeThemeMode(newValue);
    });
  }

  // chọn màu chủ đạo
  void changeColorTheme(String themeName) {
    setState(() {
      _selectedColorTheme = themeName;
    });
  }

  // chọn font chữ
  void selectedFontFamily(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedFont = newValue;
      });
    }
  }

  // chọn kích thước chữ
  void changeFontSize(double value) {
    setState(() {
      _fontSize = value;
    });
  }

  // lưu toàn bộ thay đổi
  void _saveSettings() {
    log(_selectedColorTheme);
    log(_selectedTheme);
    log(_fontSize.toString());
    log(_selectedFont);
    setState(() {
      _isSaveChange = true;
    });
    // Lưu cài đặt vào Hive
    context.read<ThemeCubit>().changeSetting(
      null,
      _selectedFont,
      _selectedTheme,
      _fontSize,
      _selectedColorTheme,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.saveSettings),
        backgroundColor: _colorThemes[_selectedColorTheme],
        duration: Duration(seconds: 2),
      ),
    );
  }

  // trở về màn trước
  void back() {
    // Cài lại chế độ theme khi chưa lưu
    if (!_isSaveChange) {
      context.read<ThemeCubit>().changeThemeMode(
        ThemeUtils.themeModeToString(_preThemeMode),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: ColorUtils.parseColor(_selectedColorTheme),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: back,
        ),
        title: Text(
          appLocal.themeSettings,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _buildSectionTitle(appLocal.theme),
            _buildThemeSelector(),
            SizedBox(height: 24),

            // Color Theme Section
            _buildSectionTitle(appLocal.primaryColor),
            _buildColorThemeSelector(),
            SizedBox(height: 24),

            // Font Section
            _buildSectionTitle(appLocal.fontFamily),
            _buildFontSelector(),
            SizedBox(height: 16),
            _buildFontSizeSlider(),
            SizedBox(height: 24),

            // Animation Section
            _buildSectionTitle(appLocal.effect),
            _buildAnimationSettings(),
            SizedBox(height: 24),

            // Preview Section
            _buildSectionTitle('Xem trước'),
            _buildPreviewCard(),
            SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRadioTile('Dark', AppLocalizations.of(context)!.dark, Icons.dark_mode),
          Divider(color: Colors.grey[600], height: 1),
          _buildRadioTile('Light', AppLocalizations.of(context)!.light, Icons.light_mode),
          Divider(color: Colors.grey[600], height: 1),
          _buildRadioTile('System', AppLocalizations.of(context)!.system, Icons.brightness_auto),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedTheme,
      onChanged: selectedModeTheme,
      title: Row(
        children: [
          Icon(icon, color: Theme.of(context).highlightColor, size: 20),
          SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      activeColor: _colorThemes[_selectedColorTheme],
      fillColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return _colorThemes[_selectedColorTheme];
        }
        return Colors.grey;
      }),
    );
  }

  Widget _buildColorThemeSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colorThemes.length,
        itemBuilder: (context, index) {
          String themeName = _colorThemes.keys.elementAt(index);
          Color themeColor = _colorThemes[themeName]!;
          bool isSelected = _selectedColorTheme == themeName;

          return GestureDetector(
            onTap: () => changeColorTheme(themeName),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      border:
                          isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                    ),
                    child:
                        isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                  ),
                  SizedBox(height: 8),
                  Text(
                    themeName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFontSelector() {
    List<String> fonts = [
      'Default',
      'Roboto',
      'Open Sans',
      'Lato',
      'Montserrat',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFont,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          style: Theme.of(context).textTheme.bodyLarge,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).highlightColor,
          ),
          items:
              fonts.map((String font) {
                return DropdownMenuItem<String>(value: font, child: Text(font));
              }).toList(),
          onChanged: selectedFontFamily,
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.fontSize,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '${_fontSize.toInt()}px',
                style: TextStyle(
                  color: _colorThemes[_selectedColorTheme],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _colorThemes[_selectedColorTheme],
              thumbColor: _colorThemes[_selectedColorTheme],
              overlayColor: _colorThemes[_selectedColorTheme]!.withOpacity(0.2),
            ),
            child: Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              onChanged: changeFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Row(
              children: [
                Icon(
                  Icons.animation,
                  color: Theme.of(context).highlightColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Hiệu ứng chuyển động',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            value: _enableAnimations,
            onChanged: (bool value) {
              setState(() {
                _enableAnimations = value;
              });
            },
            activeColor: _colorThemes[_selectedColorTheme],
          ),
          Divider(color: Colors.grey[600], height: 1),
          SwitchListTile(
            title: Row(
              children: [
                Icon(
                  Icons.vibration,
                  color: Theme.of(context).highlightColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Rung phản hồi',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            value: _enableVibration,
            onChanged: (bool value) {
              setState(() {
                _enableVibration = value;
              });
            },
            activeColor: _colorThemes[_selectedColorTheme],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _colorThemes[_selectedColorTheme],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance_wallet, color: Colors.white),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.wallet,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '10,000,000 VND',
                    style: TextStyle(
                      color: _colorThemes[_selectedColorTheme],
                      fontSize: _fontSize - 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _colorThemes[_selectedColorTheme],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.previewNote,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: back,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _saveSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorThemes[_selectedColorTheme],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.saveSettings,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
