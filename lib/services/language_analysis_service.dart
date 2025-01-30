import 'package:flutter/material.dart';

class LanguageLevel {
  final String level; // A1, A2, B1, B2, C1, C2
  final List<String> strengths;
  final List<String> areasToImprove;

  LanguageLevel({
    required this.level,
    required this.strengths,
    required this.areasToImprove,
  });
}

class LanguageAnalysisService {
  static const Map<String, List<String>> _topicsByLevel = {
    'A1': [
      'Saludos y presentaciones',
      'Números y fechas',
      'Familia y amigos',
      'Rutina diaria',
    ],
    'A2': [
      'Hobbies e intereses',
      'Comida y restaurantes',
      'Viajes básicos',
      'Descripción de personas',
    ],
    'B1': [
      'Experiencias pasadas',
      'Planes futuros',
      'Opiniones y debates simples',
      'Cultura y costumbres',
    ],
    'B2': [
      'Temas de actualidad',
      'Debates complejos',
      'Expresiones idiomáticas',
      'Situaciones laborales',
    ],
  };

  static final Map<String, List<String>> _commonErrors = {
    'A1': ['ser/estar', 'género de palabras', 'artículos'],
    'A2': ['pretérito/imperfecto', 'subjuntivo básico', 'preposiciones'],
    'B1': ['subjuntivo avanzado', 'conectores', 'modismos'],
    'B2': ['matices de significado', 'registro formal/informal', 'expresiones cultas'],
  };

  String _currentLevel = 'A1';
  final List<String> _detectedErrors = [];
  final List<String> _masteredTopics = [];

  Future<LanguageLevel> analyzeUserInput(String userInput) async {
    // Análisis básico de complejidad
    final wordCount = userInput.split(' ').length;
    final containsComplexStructures = _checkComplexStructures(userInput);
    final errors = _detectErrors(userInput);
    
    // Actualizar nivel basado en el análisis
    _updateLevel(wordCount, containsComplexStructures, errors);
    
    return LanguageLevel(
      level: _currentLevel,
      strengths: _identifyStrengths(userInput),
      areasToImprove: _identifyAreasToImprove(errors),
    );
  }

  List<String> getSuggestedTopics() {
    final currentTopics = _topicsByLevel[_currentLevel] ?? [];
    // Filtrar temas ya dominados
    return currentTopics.where((topic) => !_masteredTopics.contains(topic)).toList();
  }

  bool _checkComplexStructures(String text) {
    final complexPatterns = [
      r'aunque',
      r'sin embargo',
      r'hubiera|hubiese',
      r'para que',
      r'a fin de que',
    ];

    return complexPatterns.any((pattern) => 
      RegExp(pattern, caseSensitive: false).hasMatch(text));
  }

  List<String> _detectErrors(String text) {
    final errors = <String>[];
    // Implementar detección de errores comunes
    _commonErrors[_currentLevel]?.forEach((error) {
      if (_textContainsErrorPattern(text, error)) {
        errors.add(error);
      }
    });
    return errors;
  }

  bool _textContainsErrorPattern(String text, String errorType) {
    // Implementar patrones de error específicos
    return false; // Placeholder
  }

  void _updateLevel(int wordCount, bool hasComplexStructures, List<String> errors) {
    // Lógica de actualización de nivel basada en múltiples factores
    if (wordCount > 50 && hasComplexStructures && errors.isEmpty) {
      _promoteLevel();
    } else if (errors.length > 5) {
      _demoteLevel();
    }
  }

  void _promoteLevel() {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final currentIndex = levels.indexOf(_currentLevel);
    if (currentIndex < levels.length - 1) {
      _currentLevel = levels[currentIndex + 1];
    }
  }

  void _demoteLevel() {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final currentIndex = levels.indexOf(_currentLevel);
    if (currentIndex > 0) {
      _currentLevel = levels[currentIndex - 1];
    }
  }

  List<String> _identifyStrengths(String text) {
    final strengths = <String>[];
    if (text.length > 100) strengths.add('Expresión extensa');
    if (_checkComplexStructures(text)) strengths.add('Uso de estructuras complejas');
    return strengths;
  }

  List<String> _identifyAreasToImprove(List<String> errors) {
    return errors.isEmpty 
      ? ['Practica estructuras más complejas'] 
      : errors;
  }
}
