import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/chat_conversation.dart';
import '../../../../data/providers/chat_provider.dart';
import 'chat_detail_view.dart';
import 'chat_fab.dart';
import 'chat_list_view.dart';

class ChatWindow extends StatefulWidget {
  final VoidCallback onClose;
  const ChatWindow({super.key, required this.onClose});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  ChatConversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    final conversations = context.read<ChatProvider>().conversations;
    if (conversations.isNotEmpty) {
      _selectedConversation = conversations.first;
    }
  }

  void _onConversationSelected(ChatConversation conversation) {
    setState(() {
      _selectedConversation = conversation;
    });
    context.read<ChatProvider>().markAsRead(conversation.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = context.watch<ChatProvider>().hasUnreadMessages;

    final Color panelColor = theme.colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    const double borderWidth = 6.0;
    const double borderRadius = 22.0;

    return Row(
      children: [
        Container(
          width: 250,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.15),
                blurRadius: 6.0,
                spreadRadius: 1.0,
                offset: const Offset(2.0, 0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: theme.colorScheme.surface,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.5,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: widget.onClose,
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ChatFab(
                              state: hasUnread
                                  ? MailboxState.hasUnread
                                  : MailboxState.closed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Чаты',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ChatListView(
                    onConversationSelected: _onConversationSelected,
                    selectedConversationId: _selectedConversation?.id,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(borderWidth),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Card(
                margin: EdgeInsets.zero,
                child: _selectedConversation != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  child: Text(
                                    _selectedConversation!.name.substring(0, 1),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedConversation!.name,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ChatDetailView(
                              conversation: _selectedConversation!,
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text('Выберите чат для начала общения'),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
