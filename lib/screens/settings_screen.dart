import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../features/progress/models/user_progress.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Inicializar el provider de idioma si no está inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader('Idioma'),
              _buildLanguageSelector(languageProvider),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Nivel de Competencia'),
              _buildLevelSelector(languageProvider),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Preferencias'),
              _buildNotificationToggle(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Información'),
              _buildInfoSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(LanguageProvider languageProvider) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: const Text('Idioma de aprendizaje'),
        subtitle: Text(
          languageProvider.targetLanguage != null
              ? languageProvider.getLanguageName(languageProvider.targetLanguage!)
              : 'Seleccionar idioma',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showLanguageDialog(languageProvider),
      ),
    );
  }

  Widget _buildLevelSelector(LanguageProvider languageProvider) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.school),
        title: const Text('Nivel de competencia'),
        subtitle: Text(
          languageProvider.currentLevel?.code ?? 'Seleccionar nivel',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showLevelDialog(languageProvider),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications),
        title: const Text('Notificaciones'),
        subtitle: const Text('Recibir recordatorios de práctica'),
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
          // TODO: Implementar lógica de notificaciones
        },
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            subtitle: const Text('IdeomAs v1.0.0'),
            onTap: () => _showAboutDialog(),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda'),
            subtitle: const Text('Preguntas frecuentes y soporte'),
            onTap: () => _showHelpDialog(),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar idioma de aprendizaje'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languageProvider.supportedLanguages.length,
              itemBuilder: (context, index) {
                final language = languageProvider.supportedLanguages[index];
                final isSelected = languageProvider.targetLanguage == language['code'];
                
                return ListTile(
                  title: Text(language['name']!),
                  leading: Radio<String>(
                    value: language['code']!,
                    groupValue: languageProvider.targetLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        languageProvider.setTargetLanguage(value);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  selected: isSelected,
                  onTap: () {
                    languageProvider.setTargetLanguage(language['code']!);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showLevelDialog(LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar nivel de competencia'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ProficiencyLevel.values.length,
              itemBuilder: (context, index) {
                final level = ProficiencyLevel.values[index];
                final isSelected = languageProvider.currentLevel == level;
                
                return ListTile(
                  title: Text(level.code),
                  subtitle: Text(_getLevelDescription(level)),
                  leading: Radio<ProficiencyLevel>(
                    value: level,
                    groupValue: languageProvider.currentLevel,
                    onChanged: (value) {
                      if (value != null) {
                        languageProvider.setLevel(value);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  selected: isSelected,
                  onTap: () {
                    languageProvider.setLevel(level);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  String _getLevelDescription(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.a1:
        return 'Principiante - Palabras y frases básicas';
      case ProficiencyLevel.a2:
        return 'Elemental - Conversaciones simples';
      case ProficiencyLevel.b1:
        return 'Intermedio - Situaciones familiares';
      case ProficiencyLevel.b2:
        return 'Intermedio alto - Textos complejos';
      case ProficiencyLevel.c1:
        return 'Avanzado - Expresión fluida';
      case ProficiencyLevel.c2:
        return 'Maestría - Comprensión total';
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'IdeomAs',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 48),
      children: [
        const Text(
          'Una aplicación de aprendizaje de idiomas potenciada por inteligencia artificial.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Desarrollado con Flutter y ChatGPT para ofrecer una experiencia de aprendizaje personalizada.',
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ayuda'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Cómo usar IdeomAs?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('1. Selecciona tu idioma de aprendizaje'),
                Text('2. Configura tu nivel de competencia'),
                Text('3. Comienza a chatear con la IA'),
                Text('4. Practica con ejercicios interactivos'),
                SizedBox(height: 16),
                Text(
                  'Funciones principales:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Chat con IA para práctica conversacional'),
                Text('• Reconocimiento de voz'),
                Text('• Síntesis de voz'),
                Text('• Seguimiento de progreso'),
                Text('• Ejercicios adaptativos'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
