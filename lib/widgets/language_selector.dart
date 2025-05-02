import 'package:findsafe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });
}

class LanguageSelector extends StatelessWidget {
  final List<Language> languages;
  final String selectedLanguageCode;
  final ValueChanged<String> onLanguageSelected;

  const LanguageSelector({
    super.key,
    required this.languages,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.darkCardColor : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: languages.map((language) => _buildLanguageItem(
                    context,
                    language,
                    language.code == selectedLanguageCode,
                    isDarkMode,
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, Language language, bool isSelected, bool isDarkMode) {
    final textColor = isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
    final secondaryTextColor = isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor;
    final selectedColor = isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
    
    return InkWell(
      onTap: () {
        onLanguageSelected(language.code);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // Flag emoji
            Text(
              language.flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            
            // Language name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? selectedColor : textColor,
                    ),
                  ),
                  Text(
                    language.nativeName,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selected indicator
            if (isSelected)
              Icon(
                Iconsax.tick_circle,
                color: selectedColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
