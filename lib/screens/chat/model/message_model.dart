class Message {
  final String id;
  final String conversationId;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime timestamp;
  final bool isEdited;
  final String? replyToId;

  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
    this.isEdited = false,
    this.replyToId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isEdited: json['is_edited'] ?? false,
      replyToId: json['reply_to_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'timestamp': timestamp.toIso8601String(),
      'is_edited': isEdited,
      'reply_to_id': replyToId,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? timestamp,
    bool? isEdited,
    String? replyToId,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      replyToId: replyToId ?? this.replyToId,
    );
  }

  bool get isFromCurrentUser {
    // You'll implement this based on your auth system
    // For now, return false
    return false;
  }
}
