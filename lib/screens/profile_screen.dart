import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('Mi Perfil'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // TODO: Implementar configuración
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
                    // Perfil del usuario
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Usuario',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nivel: B1 - Intermedio',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Estadísticas
                    Text(
                      'Estadísticas',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          context,
                          '30',
                          'Días seguidos',
                          Icons.calendar_today,
                        ),
                        _buildStatCard(
                          context,
                          '150',
                          'Ejercicios',
                          Icons.school,
                        ),
                        _buildStatCard(
                          context,
                          '500',
                          'Palabras',
                          Icons.translate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Logros
                    Text(
                      'Logros',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildAchievementCard(
                      context,
                      'Estudiante Dedicado',
                      '30 días seguidos de práctica',
                      Icons.star,
                      Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildAchievementCard(
                      context,
                      'Maestro del Vocabulario',
                      'Aprendiste 500 palabras nuevas',
                      Icons.book,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildAchievementCard(
                      context,
                      'Conversador Experto',
                      '100 conversaciones completadas',
                      Icons.chat,
                      Colors.green,
                    ),
                    const SizedBox(height: 32),

                    // Idiomas
                    Text(
                      'Mis Idiomas',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageCard(
                      context,
                      'Inglés',
                      'B1 - Intermedio',
                      0.6,
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageCard(
                      context,
                      'Francés',
                      'A2 - Básico',
                      0.3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    String language,
    String level,
    double progress,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  level,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
