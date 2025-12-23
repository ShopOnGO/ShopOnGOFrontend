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
    final bool isMobile = size.width < 650;

    const fabSize = 64.0;
    
    final double chatWidth = isMobile 
        ? (isChatOpen ? size.width * 0.95 : fabSize)
        : (isChatOpen ? (size.width > 800 ? 700.0 : size.width * 0.9) : fabSize);
        
    final double chatHeight = isMobile 
        ? (isChatOpen ? size.height * 0.62 : fabSize)
        : (isChatOpen ? (size.height > 600 ? 500.0 : size.height * 0.7) : fabSize);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: chatWidth,
      height: chatHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isChatOpen ? 20 : fabSize / 2),
        color: isChatOpen
            ? theme.scaffoldBackgroundColor
            : theme.colorScheme.secondaryContainer,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.3),
            blurRadius: 15,
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