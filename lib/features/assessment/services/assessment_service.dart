import '../models/assessment_model.dart';
import '../../progress/models/user_progress.dart';

class AssessmentService {
  Future<List<AssessmentQuestion>> generateAssessment(String targetLanguage) async {
    // En una implementación real, estas preguntas vendrían de una base de datos
    // Por ahora, generamos preguntas de ejemplo para cada idioma
    final questions = <AssessmentQuestion>[];
    
    // Vocabulario básico
    questions.addAll(_generateVocabularyQuestions(targetLanguage));
    
    // Gramática básica
    questions.addAll(_generateGrammarQuestions(targetLanguage));
    
    // Comprensión auditiva
    questions.addAll(_generateListeningQuestions(targetLanguage));
    
    // Comprensión lectora
    questions.addAll(_generateReadingQuestions(targetLanguage));
    
    return questions;
  }

  List<AssessmentQuestion> _generateVocabularyQuestions(String language) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> vocabularyQuestions = {
      'english': {
        'A1': [
          {
            'question': '¿Cómo se dice "Hola" en inglés?',
            'options': ['Hello', 'Goodbye', 'Thanks', 'Please'],
            'correctOption': 0,
          },
          {
            'question': '¿Cuál es la traducción de "Gracias"?',
            'options': ['Please', 'Sorry', 'Thank you', 'Welcome'],
            'correctOption': 2,
          },
        ],
        'A2': [
          {
            'question': 'Selecciona la traducción de "Estoy cansado"',
            'options': ['I am happy', 'I am tired', 'I am hungry', 'I am cold'],
            'correctOption': 1,
          },
        ],
      },
      'french': {
        'A1': [
          {
            'question': '¿Cómo se dice "Hola" en francés?',
            'options': ['Bonjour', 'Au revoir', 'Merci', 'S\'il vous plaît'],
            'correctOption': 0,
          },
          {
            'question': '¿Cuál es la traducción de "Gracias"?',
            'options': ['S\'il vous plaît', 'Pardon', 'Merci', 'Bienvenue'],
            'correctOption': 2,
          },
        ],
        'A2': [
          {
            'question': 'Selecciona la traducción de "Estoy cansado"',
            'options': ['Je suis content', 'Je suis fatigué', 'J\'ai faim', 'J\'ai froid'],
            'correctOption': 1,
          },
        ],
      },
      // Añadir más idiomas aquí
    };

    final questions = <AssessmentQuestion>[];
    final languageQuestions = vocabularyQuestions[language.toLowerCase()];
    
    if (languageQuestions != null) {
      for (var level in languageQuestions.entries) {
        for (var q in level.value) {
          questions.add(
            AssessmentQuestion(
              question: q['question'],
              options: List<String>.from(q['options']),
              correctOption: q['correctOption'],
              type: QuestionType.vocabulary,
              skill: UserProgressSkill.vocabulary,
              targetLevel: ProficiencyLevel.values.firstWhere(
                (e) => e.code == level.key,
              ),
            ),
          );
        }
      }
    }

    return questions;
  }

  List<AssessmentQuestion> _generateGrammarQuestions(String language) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> grammarQuestions = {
      'english': {
        'A1': [
          {
            'question': 'Selecciona la forma correcta del verbo "to be"',
            'options': ['I am', 'I is', 'I are', 'I be'],
            'correctOption': 0,
          },
          {
            'question': 'Completa: "She ___ a student"',
            'options': ['are', 'is', 'am', 'be'],
            'correctOption': 1,
          },
        ],
        'A2': [
          {
            'question': 'Elige el pasado simple correcto de "go"',
            'options': ['goed', 'went', 'gone', 'going'],
            'correctOption': 1,
          },
        ],
      },
      'french': {
        'A1': [
          {
            'question': 'Selecciona la forma correcta del verbo "être"',
            'options': ['Je suis', 'Je es', 'Je est', 'Je être'],
            'correctOption': 0,
          },
          {
            'question': 'Completa: "Elle ___ étudiante"',
            'options': ['es', 'est', 'suis', 'être'],
            'correctOption': 1,
          },
        ],
        'A2': [
          {
            'question': 'Elige el passé composé correcto de "aller"',
            'options': ['j\'ai allé', 'je suis allé', 'j\'ai été', 'je vais'],
            'correctOption': 1,
          },
        ],
      },
      // Añadir más idiomas aquí
    };

    final questions = <AssessmentQuestion>[];
    final languageQuestions = grammarQuestions[language.toLowerCase()];
    
    if (languageQuestions != null) {
      for (var level in languageQuestions.entries) {
        for (var q in level.value) {
          questions.add(
            AssessmentQuestion(
              question: q['question'],
              options: List<String>.from(q['options']),
              correctOption: q['correctOption'],
              type: QuestionType.grammar,
              skill: UserProgressSkill.grammar,
              targetLevel: ProficiencyLevel.values.firstWhere(
                (e) => e.code == level.key,
              ),
            ),
          );
        }
      }
    }

    return questions;
  }

  List<AssessmentQuestion> _generateListeningQuestions(String language) {
    // Por ahora retornamos una lista vacía ya que necesitaríamos archivos de audio
    return [];
  }

  List<AssessmentQuestion> _generateReadingQuestions(String language) {
    final Map<String, Map<String, List<Map<String, dynamic>>>> readingQuestions = {
      'english': {
        'A1': [
          {
            'question': 'Lee el texto y responde:\n\n"Hello! My name is John. I am a teacher."\n\n¿Cuál es la profesión de John?',
            'options': ['Student', 'Teacher', 'Doctor', 'Engineer'],
            'correctOption': 1,
          },
        ],
      },
      'french': {
        'A1': [
          {
            'question': 'Lee el texto y responde:\n\n"Bonjour! Je m\'appelle Marie. Je suis professeur."\n\n¿Cuál es la profesión de Marie?',
            'options': ['Estudiante', 'Profesora', 'Doctora', 'Ingeniera'],
            'correctOption': 1,
          },
        ],
      },
      // Añadir más idiomas aquí
    };

    final questions = <AssessmentQuestion>[];
    final languageQuestions = readingQuestions[language.toLowerCase()];
    
    if (languageQuestions != null) {
      for (var level in languageQuestions.entries) {
        for (var q in level.value) {
          questions.add(
            AssessmentQuestion(
              question: q['question'],
              options: List<String>.from(q['options']),
              correctOption: q['correctOption'],
              type: QuestionType.reading,
              skill: UserProgressSkill.reading,
              targetLevel: ProficiencyLevel.values.firstWhere(
                (e) => e.code == level.key,
              ),
            ),
          );
        }
      }
    }

    return questions;
  }
}
