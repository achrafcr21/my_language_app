import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/progress/providers/progress_provider.dart';
import '../features/progress/models/user_progress.dart';
import '../features/assessment/screens/assessment_screen.dart';
import '../features/progress/screens/detailed_progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IdeomAs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<ProgressProvider>(context, listen: false)
            .initializeProgress('user_1'), // TODO: Usar ID de usuario real
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<ProgressProvider>(
            builder: (context, progressProvider, child) {
              final selectedLanguage = 'english'; // TODO: Obtener del LanguageProvider
              final progress = progressProvider.getLanguageProgress(selectedLanguage);
              final currentLevel = progressProvider.getCurrentLevel(selectedLanguage);
              final streak = progressProvider.getDailyStreak();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, currentLevel, streak),
                    if (progress != null) ...[
                      _buildSkillsProgress(context, progress),
                      _buildActionButtons(context, selectedLanguage),
                    ] else
                      _buildWelcomeCard(context, selectedLanguage),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProficiencyLevel? level, int streak) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel General',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level?.code ?? 'Sin nivel',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  Text(
                    '$streak días',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsProgress(
    BuildContext context,
    Map<UserProgressSkill, SkillProgress> progress,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso por Habilidad',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailedProgressScreen(),
                    ),
                  );
                },
                child: const Text('Ver Detalles'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...progress.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.toString().split('.').last,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        entry.value.currentLevel.code,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: entry.value.experience / entry.value.experienceForNextLevel,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String language) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentScreen(language: language),
                ),
              );
            },
            icon: const Icon(Icons.assessment),
            label: const Text('Realizar Evaluación'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar práctica
            },
            icon: const Icon(Icons.school),
            label: const Text('Comenzar Práctica'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String language) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¡Bienvenido a IdeomAs!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Para comenzar, realiza una evaluación de nivel para medir tus habilidades actuales.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssessmentScreen(language: language),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Comenzar Evaluación'),
            ),
          ],
        ),
      ),
    );
  }
}
