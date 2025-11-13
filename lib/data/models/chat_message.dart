class ChatMessage {
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
  });
}