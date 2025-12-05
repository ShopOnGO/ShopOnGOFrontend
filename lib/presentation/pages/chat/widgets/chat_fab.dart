import 'package:flutter/material.dart';

enum MailboxState {
  closed,
  hasUnread,
}

class ChatFab extends StatelessWidget {
  final MailboxState state;
  const ChatFab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String emoji;
    switch (state) {
      case MailboxState.closed:
        emoji = '📪';
        break;
      case MailboxState.hasUnread:
        emoji = '📬';
        break;
    }

    return Text(emoji, style: const TextStyle(fontSize: 32));
  }
}