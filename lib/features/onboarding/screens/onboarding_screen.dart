import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../models/onboarding_page.dart';
import '../../home/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == OnboardingPage.pages.length - 1;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingPage.pages.length,
                itemBuilder: (context, index) {
                  final page = OnboardingPage.pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) => Lottie.asset(
                            page.animation,
                            height: 300,
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 600),
                          opacity: 1.0,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 400),
                            offset: const Offset(0, 0),
                            child: Text(
                              page.title,
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 600),
                          opacity: 1.0,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 400),
                            offset: const Offset(0, 0),
                            child: Text(
                              page.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: 1.0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 400),
                  offset: const Offset(0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Saltar',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // Dots indicator
                      Row(
                        children: List.generate(
                          OnboardingPage.pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? theme.colorScheme.primary
                                  : AppColors.divider,
                            ),
                          ),
                        ),
                      ),
                      // Next/Start button
                      ElevatedButton(
                        onPressed: _isLastPage
                            ? _completeOnboarding
                            : () {
                                _pageController.nextPage(
                                  duration: 400.ms,
                                  curve: Curves.easeInOut,
                                );
                              },
                        child: Text(_isLastPage ? '¡Empezar!' : 'Siguiente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
