import 'chat_message.dart';

class ChatConversation {
  final String id;
  final String name;
  final String avatarUrl;
  final List<ChatMessage> messages;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.messages,
    this.unreadCount = 0,
  });
}