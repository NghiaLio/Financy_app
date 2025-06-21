import 'package:flutter/material.dart';

class InterfaceSettings extends StatefulWidget {
  const InterfaceSettings({Key? key}) : super(key: key);

  @override
  State<InterfaceSettings> createState() => _InterfaceSettingsState();
}

class _InterfaceSettingsState extends State<InterfaceSettings> {
  // Theme settings
  String _selectedTheme = 'Dark';
  String _selectedLanguage = 'Tiếng Việt';
  String _selectedFont = 'Default';
  double _fontSize = 16.0;
  bool _enableAnimations = true;
  bool _enableVibration = true;

  // Color themes
  final Map<String, Color> _colorThemes = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Purple': Colors.purple,
    'Orange': Colors.orange,
    'Red': Colors.red,
    'Cyan': Colors.cyan,
  };
  String _selectedColorTheme = 'Blue';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cài đặt giao diện',
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
            _buildSectionTitle('Chủ đề'),
            _buildThemeSelector(),
            SizedBox(height: 24),

            // Color Theme Section
            _buildSectionTitle('Màu chủ đạo'),
            _buildColorThemeSelector(),
            SizedBox(height: 24),

            // Font Section
            _buildSectionTitle('Phông chữ'),
            _buildFontSelector(),
            SizedBox(height: 16),
            _buildFontSizeSlider(),
            SizedBox(height: 24),

            // Animation Section
            _buildSectionTitle('Hiệu ứng'),
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
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRadioTile('Dark', 'Tối', Icons.dark_mode),
          Divider(color: Colors.grey[600], height: 1),
          _buildRadioTile('Light', 'Sáng', Icons.light_mode),
          Divider(color: Colors.grey[600], height: 1),
          _buildRadioTile('Auto', 'Tự động', Icons.brightness_auto),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedTheme,
      onChanged: (String? newValue) {
        setState(() {
          _selectedTheme = newValue!;
        });
      },
      title: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
      activeColor: _colorThemes[_selectedColorTheme],
      fillColor: MaterialStateProperty.resolveWith<Color?>((
        Set<MaterialState> states,
      ) {
        if (states.contains(MaterialState.selected)) {
          return _colorThemes[_selectedColorTheme];
        }
        return Colors.grey;
      }),
    );
  }

  Widget _buildColorThemeSelector() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colorThemes.length,
        itemBuilder: (context, index) {
          String themeName = _colorThemes.keys.elementAt(index);
          Color themeColor = _colorThemes[themeName]!;
          bool isSelected = _selectedColorTheme == themeName;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColorTheme = themeName;
              });
            },
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
        color: Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFont,
          isExpanded: true,
          dropdownColor: Color(0xFF2A2A3E),
          style: TextStyle(color: Colors.white, fontSize: 16),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          items:
              fonts.map((String font) {
                return DropdownMenuItem<String>(value: font, child: Text(font));
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFont = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A3E),
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
                'Kích thước chữ',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
              onChanged: (double value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Row(
              children: [
                Icon(Icons.animation, color: Colors.white70, size: 20),
                SizedBox(width: 12),
                Text(
                  'Hiệu ứng chuyển động',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
                Icon(Icons.vibration, color: Colors.white70, size: 20),
                SizedBox(width: 12),
                Text(
                  'Rung phản hồi',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
        color: Color(0xFF2A2A3E),
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
                    'Ví tiền',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontSize,
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
            'Đây là giao diện xem trước với các cài đặt hiện tại',
            style: TextStyle(color: Colors.white70, fontSize: _fontSize - 2),
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
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hủy',
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
              'Lưu cài đặt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    // Lưu cài đặt vào SharedPreferences hoặc database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cài đặt đã được lưu thành công!'),
        backgroundColor: _colorThemes[_selectedColorTheme],
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }
}
