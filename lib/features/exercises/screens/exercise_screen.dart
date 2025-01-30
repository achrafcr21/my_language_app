import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import 'package:lottie/lottie.dart';

class ExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  final Function(bool) onComplete;

  const ExerciseScreen({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? selectedAnswer;
  bool? isCorrect;
  bool showExplanation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicio de ${widget.exercise.category}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nivel y tipo de ejercicio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text('Nivel ${widget.exercise.level}'),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  Chip(
                    label: Text(widget.exercise.type),
                    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pregunta
              Text(
                widget.exercise.question,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Opciones
              ...widget.exercise.options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: isCorrect == null ? () => _checkAnswer(option) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getOptionColor(option),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      option,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              )).toList(),

              if (isCorrect != null) ...[
                const SizedBox(height: 24),
                // Animación de resultado
                Center(
                  child: Lottie.asset(
                    isCorrect! 
                      ? 'assets/animations/success.json'
                      : 'assets/animations/error.json',
                    width: 150,
                    height: 150,
                    repeat: false,
                  ),
                ),
                const SizedBox(height: 16),
                // Explicación
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Explicación:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(widget.exercise.explanation),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    widget.onComplete(isCorrect!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Continuar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == widget.exercise.correctAnswer;
      showExplanation = true;
    });
  }

  Color? _getOptionColor(String option) {
    if (selectedAnswer == null) return null;
    if (option == widget.exercise.correctAnswer) {
      return Colors.green.withOpacity(0.2);
    }
    if (option == selectedAnswer && !isCorrect!) {
      return Colors.red.withOpacity(0.2);
    }
    return null;
  }
}
