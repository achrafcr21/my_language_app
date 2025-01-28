import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'es';
  String _targetLanguage = 'en';
  String _proficiencyLevel = 'intermediate';

  String get currentLanguage => _currentLanguage;
  String get targetLanguage => _targetLanguage;
  String get proficiencyLevel => _proficiencyLevel;

  void setTargetLanguage(String language) {
    _targetLanguage = language;
    notifyListeners();
  }

  void setProficiencyLevel(String level) {
    _proficiencyLevel = level;
    notifyListeners();
  }

  // Lista de idiomas soportados
  final List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
  ];

  // Niveles de competencia
  final List<String> proficiencyLevels = [
    'beginner',
    'intermediate',
    'advanced',
  ];
}
