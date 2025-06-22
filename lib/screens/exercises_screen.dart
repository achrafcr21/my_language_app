import 'package:flutter/material.dart';
import '../features/exercises/models/exercise_model.dart';
import '../features/exercises/screens/exercise_screen.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('Ejercicios'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categorías de ejercicios
                    Text(
                      'Categorías',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryCard(
                            context,
                            'Gramática',
                            Icons.auto_stories,
                            Colors.blue,
                            'grammar',
                          ),
                          _buildCategoryCard(
                            context,
                            'Vocabulario',
                            Icons.translate,
                            Colors.green,
                            'vocabulary',
                          ),
                          _buildCategoryCard(
                            context,
                            'Pronunciación',
                            Icons.record_voice_over,
                            Colors.orange,
                            'pronunciation',
                          ),
                          _buildCategoryCard(
                            context,
                            'Comprensión',
                            Icons.headphones,
                            Colors.purple,
                            'comprehension',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ejercicios recomendados
                    Text(
                      'Recomendados para ti',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildExerciseCard(
                      context,
                      'Práctica de Verbos',
                      'Presente Simple vs. Presente Continuo',
                      'Gramática',
                      'A2',
                      'grammar',
                    ),
                    const SizedBox(height: 12),
                    _buildExerciseCard(
                      context,
                      'Vocabulario de Viajes',
                      'Aprende palabras útiles para viajar',
                      'Vocabulario',
                      'B1',
                      'vocabulary',
                    ),
                    const SizedBox(height: 12),
                    _buildExerciseCard(
                      context,
                      'Pronunciación de "TH"',
                      'Mejora tu pronunciación del sonido "TH"',
                      'Pronunciación',
                      'A2',
                      'pronunciation',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _startRandomExercise(context);
        },
        icon: const Icon(Icons.shuffle),
        label: const Text('Ejercicio Aleatorio'),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String category,
  ) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: () => _navigateToCategory(context, category),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    String title,
    String description,
    String category,
    String level,
    String exerciseType,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          _startExercise(context, exerciseType, level);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    // Crear un ejercicio de ejemplo para la categoría
    final exercise = _createSampleExercise(category);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseScreen(exercise: exercise),
      ),
    );
  }

  void _startExercise(BuildContext context, String type, String level) {
    final exercise = _createSampleExercise(type, level: level);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseScreen(exercise: exercise),
      ),
    );
  }

  void _startRandomExercise(BuildContext context) {
    final types = ['grammar', 'vocabulary', 'pronunciation', 'comprehension'];
    final levels = ['A1', 'A2', 'B1', 'B2'];
    final randomType = types[DateTime.now().millisecond % types.length];
    final randomLevel = levels[DateTime.now().second % levels.length];
    
    _startExercise(context, randomType, randomLevel);
  }

  Exercise _createSampleExercise(String type, {String level = 'B1'}) {
    switch (type) {
      case 'grammar':
        return Exercise(
          id: DateTime.now().toString(),
          type: 'multiple-choice',
          question: '¿Cuál es la forma correcta del presente continuo?',
          options: ['I am studying', 'I study', 'I studied', 'I will study'],
          correctAnswer: 'I am studying',
          explanation: 'El presente continuo se forma con "to be" + verbo-ing',
          level: level,
          category: 'gramática',
          context: 'Práctica de tiempos verbales',
        );
      case 'vocabulary':
        return Exercise(
          id: DateTime.now().toString(),
          type: 'multiple-choice',
          question: '¿Cómo se dice "aeropuerto" en inglés?',
          options: ['Airport', 'Airplane', 'Station', 'Terminal'],
          correctAnswer: 'Airport',
          explanation: 'Airport es el lugar donde despegan y aterrizan los aviones',
          level: level,
          category: 'vocabulario',
          context: 'Vocabulario de viajes',
        );
      case 'pronunciation':
        return Exercise(
          id: DateTime.now().toString(),
          type: 'pronunciation',
          question: 'Pronuncia correctamente: "Think"',
          options: ['θɪŋk', 'tɪŋk', 'sɪŋk', 'fɪŋk'],
          correctAnswer: 'θɪŋk',
          explanation: 'La "th" en "think" se pronuncia como /θ/',
          level: level,
          category: 'pronunciación',
          context: 'Sonidos difíciles en inglés',
        );
      default:
        return Exercise(
          id: DateTime.now().toString(),
          type: 'multiple-choice',
          question: '¿Qué significa "understand"?',
          options: ['Entender', 'Escuchar', 'Hablar', 'Leer'],
          correctAnswer: 'Entender',
          explanation: 'Understand significa comprender o entender algo',
          level: level,
          category: 'comprensión',
          context: 'Comprensión de vocabulario básico',
        );
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar ejercicios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Por nivel'),
                leading: const Icon(Icons.school),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar filtro por nivel
                },
              ),
              ListTile(
                title: const Text('Por categoría'),
                leading: const Icon(Icons.category),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar filtro por categoría
                },
              ),
              ListTile(
                title: const Text('Por dificultad'),
                leading: const Icon(Icons.trending_up),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar filtro por dificultad
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
