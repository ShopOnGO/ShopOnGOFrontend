class ChatMessage {
final String? text;
final String? imageUrl;
final DateTime timestamp;
final bool isSentByMe;


ChatMessage({
this.text,
this.imageUrl,
required this.timestamp,
required this.isSentByMe,
});
}