import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  String? _currentToken;
  List<int> _waitingUsers = [];

  final String _managerToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjc3ODc5MzkxNzcsInJvbGUiOiJtYW5hZ2VyIiwidXNlcl9pZCI6Mn0.NqNyE0yIyyumue9DWJXHmmUfjbWo5xN7zmnXvr3k_vU";

  List<ChatMessage> _messages = [];
  bool _hasUnreadMessages = false;
  bool _isUploading = false;

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  bool get isManagerMode => _isManagerMode;
  bool get isUploading => _isUploading;
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
    _waitingUsers = [];
    _activeTargetUserId = null;
    _messages.clear();
    disconnect();
    connect(value ? _managerToken : userToken);
  }

  void connect(String? token) {
    if (token == null || _isConnected) return;
    _currentToken = token;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _currentUserId = int.tryParse(decodedToken['user_id'].toString());
      print(">>> [CHAT] Current User ID: $_currentUserId");
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

  Future<void> uploadAndSendImage(Uint8List bytes, String fileName) async {
    if (!_isConnected) return;

    print(">>> [CHAT] Starting image upload to Media Service: $fileName");
    _isUploading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(ApiConfig.mediaUploadEndpoint);
      var request = http.MultipartRequest('POST', uri);

      final mimeType = fileName.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        bytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));

      if (_currentToken != null) {
        request.headers['Authorization'] = 'Bearer $_currentToken';
      }

      print(">>> [CHAT] Uploading to: $uri");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(">>> [CHAT] Media Upload Status: ${response.statusCode}");
      print(">>> [CHAT] Media Upload Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String imageUrl = data['url'];

        final socketPayload = {
          "content": imageUrl,
          "type": "image",
          "file_name": fileName,
          if (_isManagerMode && _activeTargetUserId != null) "user_id": _activeTargetUserId,
        };

        print(">>> [CHAT] Sending image URL to WebSocket: $socketPayload");
        _channel!.sink.add(jsonEncode(socketPayload));
        
        _messages.add(ChatMessage(
          imageUrl: imageUrl,
          type: "image",
          timestamp: DateTime.now(),
          isSentByMe: true,
          fromId: _currentUserId,
        ));
      } else {
        print(">>> [CHAT] Media Upload Failed: ${response.body}");
      }
    } catch (e) {
      print(">>> [CHAT] Image Upload Exception: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
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
    final payload = { "command": cmd, if (targetId != null) "user_id": targetId };
    print(">>> [CHAT] Sending Command: $payload");
    _channel!.sink.add(jsonEncode(payload));
    notifyListeners();
  }

  Future<void> sendMessage({required String text}) async {
    if (!_isConnected || _channel == null) return;
    final payload = {
      "content": text,
      "type": "text",
      if (_isManagerMode && _activeTargetUserId != null) "user_id": _activeTargetUserId,
    };
    print(">>> [CHAT] Sending Message: $payload");
    _channel!.sink.add(jsonEncode(payload));
    _messages.add(ChatMessage(
      text: text,
      timestamp: DateTime.now(),
      isSentByMe: true,
      type: "text",
      fromId: _currentUserId,
    ));
    notifyListeners();
  }

  void disconnect() {
    print(">>> [CHAT] Disconnecting...");
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _messages.clear();
    _waitingUsers = [];
    _activeTargetUserId = null;
    _currentUserId = null;
    _currentToken = null;
    notifyListeners();
  }
}