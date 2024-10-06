class ChatMessage {
  final int id;
  final String senderType;
  final String content;
  final DateTime createdAt;

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: int.parse(map["chat_message_id"]),
      senderType: map["sender_type"],
      content: map["content"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }

  const ChatMessage({
    required this.id,
    required this.senderType,
    required this.content,
    required this.createdAt,
  });
}
