import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/gradient_button.dart';
import '../widgets/voice_wave_indicator.dart';
import 'chat_screen.dart';

class ChatWelcomeScreen extends StatelessWidget {
  const ChatWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              VoiceWaveIndicator(
                isListening: false,
                color: Theme.of(context).primaryColor,
                size: 120,
              )
                .animate()
                .scale(delay: 300.ms)
                .fadeIn(),
              const SizedBox(height: 40),
              Text(
                '¿Cómo prefieres practicar?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
                .animate()
                .fadeIn(delay: 500.ms)
                .moveY(begin: 20, end: 0),
              const SizedBox(height: 12),
              Text(
                'Elige tu modo de conversación preferido',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              )
                .animate()
                .fadeIn(delay: 700.ms)
                .moveY(begin: 20, end: 0),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    GradientButton(
                      text: 'Conversación por Voz',
                      icon: Icons.mic,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChatScreen(initialMode: ChatMode.voice),
                          ),
                        );
                      },
                    )
                      .animate()
                      .fadeIn(delay: 900.ms)
                      .moveY(begin: 20, end: 0),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Chat por Texto',
                      icon: Icons.chat_bubble_outline,
                      isVariant: true,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChatScreen(initialMode: ChatMode.text),
                          ),
                        );
                      },
                    )
                      .animate()
                      .fadeIn(delay: 1100.ms)
                      .moveY(begin: 20, end: 0),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Puedes cambiar el modo en cualquier momento durante la conversación',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                )
                  .animate()
                  .fadeIn(delay: 1300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
