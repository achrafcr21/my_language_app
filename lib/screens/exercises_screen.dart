import 'package:flutter/material.dart';
import '../features/exercises/models/exercise_model.dart';

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
                    // TODO: Implementar filtros
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
                          ),
                          _buildCategoryCard(
                            context,
                            'Vocabulario',
                            Icons.translate,
                            Colors.green,
                          ),
                          _buildCategoryCard(
                            context,
                            'Pronunciación',
                            Icons.record_voice_over,
                            Colors.orange,
                          ),
                          _buildCategoryCard(
                            context,
                            'Comprensión',
                            Icons.headphones,
                            Colors.purple,
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
                    ),
                    const SizedBox(height: 12),
                    _buildExerciseCard(
                      context,
                      'Vocabulario de Viajes',
                      'Aprende palabras útiles para viajar',
                      'Vocabulario',
                      'B1',
                    ),
                    const SizedBox(height: 12),
                    _buildExerciseCard(
                      context,
                      'Pronunciación de "TH"',
                      'Mejora tu pronunciación del sonido "TH"',
                      'Pronunciación',
                      'A2',
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
          // TODO: Implementar ejercicio aleatorio
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
  ) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      color: color.withOpacity(0.1),
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
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    String title,
    String description,
    String category,
    String level,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navegar al ejercicio
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
}
