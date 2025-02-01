import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_progress.dart';

class ProgressProvider with ChangeNotifier {
  UserProgress? _userProgress;
  final String _storageKey = 'user_progress';

  UserProgress? get userProgress => _userProgress;

  Future<void> initializeProgress(String userId) async {
    if (_userProgress != null) return;

    final prefs = await SharedPreferences.getInstance();
    final storedProgress = prefs.getString(_storageKey);

    if (storedProgress != null) {
      _userProgress = UserProgress.fromJson(jsonDecode(storedProgress));
    } else {
      _userProgress = UserProgress.initial(userId);
    }
    notifyListeners();
  }

  Future<void> initializeLanguage(String language) async {
    if (_userProgress == null) return;

    if (!_userProgress!.languages.containsKey(language)) {
      _userProgress!.languages[language] = {
        for (var skill in UserProgressSkill.values)
          skill: SkillProgress(
            experience: 0,
            currentLevel: ProficiencyLevel.a1,
            experienceForNextLevel: 100,
          ),
      };
      await _saveProgress();
    }
  }

  Map<UserProgressSkill, SkillProgress>? getLanguageProgress(String language) {
    return _userProgress?.languages[language];
  }

  ProficiencyLevel? getCurrentLevel(String language) {
    if (_userProgress == null || !_userProgress!.languages.containsKey(language)) {
      return null;
    }

    final skills = _userProgress!.languages[language]!;
    final totalLevel = skills.values
        .map((progress) => progress.currentLevel.index)
        .reduce((a, b) => a + b);
    
    final averageLevel = (totalLevel / skills.length).floor();
    return ProficiencyLevel.values[averageLevel];
  }

  int getDailyStreak() {
    return _userProgress?.dailyStreak ?? 0;
  }

  int getTotalExperience() {
    return _userProgress?.totalExperience ?? 0;
  }

  Future<void> addExperience(
    String language,
    UserProgressSkill skill,
    int amount,
  ) async {
    if (_userProgress == null) return;

    if (!_userProgress!.languages.containsKey(language)) {
      await initializeLanguage(language);
    }

    final skillProgress = _userProgress!.languages[language]![skill]!;
    final newExperience = skillProgress.experience + amount;

    // Calcular nuevo nivel si es necesario
    ProficiencyLevel newLevel = skillProgress.currentLevel;
    int experienceForNext = skillProgress.experienceForNextLevel;

    if (newExperience >= experienceForNext) {
      final currentLevelIndex = ProficiencyLevel.values.indexOf(skillProgress.currentLevel);
      if (currentLevelIndex < ProficiencyLevel.values.length - 1) {
        newLevel = ProficiencyLevel.values[currentLevelIndex + 1];
        experienceForNext = _calculateExperienceForLevel(newLevel);
      }
    }

    _userProgress!.languages[language]![skill] = SkillProgress(
      experience: newExperience,
      currentLevel: newLevel,
      experienceForNextLevel: experienceForNext,
    );

    _userProgress = _userProgress!.copyWith(
      totalExperience: _userProgress!.totalExperience + amount,
    );

    await _saveProgress();
  }

  int _calculateExperienceForLevel(ProficiencyLevel level) {
    final Map<ProficiencyLevel, int> experienceRequirements = {
      ProficiencyLevel.a1: 100,
      ProficiencyLevel.a2: 250,
      ProficiencyLevel.b1: 500,
      ProficiencyLevel.b2: 1000,
      ProficiencyLevel.c1: 2000,
      ProficiencyLevel.c2: 4000,
    };

    return experienceRequirements[level] ?? 100;
  }

  Future<void> updateSkillLevels(
    String language,
    Map<UserProgressSkill, ProficiencyLevel> skillLevels,
  ) async {
    if (_userProgress == null) return;

    if (!_userProgress!.languages.containsKey(language)) {
      await initializeLanguage(language);
    }

    for (var entry in skillLevels.entries) {
      final skill = entry.key;
      final newLevel = entry.value;
      
      _userProgress!.languages[language]![skill] = SkillProgress(
        experience: _calculateExperienceForLevel(newLevel),
        currentLevel: newLevel,
        experienceForNextLevel: _calculateExperienceForLevel(
          ProficiencyLevel.values[
            (ProficiencyLevel.values.indexOf(newLevel) + 1)
                .clamp(0, ProficiencyLevel.values.length - 1)
          ],
        ),
      );
    }

    await _saveProgress();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_userProgress!.toJson()));
    notifyListeners();
  }
}
