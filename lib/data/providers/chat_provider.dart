import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/utils/app_logger.dart';
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

  final String _managerToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjc3ODc5MzkxNzcsInJvbGUiOiJtYW5hZ2VyIiwidXNlcl9pZCI6Mn0.NqNyE0yIyyumue9DWJXHmmUfjbWo5xN7zmnXvr3k_vU";

  final List<ChatMessage> _messages = [];
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
            ? (_activeTargetUserId != null
                  ? "CONV_MANAGER_CHAT"
                  : "CONV_WAITING")
            : "CONV_SUPPORT",
        avatarUrl: "",
        messages: _messages,
        unreadCount: _hasUnreadMessages ? 1 : 0,
      ),
    ];
  }

  void setManagerMode(bool value, String? userToken) {
    logger.i('Chat: Switching Mode - ManagerMode = $value');
    _isManagerMode = value;
    _waitingUsers = [];
    _activeTargetUserId = null;
    _messages.clear();
    disconnect();
    connect(value ? _managerToken : userToken);
  }

  void connect(String? token) {
    if (token == null) {
      logger.w('Chat: Connection aborted - Token is null');
      return;
    }
    if (_isConnected) {
      logger.d('Chat: Already connected, skipping...');
      return;
    }

    _currentToken = token;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _currentUserId = int.tryParse(decodedToken['user_id'].toString());
      logger.d('Chat: Connecting to WS as UserID: $_currentUserId');
    } catch (e) {
      logger.e('Chat: Failed to decode JWT', error: e);
    }

    final wsUrl = "${ApiConfig.wsChatUrl}?token=$token";
    logger.d('Chat: WS URL - $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
        (data) => _onMessageReceived(data),
        onError: (err) {
          logger.e('Chat: WebSocket Stream Error', error: err);
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          logger.i('Chat: WebSocket Connection Closed by Server');
          _isConnected = false;
          notifyListeners();
        },
      );

      if (_isManagerMode) {
        logger.d('Chat: Manager mode active, requesting user list');
        sendCommand("list");
      }
    } catch (e, stackTrace) {
      logger.e(
        'Chat: WebSocket Connection Exception',
        error: e,
        stackTrace: stackTrace,
      );
      _isConnected = false;
      notifyListeners();
    }
  }

  void _onMessageReceived(dynamic data) {
    logger.d('Chat: WS Incoming Raw Data: $data');
    try {
      final json = jsonDecode(data);

      if (json['payload'] != null && json['payload'] is List) {
        _waitingUsers = List<int>.from(json['payload']);
        logger.i('Chat: Updated waiting users: $_waitingUsers');
        notifyListeners();
      }

      final message = ChatMessage.fromServerJson(json, _currentUserId ?? 0);
      if (message.isSentByMe && message.type != "system") {
        logger.d(
          'Chat: Ignored echo message from server to prevent duplication.',
        );
        return;
      }

      _messages.add(message);
      _hasUnreadMessages = true;
      logger.d('Chat: New message added. Count: ${_messages.length}');
      notifyListeners();
    } catch (e) {
      logger.e('Chat: Error parsing incoming message', error: e);
    }
  }

  Future<void> uploadAndSendImage(Uint8List bytes, String fileName) async {
    if (!_isConnected) {
      logger.w('Chat: Cannot upload, WS not connected');
      return;
    }

    logger.i('Chat: Starting image upload: $fileName');
    _isUploading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(ApiConfig.mediaUploadEndpoint);
      var request = http.MultipartRequest('POST', uri);

      final mimeType = fileName.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      if (_currentToken != null) {
        request.headers['Authorization'] = 'Bearer $_currentToken';
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String imageUrl = data['url'];
        logger.i('Chat: Image uploaded. URL: $imageUrl');

        final socketPayload = {
          "content": imageUrl,
          "type": "image",
          "file_name": fileName,
          if (_isManagerMode && _activeTargetUserId != null)
            "user_id": _activeTargetUserId,
        };

        _channel!.sink.add(jsonEncode(socketPayload));

        _messages.add(
          ChatMessage(
            imageUrl: imageUrl,
            type: "image",
            timestamp: DateTime.now(),
            isSentByMe: true,
            fromId: _currentUserId,
          ),
        );
      } else {
        logger.e('Chat: Media Upload Failed. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e(
        'Chat: Exception during upload',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void markMessagesAsRead() {
    if (_hasUnreadMessages) {
      _hasUnreadMessages = false;
      notifyListeners();
    }
  }

  void sendCommand(String cmd, {int? targetId}) {
    if (!_isConnected) return;

    if (cmd == "take" && targetId != null) {
      logger.i('Chat Manager: Taking user $targetId');
      _messages.clear();
      _activeTargetUserId = targetId;
    } else if (cmd == "close") {
      logger.i('Chat Manager: Closing session with $_activeTargetUserId');
      _activeTargetUserId = null;
    }

    final payload = {"command": cmd, if (targetId != null) "user_id": targetId};
    _channel!.sink.add(jsonEncode(payload));
    notifyListeners();
  }

  Future<void> sendMessage({required String text}) async {
    if (!_isConnected || _channel == null) {
      logger.w('Chat: Cannot send, not connected');
      return;
    }

    final payload = {
      "content": text,
      "type": "text",
      if (_isManagerMode && _activeTargetUserId != null)
        "user_id": _activeTargetUserId,
    };

    _channel!.sink.add(jsonEncode(payload));

    _messages.add(
      ChatMessage(
        text: text,
        timestamp: DateTime.now(),
        isSentByMe: true,
        type: "text",
        fromId: _currentUserId,
      ),
    );
    notifyListeners();
  }

  void disconnect() {
    logger.i('Chat: Disconnecting...');
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
