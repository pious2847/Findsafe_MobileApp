import 'package:findsafe/widgets/language_selector.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();
  
  final _selectedLanguageCode = 'en'.obs;
  final _languagePrefsKey = 'languageCode';
  
  final List<Language> supportedLanguages = [
    const Language(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇺🇸',
    ),
    const Language(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flagEmoji: '🇪🇸',
    ),
    const Language(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flagEmoji: '🇫🇷',
    ),
    const Language(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flagEmoji: '🇩🇪',
    ),
    const Language(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      flagEmoji: '🇨🇳',
    ),
    const Language(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flagEmoji: '🇯🇵',
    ),
    const Language(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flagEmoji: '🇸🇦',
    ),
    const Language(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flagEmoji: '🇮🇳',
    ),
  ];
  
  String get selectedLanguageCode => _selectedLanguageCode.value;
  
  Language get selectedLanguage => supportedLanguages.firstWhere(
    (lang) => lang.code == selectedLanguageCode,
    orElse: () => supportedLanguages.first,
  );
  
  @override
  void onInit() {
    super.onInit();
    _loadLanguageFromPrefs();
  }
  
  Future<void> _loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languagePrefsKey) ?? 'en';
    _selectedLanguageCode.value = languageCode;
    
    // Update app locale
    final locale = Locale(languageCode);
    Get.updateLocale(locale);
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (_selectedLanguageCode.value == languageCode) return;
    
    _selectedLanguageCode.value = languageCode;
    
    // Update app locale
    final locale = Locale(languageCode);
    Get.updateLocale(locale);
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefsKey, languageCode);
  }
}
