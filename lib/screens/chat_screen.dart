import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:avatar_glow/avatar_glow.dart';
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

class _ChatScreenState extends State<ChatScreen> {
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
  Timer? _pauseTimer;
  static const Duration _pauseThreshold = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _currentMode = widget.initialMode;
    
    _chatService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
          if (messages.isEmpty && !_hasShownWelcome) {
            _showWelcomeMessage();
            _hasShownWelcome = true;
          }
        });
        _scrollToBottom();
      }
    });

    if (_currentMode == ChatMode.voice) {
      _requestMicrophonePermission();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    _speech.cancel();
    _pauseTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTyping = true;
      _textController.clear();
    });

    try {
      await _chatService.sendMessage(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _textSpeech = result.recognizedWords;
              _textController.text = _textSpeech;
              _isTyping = _textSpeech.isNotEmpty;
            });
            
            _pauseTimer?.cancel();
            if (_textSpeech.isNotEmpty) {
              _pauseTimer = Timer(_pauseThreshold, () {
                if (_isListening && _textSpeech.isNotEmpty) {
                  _handleSubmit();
                }
              });
            }
          },
          listenMode: ListenMode.dictation,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_textSpeech.isNotEmpty) {
        _handleSubmit();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat de Idiomas'),
        actions: [
          IconButton(
            icon: Icon(_currentMode == ChatMode.voice ? Icons.keyboard : Icons.mic),
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == ChatMode.voice 
                    ? ChatMode.text 
                    : ChatMode.voice;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                image: DecorationImage(
                  image: const AssetImage('assets/images/chat_pattern.png'),
                  opacity: 0.05,
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor,
                    BlendMode.lighten,
                  ),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AnimatedChatBubble(
                      message: message,
                      onPlayAudio: (text) async {
                        await _flutterTts.speak(text);
                      },
                      onQuickReplySelected: () {
                        if (message.quickReplies != null && 
                            message.quickReplies!.isNotEmpty) {
                          _textController.text = message.quickReplies![0];
                          _handleSubmit();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8),
              child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (text) {
                        setState(() => _isTyping = text.isNotEmpty);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (text) => _handleSubmit(),
                    ),
                  ),
                  if (_currentMode == ChatMode.voice)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: VoiceWaveIndicator(
                        isListening: _isListening,
                        size: 40,
                        glowColor: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _currentMode == ChatMode.voice ? _listen : _handleSubmit,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _currentMode == ChatMode.voice
                      ? _isListening ? Icons.stop : Icons.mic
                      : Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se requiere permiso del micrófono para el modo de voz'),
          ),
        );
      }
    }
  }
}
