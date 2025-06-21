import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'English (UK)';

  final List<LanguageOption> languages = [
    LanguageOption(
      flag: '🇬🇧',
      name: 'English (UK)',
      code: 'en_GB',
    ),
    LanguageOption(
      flag: '🇺🇸',
      name: 'English (US)',
      code: 'en_US',
    ),
    LanguageOption(
      flag: '🇻🇳',
      name: 'Việt Nam',
      code: 'vi_VN',
    ),
    LanguageOption(
      flag: '🇲🇲',
      name: 'Myanmar',
      code: 'my_MM',
    ),
    LanguageOption(
      flag: '🇱🇦',
      name: 'Lào',
      code: 'lo_LA',
    ),
    LanguageOption(
      flag: '🇹🇭',
      name: 'Thái Lan',
      code: 'th_TH',
    ),
    LanguageOption(
      flag: '🇧🇪',
      name: 'Belgium',
      code: 'nl_BE',
    ),
    LanguageOption(
      flag: '🇫🇷',
      name: 'French',
      code: 'fr_FR',
    ),
    LanguageOption(
      flag: '🇰🇷',
      name: 'Korea',
      code: 'ko_KR',
    ),
    LanguageOption(
      flag: '🇮🇳',
      name: 'India',
      code: 'hi_IN',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Language Selection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLanguageItem(language),
                  );
                },
              ),
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(LanguageOption language) {
    final isSelected = selectedLanguage == language.name;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language.name;
        });
        _onLanguageSelected(language);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
            ? Border.all(color: Colors.blue, width: 2)
            : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            icon: Icons.widgets,
            label: 'Sổ giao dịch',
            isActive: false,
          ),
          _buildBottomNavItem(
            icon: Icons.pie_chart,
            label: 'Ví tiền',
            isActive: false,
          ),
          _buildBottomNavItem(
            icon: Icons.add_circle,
            label: '',
            isActive: false,
            isAddButton: true,
          ),
          _buildBottomNavItem(
            icon: Icons.pie_chart_outline,
            label: 'Thống kê',
            isActive: false,
          ),
          _buildBottomNavItem(
            icon: Icons.settings,
            label: 'Cài đặt',
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isAddButton = false,
  }) {
    if (isAddButton) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _onLanguageSelected(LanguageOption language) {
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to ${language.name}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Here you can implement actual language change logic
    // For example, using a localization package like flutter_localizations
    // or updating app preferences
    
    // Delay navigation to show the selection feedback
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, language);
    });
  }
}

class LanguageOption {
  final String flag;
  final String name;
  final String code;

  LanguageOption({
    required this.flag,
    required this.name,
    required this.code,
  });
}

// Custom flag widget if you want to use images instead of emojis
class FlagWidget extends StatelessWidget {
  final String countryCode;
  final double size;

  const FlagWidget({
    Key? key,
    required this.countryCode,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipOval(
        child: Container(
          color: Colors.grey.shade200,
          child: Center(
            child: Text(
              _getFlagEmoji(countryCode),
              style: TextStyle(fontSize: size * 0.6),
            ),
          ),
        ),
      ),
    );
  }

  String _getFlagEmoji(String countryCode) {
    switch (countryCode.toLowerCase()) {
      case 'gb':
        return '🇬🇧';
      case 'us':
        return '🇺🇸';
      case 'vn':
        return '🇻🇳';
      case 'mm':
        return '🇲🇲';
      case 'la':
        return '🇱🇦';
      case 'th':
        return '🇹🇭';
      case 'be':
        return '🇧🇪';
      case 'fr':
        return '🇫🇷';
      case 'kr':
        return '🇰🇷';
      case 'in':
        return '🇮🇳';
      default:
        return '🏳️';
    }
  }
}