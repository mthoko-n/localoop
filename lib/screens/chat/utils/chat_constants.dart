// lib/screens/chat/utils/chat_constants.dart
import 'package:flutter/material.dart';
import '../model/chat_filter_model.dart';

class ChatConstants {
  static const int maxMessageLength = 500;
  static const int conversationsPerPage = 20;
  static const int messagesPerPage = 50;
  
  static final List<ChatFilter> filters = [
    ChatFilter.all(),
    ChatFilter.water(),
    ChatFilter.electricity(),
    ChatFilter.maintenance(),
    ChatFilter.crime(),
    ChatFilter.places(),
    ChatFilter.general(),
  ];
  
  static ChatFilter getFilterById(String id) {
    return filters.firstWhere(
      (filter) => filter.id == id,
      orElse: () => ChatFilter.general(),
    );
  }
  
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  static String formatMessageCount(int count) {
    if (count == 0) return 'No messages';
    if (count == 1) return '1 message';
    if (count < 1000) return '$count messages';
    return '${(count / 1000).toStringAsFixed(1)}k messages';
  }
}