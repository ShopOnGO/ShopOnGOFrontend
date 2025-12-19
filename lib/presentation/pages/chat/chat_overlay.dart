import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/chat_provider.dart';
import 'widgets/chat_fab.dart';
import 'widgets/chat_window.dart';

class ChatOverlay extends StatelessWidget {
  final bool isChatOpen;
  final VoidCallback toggleChat;

  const ChatOverlay({
    super.key,
    required this.isChatOpen,
    required this.toggleChat,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.watch<ChatProvider>().hasUnreadMessages;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    const fabSize = 64.0;
    final chatWidth = size.width > 800 ? 700.0 : size.width * 0.9;
    final chatHeight = size.height > 600 ? 500.0 : size.height * 0.7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: isChatOpen ? chatWidth : fabSize,
      height: isChatOpen ? chatHeight : fabSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isChatOpen ? 16 : fabSize / 2),
        color: isChatOpen
            ? theme.scaffoldBackgroundColor
            : theme.colorScheme.secondaryContainer,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isChatOpen
            ? ChatWindow(onClose: toggleChat)
            : InkWell(
                onTap: toggleChat,
                borderRadius: BorderRadius.circular(fabSize / 2),
                child: Center(
                  child: ChatFab(
                    state: hasUnread
                        ? MailboxState.hasUnread
                        : MailboxState.closed,
                  ),
                ),
              ),
      ),
    );
  }
}
