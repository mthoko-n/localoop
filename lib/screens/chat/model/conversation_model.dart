// lib/screens/chat/model/conversation_model.dart
class Conversation {
  final String id;
  final String locationId;
  final String title;
  final String body;
  final String category;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime lastActivity;
  final int messageCount;
  final bool isUnread;

  const Conversation({
    required this.id,
    required this.locationId,
    required this.title,
    required this.body,
    required this.category,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.lastActivity,
    required this.messageCount,
    required this.isUnread,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      locationId: json['location_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      category: json['category'] ?? 'general',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      lastActivity: DateTime.tryParse(json['last_activity'] ?? '') ?? DateTime.now(),
      messageCount: json['message_count'] ?? 0,
      isUnread: json['is_unread'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'title': title,
      'body': body,
      'category': category,
      'author_id': authorId,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'last_activity': lastActivity.toIso8601String(),
      'message_count': messageCount,
      'is_unread': isUnread,
    };
  }

  Conversation copyWith({
    String? id,
    String? locationId,
    String? title,
    String? body,
    String? category,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? lastActivity,
    int? messageCount,
    bool? isUnread,
  }) {
    return Conversation(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      messageCount: messageCount ?? this.messageCount,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}