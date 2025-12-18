import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/chat_conversation.dart';
import '../../../../data/providers/chat_provider.dart';

class ChatListView extends StatelessWidget {
  final Function(ChatConversation) onConversationSelected;
  final String? selectedConversationId;

  const ChatListView({
    super.key,
    required this.onConversationSelected,
    this.selectedConversationId,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conversations = chatProvider.conversations;
    final theme = Theme.of(context);

    if (conversations.isEmpty) {
      return const Center(child: Text("Нет активных чатов", style: TextStyle(fontSize: 12)));
    }

    const double itemHeight = 70.0;
    const double overlap = 12.0;
    const double borderRadius = 22.0;
    const double borderWidth = 4.0;

    final double totalHeight = (conversations.length * (itemHeight - overlap)) + overlap;

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none, 
            children: List.generate(conversations.length, (i) {
              final conversation = conversations[i];
              final isSelected = conversation.id == selectedConversationId;

              return Positioned(
                top: i * (itemHeight - overlap),
                left: 0,
                right: 0,
                child: _buildConversationItem(
                  context,
                  conversation,
                  isSelected,
                  itemHeight,
                  borderRadius,
                  borderWidth,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    ChatConversation conversation,
    bool isSelected,
    double itemHeight,
    double borderRadius,
    double borderWidth,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => onConversationSelected(conversation),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: itemHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: theme.colorScheme.surface, width: borderWidth),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                child: Text(conversation.name.isNotEmpty ? conversation.name[0] : "?"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                    ),
                    Text(
                      conversation.messages.isNotEmpty ? (conversation.messages.last.text ?? "Медиа") : "",
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}