import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chat_message.dart';

class AnimatedChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onQuickReplySelected;
  final Function(String) onPlayAudio;

  const AnimatedChatBubble({
    Key? key,
    required this.message,
    this.onQuickReplySelected,
    required this.onPlayAudio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) _buildBotAvatar(),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      if (!message.isUser && message.quickReplies != null)
                        const SizedBox(height: 8),
                      if (!message.isUser && message.quickReplies != null)
                        _buildQuickReplies(context),
                    ],
                  ),
                ).animate()
                    .fade(duration: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8), duration: 300.ms),
              ),
              if (message.isUser) _buildUserAvatar(),
            ],
          ),
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 48.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    onPressed: () => onPlayAudio(message.content),
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: message.quickReplies!.map((reply) {
        return Chip(
          label: Text(
            reply,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          backgroundColor: Theme.of(context).cardColor.withOpacity(0.3),
          onDeleted: onQuickReplySelected,
          deleteIcon: const Icon(Icons.arrow_forward_ios, size: 12),
        );
      }).toList(),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.purple[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.school,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}
