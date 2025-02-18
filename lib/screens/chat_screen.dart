import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/chat_service.dart';
import '../widgets/voice_wave_indicator.dart';
import '../widgets/animated_chat_bubble.dart';
import '../models/chat_message.dart';
import '../providers/language_provider.dart';

enum ChatMode {
  text,
  voice,
}

class ChatScreen extends StatefulWidget {
  final ChatMode initialMode;
  
  const ChatScreen({
    Key? key,
    this.initialMode = ChatMode.text,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ChatService _chatService = ChatService();
  
  bool _isListening = false;
  bool _isTyping = false;
  String _textSpeech = '';
  List<ChatMessage> _messages = [];
  late ChatMode _currentMode;
  bool _hasShownWelcome = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _currentMode = widget.initialMode;
    
    _chatService.messagesStream.listen((messages) {
      setState(() {
        _messages = messages;
        if (messages.isEmpty && !_hasShownWelcome) {
          _showWelcomeMessage();
          _hasShownWelcome = true;
        }
        _scrollToBottom();
      });
    });

    if (_currentMode == ChatMode.voice) {
      _requestMicrophonePermission();
    }
  }

  void _showWelcomeMessage() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final languageName = languageProvider.getLanguageName(languageProvider.targetLanguage ?? 'es');
    
    final welcomeMessage = ChatMessage(
      content: '''¡Bienvenido a tu clase de $languageName! 

Estoy aquí para ayudarte a practicar y mejorar tu nivel. Algunas cosas que podemos hacer:
- Mantener conversaciones en $languageName
- Practicar gramática y vocabulario
- Corregir tus errores de manera constructiva
- Realizar ejercicios específicos

¿En qué te gustaría enfocarte hoy?''',
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: [
        "Conversación libre",
        "Practicar gramática",
        "Vocabulario nuevo",
        "Ejercicios de pronunciación"
      ],
    );
    
    _chatService.addMessage(welcomeMessage);
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildAnimatedMessage(message, index);
                },
              ),
            ),
            if (_isTyping)
              Container(
                padding: const EdgeInsets.all(8),
                child: SpinKitThreeBounce(
                  color: theme.primaryColor,
                  size: 16,
                ),
              ).animate()
                .fade()
                .scale(),
            if (_currentMode == ChatMode.voice && _isListening)
              _buildVoiceModeIndicator(),
            _buildInputArea(theme),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.school,
              color: theme.primaryColor,
            ),
          ).animate()
            .fade(duration: 500.ms)
            .scale(delay: 200.ms),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu Profesor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Consumer<LanguageProvider>(
                builder: (context, provider, child) {
                  return Text(
                    'Nivel B2 • ${provider.getLanguageName(provider.targetLanguage ?? 'es')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptionsMenu(context),
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Limpiar conversación'),
            onTap: () {
              Navigator.pop(context);
              _chatService.clearHistory();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implementar pantalla de configuración
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceModeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VoiceWaveIndicator(
            isListening: _isListening,
            size: 150,
            glowColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            _textSpeech.isEmpty ? 'Escuchando...' : _textSpeech,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ).animate()
      .fade()
      .scale();
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _currentMode == ChatMode.voice ? Icons.keyboard : Icons.mic,
                  color: theme.primaryColor,
                ),
                onPressed: _toggleInputMode,
              ),
            ).animate()
              .scale()
              .fade(),
            const SizedBox(width: 8),
            if (_currentMode == ChatMode.text) ...[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: 5,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ).animate()
                .shimmer(
                  duration: 2000.ms,
                  color: Colors.white24,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMessage(ChatMessage message, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..forward(),
        curve: Curves.easeOutQuad,
      )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 300),
          )..forward(),
          curve: Curves.easeOut,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: AnimatedChatBubble(
            message: message,
            onQuickReplySelected: () {
              if (message.quickReplies != null && message.quickReplies!.isNotEmpty) {
                _handleSubmitted(message.quickReplies![0]);
              }
            },
            onPlayAudio: _speak,
          ),
        ),
      ),
    );
  }

  void _toggleInputMode() {
    setState(() {
      _currentMode = _currentMode == ChatMode.voice
          ? ChatMode.text
          : ChatMode.voice;
      if (_currentMode == ChatMode.voice) {
        _listen();
      } else {
        _speech.stop();
        _isListening = false;
      }
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    setState(() => _isTyping = true);
    
    await _chatService.sendMessage(text);
    
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      final hasPermission = await Permission.microphone.isGranted;
      if (!hasPermission) {
        await _requestMicrophonePermission();
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print('Speech error: $error');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _textSpeech = result.recognizedWords;
              if (result.finalResult) {
                _handleSubmitted(_textSpeech);
                _textSpeech = '';
              }
            });
          },
          localeId: 'es_ES',
        );
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      if (_textSpeech.isNotEmpty) {
        _handleSubmitted(_textSpeech);
        _textSpeech = '';
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    
    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permiso necesario'),
          content: const Text(
            'Para usar el chat por voz, necesitamos acceso al micrófono. '
            'Por favor, habilita el permiso en la configuración de la aplicación.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Abrir Ajustes'),
            ),
          ],
        ),
      );
      return;
    }

    if (!status.isGranted) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesita permiso del micrófono para esta función'),
        ),
      );
      return;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
