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
    final conversations = context.watch<ChatProvider>().conversations;
    final theme = Theme.of(context);

    const double itemHeight = 70.0;
    const double overlap = 12.0;
    const double borderRadius = 22.0;
    const double borderWidth = 4.0;

    final double totalHeight = conversations.isNotEmpty
        ? (conversations.length * (itemHeight - overlap)) + overlap
        : 0;

    final List<Widget> chatItems = [];
    Widget? selectedItem;

    for (int i = 0; i < conversations.length; i++) {
      final conversation = conversations[i];
      final isSelected = conversation.id == selectedConversationId;

      final positionedItem = Positioned(
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

      if (isSelected) {
        selectedItem = positionedItem;
      } else {
        chatItems.add(positionedItem);
      }
    }

    if (selectedItem != null) {
      chatItems.add(selectedItem);
    }

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        child: SizedBox(
          height: totalHeight,
          child: Stack(clipBehavior: Clip.none, children: chatItems),
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

    final Color backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.secondaryContainer;

    return GestureDetector(
      onTap: () => onConversationSelected(conversation),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: itemHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: theme.colorScheme.surface,
            width: borderWidth,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text(
                  conversation.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 20,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      conversation.messages.last.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSecondaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (conversation.unreadCount > 0) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isSelected
                      ? theme.cardColor
                      : colorScheme.primary,
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
