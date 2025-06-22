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
    final theme = Theme.of(context);
    
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
              if (!message.isUser) _buildBotAvatar(theme),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? theme.primaryColor
                        : theme.cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(message.isUser ? 20 : 4),
                      topRight: Radius.circular(message.isUser ? 4 : 20),
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                    ),
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
                          color: message.isUser 
                              ? Colors.white 
                              : theme.textTheme.bodyLarge?.color ?? Colors.black,
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
              if (message.isUser) _buildUserAvatar(theme),
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
                    color: theme.iconTheme.color?.withOpacity(0.6),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      children: message.quickReplies!.map((reply) {
        return ActionChip(
          label: Text(
            reply,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          backgroundColor: theme.chipTheme.backgroundColor ?? theme.cardColor,
          onPressed: onQuickReplySelected,
          avatar: Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: theme.iconTheme.color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBotAvatar(ThemeData theme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.smart_toy_outlined,
        size: 18,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildUserAvatar(ThemeData theme) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.person_outline,
        size: 18,
        color: theme.primaryColor,
      ),
    );
  }
}
