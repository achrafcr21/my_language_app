import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class VoiceWaveIndicator extends StatelessWidget {
  final bool isListening;
  final double size;
  final Color glowColor;
  final Duration duration;

  const VoiceWaveIndicator({
    Key? key,
    required this.isListening,
    this.size = 100.0,
    this.glowColor = const Color(0xFF7C4DFF),
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      animate: isListening,
      glowColor: glowColor,
      endRadius: size / 2,
      duration: duration,
      repeatPauseDuration: const Duration(milliseconds: 100),
      repeat: true,
      child: Container(
        width: size * 0.6,
        height: size * 0.6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              glowColor.withOpacity(0.5),
              glowColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: size * 0.3,
        ),
      ),
    );
  }
}
