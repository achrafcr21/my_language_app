import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/language_analysis_service.dart';
import '../providers/language_provider.dart';
import '../features/exercises/models/exercise_model.dart';
import '../features/exercises/screens/exercise_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late ChatService _chatService;
  final LanguageAnalysisService _languageAnalysis = LanguageAnalysisService();
  LanguageLevel? _currentLevel;
  List<String> _suggestedTopics = [];

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _loadSuggestedTopics();
  }

  Future<void> _loadSuggestedTopics() async {
    _suggestedTopics = _languageAnalysis.getSuggestedTopics();
    setState(() {});
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Analizar el nivel del usuario
      _currentLevel = await _languageAnalysis.analyzeUserInput(message);
      
      final targetLanguage = context.read<LanguageProvider>().targetLanguage;
      final response = await _chatService.sendMessage(message, targetLanguage);
      
      setState(() {
        _messages.add(response);
        _isLoading = false;
        _suggestedTopics = _languageAnalysis.getSuggestedTopics();
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(
          content: 'Lo siento, ha ocurrido un error. Por favor, intenta de nuevo.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showLevelInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nivel de idioma'),
        content: Text('Tu nivel de idioma es: ${_currentLevel?.name ?? 'Desconocido'}'),
      ),
    );
  }

  void _showSuggestedTopics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temas sugeridos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _suggestedTopics.map((topic) => ListTile(title: Text(topic))).toList(),
        ),
      ),
    );
  }

  void _showExercise() {
    if (_messages.isEmpty) return;
    
    final exercise = Exercise.fromContext(
      context: _messages.last.content,
      level: _currentLevel?.level ?? 'A1',
      type: 'multiple-choice',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ExerciseScreen(
          exercise: exercise,
          onComplete: (bool wasCorrect) {
            if (wasCorrect) {
              _messages.add(ChatMessage(
                content: '¡Excelente! Has completado el ejercicio correctamente. ¿Te gustaría practicar algo más?',
                isUser: false,
                timestamp: DateTime.now(),
              ));
            } else {
              _messages.add(ChatMessage(
                content: 'No te preocupes, es parte del aprendizaje. ¿Quieres que repasemos este tema?',
                isUser: false,
                timestamp: DateTime.now(),
              ));
            }
            setState(() {});
            _scrollToBottom();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat de Idiomas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: _showExercise,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showLevelInfo,
          ),
          IconButton(
            icon: const Icon(Icons.topic),
            onPressed: _showSuggestedTopics,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _chatService.clearConversation();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              print('Botón de idioma presionado'); // Log para depuración
              final languageProvider = context.read<LanguageProvider>();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Seleccionar idioma'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: languageProvider.supportedLanguages
                        .map((lang) => ListTile(
                              title: Text(lang['name']!),
                              onTap: () {
                                print('Idioma seleccionado: ${lang['code']}'); // Log para depuración
                                languageProvider.setTargetLanguage(lang['code']!);
                                Navigator.pop(context);
                              },
                              trailing: languageProvider.targetLanguage == lang['code']
                                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message)
                    .animate()
                    .fade()
                    .scale(delay: 200.ms);
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Escribiendo'),
                  const SizedBox(width: 8),
                  ...List.generate(3, (index) {
                    return Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).scale(
                      duration: 600.ms,
                      delay: (index * 200).ms,
                      curve: Curves.easeInOut,
                    );
                  }),
                ],
              ),
            ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            elevation: 0,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isUser
                      ? Colors.white
                      : theme.colorScheme.onSecondaryContainer,
                ),
                code: TextStyle(
                  backgroundColor: isUser
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.tertiaryContainer,
                  color: isUser
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
