import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../assessment/screens/assessment_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedLanguage;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': '¡Bienvenido a IdeomAs!',
      'description':
          'Tu compañero personalizado para aprender idiomas de forma efectiva y divertida.',
      'icon': Icons.language,
    },
    {
      'title': 'Aprendizaje Personalizado',
      'description':
          'Adaptamos el contenido a tu nivel y estilo de aprendizaje para maximizar tus resultados.',
      'icon': Icons.book,
    },
    {
      'title': 'Práctica Interactiva',
      'description':
          'Mejora tus habilidades con ejercicios interactivos y conversaciones en tiempo real.',
      'icon': Icons.chat,
    },
    {
      'title': '¿Qué idioma quieres aprender?',
      'description': 'Selecciona el idioma con el que quieres empezar.',
      'icon': Icons.translate,
      'isLanguageSelection': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForPage(index),
                            size: 120,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            page['title'],
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page['description'],
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (page['isLanguageSelection'] == true) ...[
                            const SizedBox(height: 32),
                            _buildLanguageSelection(),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Anterior'),
                    )
                  else
                    const SizedBox.shrink(),
                  FilledButton(
                    onPressed: _currentPage == _pages.length - 1
                        ? (_selectedLanguage != null
                            ? () => _startAssessment(context)
                            : null)
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Comenzar'
                          : 'Siguiente',
                    ),
                  ),
                ],
              ),
            ),
            // Indicadores de página
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.language;
      case 1:
        return Icons.school;
      case 2:
        return Icons.trending_up;
      default:
        return Icons.translate;
    }
  }

  Widget _buildLanguageSelection() {
    final languages = [
      {'code': 'english', 'name': 'Inglés', 'flag': '🇬🇧'},
      {'code': 'french', 'name': 'Francés', 'flag': '🇫🇷'},
      {'code': 'german', 'name': 'Alemán', 'flag': '🇩🇪'},
      {'code': 'italian', 'name': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'portuguese', 'name': 'Portugués', 'flag': '🇵🇹'},
      {'code': 'chinese', 'name': 'Chino', 'flag': '🇨🇳'},
    ];

    return Column(
      children: languages.map((language) {
        final isSelected = _selectedLanguage == language['code'];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedLanguage = language['code'];
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    language['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    language['name']!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _startAssessment(BuildContext context) async {
    // Marcar el onboarding como completado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;

    // Navegar a la pantalla de evaluación
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AssessmentScreen(
          language: _selectedLanguage!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
