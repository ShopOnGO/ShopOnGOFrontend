import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/chat_conversation.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../data/providers/chat_provider.dart';
import 'chat_message_bubble.dart';

class ChatDetailView extends StatelessWidget {
  final ChatConversation conversation;

  const ChatDetailView({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            reverse: true,
            itemCount: conversation.messages.length,
            itemBuilder: (context, index) {
              final list = conversation.messages.reversed.toList();
              return ChatMessageBubble(message: list[index]);
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(8).copyWith(bottom: 12),
          color: Colors.transparent,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () {
                  context.read<ChatProvider>().addMessage(
                    conversation.id,
                    ChatMessage(
                      imageUrl:
                          "https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/300",
                      timestamp: DateTime.now(),
                      isSentByMe: true,
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Введите сообщение...',
                    filled: true,
                    fillColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  minimumSize: const Size(
                    48,
                    48,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
