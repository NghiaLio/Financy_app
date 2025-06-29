import 'package:financy_ui/app/cubit/themeCubit.dart';
import 'package:financy_ui/core/constants/languageOptions.dart';
import 'package:financy_ui/shared/utils/locale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String selectedLanguage;

  final List languages = LangOptions.languages;

  @override
  void initState() {
    selectedLanguage = LocaleUtils.localeToString(
      context.read<ThemeCubit>().state.lang ?? Locale('vi'),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.chooseLanguage,
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
        ],
      ),
    );
  }

  Widget _buildLanguageItem(LanguageOption language) {
    final isSelected = selectedLanguage == language.code;

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
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
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
              const Icon(Icons.check_circle, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  void _onLanguageSelected(LanguageOption language) {
    //change language
    context.read<ThemeCubit>().changeSetting(
      language.code,
      null,
      null,
      null,
      null,
    );
    Future.delayed(const Duration(milliseconds: 500));
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.languageChanged),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, language);
    });
  }
}

// Custom flag widget if you want to use images instead of emojis
class FlagWidget extends StatelessWidget {
  final String countryCode;
  final double size;

  const FlagWidget({Key? key, required this.countryCode, this.size = 40})
    : super(key: key);

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
