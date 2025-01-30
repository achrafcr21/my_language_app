class Exercise {
  final String id;
  final String type; // 'fill-blank', 'multiple-choice', 'translation', 'pronunciation'
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String level; // A1, A2, B1, B2, C1, C2
  final String category; // gramática, vocabulario, comprensión, etc.
  final String context; // El contexto de la conversación donde surgió

  Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.level,
    required this.category,
    required this.context,
  });

  factory Exercise.fromContext({
    required String context,
    required String level,
    required String type,
  }) {
    // Aquí implementaremos la lógica para generar ejercicios basados en el contexto
    // Por ahora, retornamos un ejercicio de ejemplo
    return Exercise(
      id: DateTime.now().toString(),
      type: type,
      question: '¿Cómo se dice "I am learning" en español?',
      options: ['Estoy aprendiendo', 'Yo aprendo', 'He aprendido', 'Voy a aprender'],
      correctAnswer: 'Estoy aprendiendo',
      explanation: 'Usamos "estar + gerundio" para expresar acciones en progreso.',
      level: level,
      category: 'gramática',
      context: context,
    );
  }
}
