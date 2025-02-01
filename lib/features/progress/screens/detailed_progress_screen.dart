import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/user_progress.dart';

class DetailedProgressScreen extends StatelessWidget {
  const DetailedProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progreso Detallado'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Habilidades'),
              Tab(text: 'Estadísticas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSkillsTab(context),
            _buildStatsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsTab(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, provider, child) {
        final language = 'english'; // TODO: Obtener del LanguageProvider
        final progress = provider.getLanguageProgress(language);

        if (progress == null) {
          return const Center(
            child: Text('No hay datos de progreso disponibles'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ...progress.entries.map(
              (entry) => _buildSkillCard(context, entry.key, entry.value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkillCard(
    BuildContext context,
    UserProgressSkill skill,
    SkillProgress progress,
  ) {
    final skillName = skill.toString().split('.').last;
    final IconData skillIcon;

    switch (skill) {
      case UserProgressSkill.vocabulary:
        skillIcon = Icons.book;
        break;
      case UserProgressSkill.grammar:
        skillIcon = Icons.rule;
        break;
      case UserProgressSkill.listening:
        skillIcon = Icons.hearing;
        break;
      case UserProgressSkill.reading:
        skillIcon = Icons.menu_book;
        break;
      case UserProgressSkill.writing:
        skillIcon = Icons.edit;
        break;
      case UserProgressSkill.speaking:
        skillIcon = Icons.mic;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(skillIcon, size: 24),
                const SizedBox(width: 12),
                Text(
                  skillName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    progress.currentLevel.code,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.experience / progress.experienceForNextLevel,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.experience} / ${progress.experienceForNextLevel} XP',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, provider, child) {
        final language = 'english'; // TODO: Obtener del LanguageProvider
        final level = provider.getCurrentLevel(language);
        final streak = provider.getDailyStreak();
        final totalXP = provider.getTotalExperience();

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildStatCard(
              context,
              'Nivel General',
              level?.code ?? 'Sin nivel',
              Icons.grade,
              Colors.amber,
            ),
            _buildStatCard(
              context,
              'Racha Diaria',
              '$streak días',
              Icons.local_fire_department,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              'Experiencia Total',
              '$totalXP XP',
              Icons.stars,
              Colors.purple,
            ),
            // TODO: Agregar más estadísticas
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
