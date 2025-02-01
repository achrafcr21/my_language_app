import 'package:flutter/foundation.dart';

enum UserProgressSkill {
  vocabulary,
  grammar,
  listening,
  reading,
  writing,
  speaking,
}

enum ProficiencyLevel {
  a1('A1'),
  a2('A2'),
  b1('B1'),
  b2('B2'),
  c1('C1'),
  c2('C2');

  final String code;
  const ProficiencyLevel(this.code);
}

class SkillProgress {
  final int experience;
  final ProficiencyLevel currentLevel;
  final int experienceForNextLevel;

  SkillProgress({
    required this.experience,
    required this.currentLevel,
    required this.experienceForNextLevel,
  });

  Map<String, dynamic> toJson() => {
    'experience': experience,
    'currentLevel': currentLevel.index,
    'experienceForNextLevel': experienceForNextLevel,
  };

  factory SkillProgress.fromJson(Map<String, dynamic> json) {
    return SkillProgress(
      experience: json['experience'] as int,
      currentLevel: ProficiencyLevel.values[json['currentLevel'] as int],
      experienceForNextLevel: json['experienceForNextLevel'] as int,
    );
  }
}

class UserProgress {
  final String userId;
  final Map<String, Map<UserProgressSkill, SkillProgress>> languages;
  final int dailyStreak;
  final DateTime lastLoginDate;
  final int totalExperience;

  UserProgress({
    required this.userId,
    required this.languages,
    required this.dailyStreak,
    required this.lastLoginDate,
    required this.totalExperience,
  });

  factory UserProgress.initial(String userId) {
    return UserProgress(
      userId: userId,
      languages: {},
      dailyStreak: 0,
      lastLoginDate: DateTime.now(),
      totalExperience: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'languages': languages.map(
        (lang, skills) => MapEntry(
          lang,
          skills.map(
            (skill, progress) => MapEntry(
              skill.index.toString(),
              progress.toJson(),
            ),
          ),
        ),
      ),
      'dailyStreak': dailyStreak,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'totalExperience': totalExperience,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final languagesJson = json['languages'] as Map<String, dynamic>;
    final languages = languagesJson.map(
      (lang, skillsJson) => MapEntry(
        lang,
        (skillsJson as Map<String, dynamic>).map(
          (skillIndex, progressJson) => MapEntry(
            UserProgressSkill.values[int.parse(skillIndex)],
            SkillProgress.fromJson(progressJson as Map<String, dynamic>),
          ),
        ),
      ),
    );

    return UserProgress(
      userId: json['userId'] as String,
      languages: languages,
      dailyStreak: json['dailyStreak'] as int,
      lastLoginDate: DateTime.parse(json['lastLoginDate'] as String),
      totalExperience: json['totalExperience'] as int,
    );
  }

  UserProgress copyWith({
    String? userId,
    Map<String, Map<UserProgressSkill, SkillProgress>>? languages,
    int? dailyStreak,
    DateTime? lastLoginDate,
    int? totalExperience,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      languages: languages ?? this.languages,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      totalExperience: totalExperience ?? this.totalExperience,
    );
  }
}
