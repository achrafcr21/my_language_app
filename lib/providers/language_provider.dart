import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/progress/models/user_progress.dart';

class LanguageProvider extends ChangeNotifier {
  String? _selectedLanguage;
  String? _targetLanguage;
  ProficiencyLevel? _currentLevel;
  final String _languageKey = 'selected_language';
  final String _targetLanguageKey = 'target_language';
  final String _levelKey = 'language_level';

  String? get selectedLanguage => _selectedLanguage;
  String? get targetLanguage => _targetLanguage;
  ProficiencyLevel? get currentLevel => _currentLevel;

  final List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'Inglés'},
    {'code': 'fr', 'name': 'Francés'},
    {'code': 'de', 'name': 'Alemán'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Portugués'},
    {'code': 'es', 'name': 'Español'},
  ];

  // Lista de idiomas disponibles para la app
  final List<String> availableLanguages = [
    'english',
    'french',
    'german',
    'italian',
    'portuguese',
    'spanish',
  ];

  // Inicializar el provider
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString(_languageKey);
    _targetLanguage = prefs.getString(_targetLanguageKey) ?? 'en';
    final levelIndex = prefs.getInt(_levelKey);
    if (levelIndex != null) {
      _currentLevel = ProficiencyLevel.values[levelIndex];
    }
    notifyListeners();
  }

  // Establecer el idioma seleccionado
  Future<void> setLanguage(String language) async {
    if (!availableLanguages.contains(language.toLowerCase())) {
      throw ArgumentError('Idioma no soportado: $language');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.toLowerCase());
    _selectedLanguage = language.toLowerCase();
    notifyListeners();
  }

  // Establecer el idioma objetivo para el chat
  Future<void> setTargetLanguage(String languageCode) async {
    if (!supportedLanguages.any((lang) => lang['code'] == languageCode)) {
      throw ArgumentError('Código de idioma no soportado: $languageCode');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetLanguageKey, languageCode);
    _targetLanguage = languageCode;
    notifyListeners();
  }

  // Actualizar el nivel del idioma
  Future<void> updateLanguageLevel(ProficiencyLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, level.index);
    _currentLevel = level;
    notifyListeners();
  }

  // Obtener el nombre del idioma en español
  String getLanguageNameInSpanish(String language) {
    final Map<String, String> languageNames = {
      'english': 'Inglés',
      'french': 'Francés',
      'german': 'Alemán',
      'italian': 'Italiano',
      'portuguese': 'Portugués',
      'spanish': 'Español',
    };
    return languageNames[language.toLowerCase()] ?? language;
  }

  // Obtener el código de idioma a partir del nombre
  String getLanguageCode(String languageName) {
    final Map<String, String> languageCodes = {
      'Inglés': 'en',
      'Francés': 'fr',
      'Alemán': 'de',
      'Italiano': 'it',
      'Portugués': 'pt',
      'Español': 'es',
    };
    return languageCodes[languageName] ?? 'en';
  }

  // Limpiar los datos del idioma
  Future<void> clearLanguageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
    await prefs.remove(_targetLanguageKey);
    await prefs.remove(_levelKey);
    _selectedLanguage = null;
    _targetLanguage = null;
    _currentLevel = null;
    notifyListeners();
  }
}
