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
            timestamp: DateTime.now().subtract(Duration(minutes: 5)),
            isSentByMe: false,
          ),
          ChatMessage(
            text: 'У меня вопрос по заказу #12345',
            timestamp: DateTime.now().subtract(Duration(minutes: 2)),
            isSentByMe: true,
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
      final conv = _conversations[index];
      _conversations[index] = ChatConversation(
        id: conv.id,
        name: conv.name,
        avatarUrl: conv.avatarUrl,
        messages: conv.messages,
        unreadCount: 0,
      );
      _updateUnreadStatus();
    }
  }

  void addMessage(String conversationId, ChatMessage message) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final conv = _conversations[index];
    _conversations[index] = ChatConversation(
      id: conv.id,
      name: conv.name,
      avatarUrl: conv.avatarUrl,
      unreadCount: conv.unreadCount,
      messages: [...conv.messages, message],
    );
    notifyListeners();
  }

  void createConversation(String userId) {
    final conv = ChatConversation(
      id: userId,
      name: 'Пользователь $userId',
      avatarUrl: 'https://cdn-icons-png.flaticon.com/512/1946/1946429.png',
      unreadCount: 0,
      messages: [],
    );

    _conversations.insert(0, conv);
    notifyListeners();
  }
}
