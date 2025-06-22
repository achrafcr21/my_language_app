import 'package:flutter/material.dart';

enum MessageType {
  text,
  audio,
  quickReplies,
  translation,
  correction
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final List<String>? quickReplies;
  final String? translation;
  final Map<String, String>? corrections;
  final String? audioUrl;
  final bool hasError;
  final String? originalText;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.quickReplies,
    this.translation,
    this.corrections,
    this.audioUrl,
    this.hasError = false,
    this.originalText,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      quickReplies: (json['quickReplies'] as List<dynamic>?)?.cast<String>(),
      translation: json['translation'] as String?,
      corrections: (json['corrections'] as Map<String, dynamic>?)?.cast<String, String>(),
      audioUrl: json['audioUrl'] as String?,
      hasError: json['hasError'] as bool? ?? false,
      originalText: json['originalText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      if (quickReplies != null && quickReplies!.isNotEmpty) 'quickReplies': quickReplies,
      if (translation != null) 'translation': translation,
      if (corrections != null && corrections!.isNotEmpty) 'corrections': corrections,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (hasError) 'hasError': hasError,
      if (originalText != null) 'originalText': originalText,
    };
  }

  ChatMessage copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    List<String>? quickReplies,
    String? translation,
    Map<String, String>? corrections,
    String? audioUrl,
    bool? hasError,
    String? originalText,
  }) {
    return ChatMessage(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      quickReplies: quickReplies ?? this.quickReplies,
      translation: translation ?? this.translation,
      corrections: corrections ?? this.corrections,
      audioUrl: audioUrl ?? this.audioUrl,
      hasError: hasError ?? this.hasError,
      originalText: originalText ?? this.originalText,
    );
  }

  @override
  String toString() => 'ChatMessage(content: $content, isUser: $isUser, type: $type)';
}
