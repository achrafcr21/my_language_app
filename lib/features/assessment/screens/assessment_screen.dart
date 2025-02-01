import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assessment_model.dart';
import '../services/assessment_service.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/models/user_progress.dart';

class AssessmentScreen extends StatefulWidget {
  final String language;

  const AssessmentScreen({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final AssessmentService _assessmentService = AssessmentService();
  List<AssessmentQuestion> _questions = [];
  List<AssessmentResponse> _responses = [];
  AssessmentResult? _result;
  int _currentQuestionIndex = 0;
  DateTime? _startTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _assessmentService.generateAssessment(widget.language);
      setState(() {
        _questions = questions;
        _startTime = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las preguntas: $e')),
        );
      }
    }
  }

  void _submitAnswer(int selectedOption) {
    if (_currentQuestionIndex >= _questions.length) return;

    final response = AssessmentResponse(
      question: _questions[_currentQuestionIndex],
      selectedOption: selectedOption,
      answeredAt: DateTime.now(),
    );

    setState(() {
      _responses.add(response);
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _finishAssessment();
      }
    });
  }

  Future<void> _finishAssessment() async {
    final now = DateTime.now();
    final skillLevels = AssessmentResult.calculateSkillLevels(_responses);

    setState(() {
      _result = AssessmentResult(
        language: widget.language,
        responses: _responses,
        startedAt: _startTime!,
        completedAt: now,
        skillLevels: skillLevels,
      );
    });

    // Actualizar el progreso del usuario
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    await progressProvider.updateSkillLevels(widget.language, skillLevels);
  }

  Widget _buildQuestionScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text('No hay preguntas disponibles para este idioma.'),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (question.type == QuestionType.listening)
          const Icon(Icons.volume_up, size: 48),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ...List.generate(
                  question.options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () => _submitAnswer(index),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        question.options[index],
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    if (_result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            '¡Evaluación Completada!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultados:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Porcentaje de respuestas correctas: ${_result!.percentageCorrect.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Niveles por habilidad:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...(_result!.skillLevels.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toString().split('.').last,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
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
                              entry.value.code,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluación de ${widget.language}'),
      ),
      body: SafeArea(
        child: _result == null ? _buildQuestionScreen() : _buildResultScreen(),
      ),
    );
  }
}
