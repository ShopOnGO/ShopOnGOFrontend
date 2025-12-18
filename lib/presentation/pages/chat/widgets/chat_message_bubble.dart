import 'package:flutter/material.dart';
import '../../../../data/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMyMessage = message.isSentByMe;
    final isSystem = message.type == "system";

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text ?? '',
              style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isMyMessage 
                ? theme.colorScheme.primary 
                : theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMyMessage ? 16 : 0),
              bottomRight: Radius.circular(isMyMessage ? 0 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: message.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(message.imageUrl!, width: 200, fit: BoxFit.contain),
                )
              : Text(
                  message.text ?? '',
                  style: TextStyle(
                    color: isMyMessage 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSecondaryContainer,
                  ),
                ),
        ),
      ],
    );
  }
}