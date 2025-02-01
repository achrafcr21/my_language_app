import 'package:flutter/foundation.dart';
import '../../progress/models/user_progress.dart';

enum QuestionType {
  vocabulary,
  grammar,
  listening,
  reading,
  writing,
  speaking,
}

class AssessmentQuestion {
  final String question;
  final List<String> options;
  final int correctOption;
  final QuestionType type;
  final UserProgressSkill skill;
  final ProficiencyLevel targetLevel;

  AssessmentQuestion({
    required this.question,
    required this.options,
    required this.correctOption,
    required this.type,
    required this.skill,
    required this.targetLevel,
  });

  bool checkAnswer(int selectedOption) {
    return selectedOption == correctOption;
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctOption': correctOption,
      'type': type.index,
      'skill': skill.index,
      'targetLevel': targetLevel.index,
    };
  }

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctOption: json['correctOption'] as int,
      type: QuestionType.values[json['type'] as int],
      skill: UserProgressSkill.values[json['skill'] as int],
      targetLevel: ProficiencyLevel.values[json['targetLevel'] as int],
    );
  }
}

class AssessmentResponse {
  final AssessmentQuestion question;
  final int selectedOption;
  final DateTime answeredAt;

  AssessmentResponse({
    required this.question,
    required this.selectedOption,
    required this.answeredAt,
  });

  bool get isCorrect => question.checkAnswer(selectedOption);

  Map<String, dynamic> toJson() {
    return {
      'question': question.toJson(),
      'selectedOption': selectedOption,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory AssessmentResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentResponse(
      question: AssessmentQuestion.fromJson(json['question'] as Map<String, dynamic>),
      selectedOption: json['selectedOption'] as int,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }
}

class AssessmentResult {
  final String language;
  final List<AssessmentResponse> responses;
  final DateTime startedAt;
  final DateTime completedAt;
  final Map<UserProgressSkill, ProficiencyLevel> skillLevels;

  AssessmentResult({
    required this.language,
    required this.responses,
    required this.startedAt,
    required this.completedAt,
    required this.skillLevels,
  });

  double get percentageCorrect {
    if (responses.isEmpty) return 0.0;
    final correctCount = responses.where((r) => r.isCorrect).length;
    return (correctCount / responses.length) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'responses': responses.map((r) => r.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'skillLevels': skillLevels.map(
        (skill, level) => MapEntry(skill.index.toString(), level.index),
      ),
    };
  }

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      language: json['language'] as String,
      responses: (json['responses'] as List)
          .map((r) => AssessmentResponse.fromJson(r as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      skillLevels: (json['skillLevels'] as Map<String, dynamic>).map(
        (skillIndex, levelIndex) => MapEntry(
          UserProgressSkill.values[int.parse(skillIndex)],
          ProficiencyLevel.values[levelIndex as int],
        ),
      ),
    );
  }

  static Map<UserProgressSkill, ProficiencyLevel> calculateSkillLevels(
    List<AssessmentResponse> responses,
  ) {
    final skillResponses = <UserProgressSkill, List<AssessmentResponse>>{};

    // Agrupar respuestas por habilidad
    for (var response in responses) {
      final skill = response.question.skill;
      skillResponses.putIfAbsent(skill, () => []).add(response);
    }

    // Calcular nivel para cada habilidad
    return skillResponses.map((skill, responses) {
      final correctCount = responses.where((r) => r.isCorrect).length;
      final percentage = (correctCount / responses.length) * 100;

      // Determinar nivel basado en porcentaje
      ProficiencyLevel level;
      if (percentage >= 90) level = ProficiencyLevel.c2;
      else if (percentage >= 80) level = ProficiencyLevel.c1;
      else if (percentage >= 70) level = ProficiencyLevel.b2;
      else if (percentage >= 60) level = ProficiencyLevel.b1;
      else if (percentage >= 50) level = ProficiencyLevel.a2;
      else level = ProficiencyLevel.a1;

      return MapEntry(skill, level);
    });
  }
}
