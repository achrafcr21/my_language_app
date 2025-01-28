import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Idioma de aprendizaje'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Implementar selección de idioma
            },
          ),
          ListTile(
            title: const Text('Nivel de dificultad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Implementar selección de nivel
            },
          ),
          ListTile(
            title: const Text('Notificaciones'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Implementar toggle de notificaciones
              },
            ),
          ),
        ],
      ),
    );
  }
}
