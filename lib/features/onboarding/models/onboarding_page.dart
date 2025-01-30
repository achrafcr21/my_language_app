class OnboardingPage {
  final String title;
  final String description;
  final String animation;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.animation,
  });

  static List<OnboardingPage> pages = [
    const OnboardingPage(
      title: '¡Bienvenido a tu viaje lingüístico!',
      description: 'Aprende idiomas de forma natural y divertida con conversaciones personalizadas.',
      animation: 'assets/animations/welcome.json',
    ),
    const OnboardingPage(
      title: 'Conversaciones Inteligentes',
      description: 'Chatea con un tutor de IA que se adapta a tu nivel y corrige tus errores en tiempo real.',
      animation: 'assets/animations/chat.json',
    ),
    const OnboardingPage(
      title: 'Aprende con Videos',
      description: 'Practica con videos generados por IA que simulan situaciones reales en tu idioma objetivo.',
      animation: 'assets/animations/video.json',
    ),
  ];
}
