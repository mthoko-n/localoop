import 'package:flutter/material.dart';
 
class ChatFilter {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const ChatFilter({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static ChatFilter all() {
    return const ChatFilter(
      id: 'all',
      name: 'All',
      icon: '💬',
      color: Colors.grey,
    );
  }

  static ChatFilter water() {
    return const ChatFilter(
      id: 'water',
      name: 'Water',
      icon: '💧',
      color: Colors.blue,
    );
  }

  static ChatFilter electricity() {
    return const ChatFilter(
      id: 'electricity',
      name: 'Electricity',
      icon: '⚡',
      color: Colors.orange,
    );
  }

  static ChatFilter maintenance() {
    return const ChatFilter(
      id: 'maintenance',
      name: 'Maintenance',
      icon: '🔧',
      color: Colors.green,
    );
  }

  static ChatFilter crime() {
    return const ChatFilter(
      id: 'crime',
      name: 'Crime & Safety',
      icon: '🚨',
      color: Colors.red,
    );
  }

  static ChatFilter places() {
    return const ChatFilter(
      id: 'places',
      name: 'Local Places',
      icon: '📍',
      color: Colors.purple,
    );
  }

  static ChatFilter general() {
    return const ChatFilter(
      id: 'general',
      name: 'General',
      icon: '💬',
      color: Colors.blueGrey,
    );
  }
}

