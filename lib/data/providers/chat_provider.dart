import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../config/api_config.dart';

class ChatProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isManagerMode = false;
  int? _currentUserId;
  int? _activeTargetUserId; 
  List<int> _waitingUsers = [];

  final String _managerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjc3ODc5MzkxNzcsInJvbGUiOiJtYW5hZ2VyIiwidXNlcl9pZCI6Mn0.NqNyE0yIyyumue9DWJXHmmUfjbWo5xN7zmnXvr3k_vU";

  List<ChatMessage> _messages = [];
  bool _hasUnreadMessages = false;

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  bool get isManagerMode => _isManagerMode;
  bool get hasUnreadMessages => _hasUnreadMessages;
  List<int> get waitingUsers => _waitingUsers;
  int? get activeTargetUserId => _activeTargetUserId;

  List<ChatConversation> get conversations {
    if (_messages.isEmpty) return [];
    return [
      ChatConversation(
        id: "main",
        name: _isManagerMode 
          ? (_activeTargetUserId != null ? "Чат с пользователем $_activeTargetUserId" : "Ожидание выбора") 
          : "Поддержка Tailornado",
        avatarUrl: "",
        messages: _messages,
        unreadCount: _hasUnreadMessages ? 1 : 0,
      )
    ];
  }

  void setManagerMode(bool value, String? userToken) {
    print(">>> [CHAT] Mode Switch: Manager = $value");
    _isManagerMode = value;
    // Полностью сбрасываем состояние перед переключением
    _waitingUsers = [];
    _activeTargetUserId = null;
    _messages.clear();
    
    disconnect();
    connect(value ? _managerToken : userToken);
  }

  void connect(String? token) {
    if (token == null || _isConnected) return;

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _currentUserId = int.tryParse(decodedToken['user_id'].toString());
    } catch (e) {
      print(">>> [CHAT] JWT Decode Error: $e");
    }

    final wsUrl = "${ApiConfig.wsChatUrl}?token=$token";
    print(">>> [CHAT] Connecting to: $wsUrl");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
        (data) => _onMessageReceived(data),
        onError: (err) { 
          print(">>> [CHAT] WS Error: $err");
          _isConnected = false; 
          notifyListeners(); 
        },
        onDone: () { 
          print(">>> [CHAT] WS Connection Closed");
          _isConnected = false; 
          notifyListeners(); 
        },
      );
      
      // СРАЗУ запрашиваем список при входе менеджера
      if (_isManagerMode) {
        print(">>> [CHAT] Manager connected, requesting initial list...");
        sendCommand("list");
      }
    } catch (e) {
      print(">>> [CHAT] Connection Exception: $e");
      _isConnected = false;
      notifyListeners();
    }
  }

  void _onMessageReceived(dynamic data) {
    print(">>> [CHAT] Raw Data: $data");
    try {
      final json = jsonDecode(data);
      
      // Если сервер прислал список пользователей в payload
      if (json['payload'] != null && json['payload'] is List) {
        _waitingUsers = List<int>.from(json['payload']);
        print(">>> [CHAT] Waiting Users List Updated from Server: $_waitingUsers");
        notifyListeners();
      }

      final message = ChatMessage.fromServerJson(json, _currentUserId ?? 0);
      _messages.add(message);
      _hasUnreadMessages = true;
      notifyListeners();
    } catch (e) {
      print(">>> [CHAT] Parse Error: $e");
    }
  }

  void sendCommand(String cmd, {int? targetId}) {
    if (!_isConnected) return;
    
    if (cmd == "take" && targetId != null) {
      _messages.clear();
      _activeTargetUserId = targetId;
      print(">>> [CHAT] Taking user $targetId. Messages cleared.");
    } else if (cmd == "close") {
      print(">>> [CHAT] Closing session with $_activeTargetUserId");
      _activeTargetUserId = null;
    }

    final payload = {
      "command": cmd,
      if (targetId != null) "user_id": targetId,
    };
    
    _channel!.sink.add(jsonEncode(payload));
    notifyListeners();
  }

  Future<void> sendMessage({required String text}) async {
    if (!_isConnected || _channel == null) return;

    final localMsg = ChatMessage(
      text: text,
      timestamp: DateTime.now(),
      isSentByMe: true,
      type: "text",
      fromId: _currentUserId,
    );
    _messages.add(localMsg);
    notifyListeners();

    final payload = {
      "content": text,
      "type": "text",
      if (_isManagerMode && _activeTargetUserId != null) "user_id": _activeTargetUserId,
    };

    _channel!.sink.add(jsonEncode(payload));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _messages.clear();
    _waitingUsers = [];
    _activeTargetUserId = null;
    _currentUserId = null;
    notifyListeners();
  }
}