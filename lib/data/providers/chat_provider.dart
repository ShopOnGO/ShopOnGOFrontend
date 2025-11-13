import 'package:flutter/material.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  List<ChatConversation> _conversations = [];
  bool _hasUnreadMessages = true;

  List<ChatConversation> get conversations => _conversations;
  bool get hasUnreadMessages => _hasUnreadMessages;

  ChatProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _conversations = [
      ChatConversation(
        id: '1',
        name: 'Служба поддержки',
        avatarUrl: 'https://cdn-icons-png.flaticon.com/512/8832/8832309.png',
        unreadCount: 2,
        messages: [
          ChatMessage(
            text: 'Здравствуйте! Чем можем помочь?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isSentByMe: false,
          ),
          ChatMessage(
            text: 'У меня вопрос по заказу #12345',
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
            isSentByMe: true,
          ),
          ChatMessage(
            text: 'Минутку, сейчас все проверим.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            isSentByMe: false,
          ),
          ChatMessage(
            text: 'Ваш заказ уже в пути!',
            timestamp: DateTime.now(),
            isSentByMe: false,
          ),
        ],
      ),
      ChatConversation(
        id: '2',
        name: 'Менеджер Василий',
        avatarUrl: 'https://cdn-icons-png.flaticon.com/512/3048/3048122.png',
        unreadCount: 0,
        messages: [
          ChatMessage(
            text: 'Все в порядке, мы получили оплату.',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isSentByMe: false,
          ),
        ],
      ),
    ];
    _updateUnreadStatus();
  }

  void _updateUnreadStatus() {
    _hasUnreadMessages = _conversations.any((c) => c.unreadCount > 0);
    notifyListeners();
  }

  void markAsRead(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index] = ChatConversation(
        id: _conversations[index].id,
        name: _conversations[index].name,
        avatarUrl: _conversations[index].avatarUrl,
        messages: _conversations[index].messages,
        unreadCount: 0,
      );
      _updateUnreadStatus();
    }
  }
}
