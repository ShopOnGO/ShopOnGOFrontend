import 'dart:convert';

class ChatMessage {
  final int? id;
  final int? fromId;
  final int? toId;
  final String? text;
  final String? imageUrl;
  final String? type;
  final DateTime timestamp;
  final bool isSentByMe;

  ChatMessage({
    this.id,
    this.fromId,
    this.toId,
    this.text,
    this.imageUrl,
    this.type,
    required this.timestamp,
    required this.isSentByMe,
  });

  factory ChatMessage.fromServerJson(Map<String, dynamic> json, int currentUserId) {
    if (json.containsKey('status')) {
      return ChatMessage(
        text: "${json['message']}${json['payload'] != null ? ': ${json['payload']}' : ''}",
        type: "system",
        timestamp: DateTime.now(),
        isSentByMe: false,
      );
    }

    String? contentText;
    String? imgUrl;
    String contentType = json['type'] ?? "text";

    if (contentType == "image") {
      imgUrl = json['content'];
    } else {
      try {
        final innerContent = jsonDecode(json['content']);
        if (innerContent is Map) {
          contentText = innerContent['content'];
          contentType = innerContent['type'] ?? contentType;
          if (contentType == "image") imgUrl = innerContent['content'];
        } else {
          contentText = json['content'];
        }
      } catch (_) {
        contentText = json['content'];
      }
    }

    return ChatMessage(
      id: json['id'],
      fromId: json['from_id'],
      toId: json['to_id'],
      text: contentText,
      imageUrl: imgUrl,
      type: contentType,
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isSentByMe: json['from_id'] == currentUserId,
    );
  }
}