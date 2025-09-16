import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localoop/services/api_client.dart'; 

class ChatService {
  final ApiClient apiClient;
  final _storage = const FlutterSecureStorage();

  ChatService({required this.apiClient});

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No auth token found. User might not be logged in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // -----------------------------
  // Get messages
  // -----------------------------
  Future<Map<String, dynamic>?> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    String? before,
  }) async {
    try {
      final response = await apiClient.get(
        '/chat/conversations/$conversationId/messages',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (before != null) 'before': before,
        },
        headers: await _getHeaders(),
      );

      return response;
    } catch (e) {
      print('Error loading messages: $e');
      return null;
    }
  }

  // -----------------------------
  // Send a message
  // -----------------------------
  Future<Map<String, dynamic>?> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
    try {
      final body = {
        'content': content,
        if (replyToId != null) 'reply_to_id': replyToId,
      };

      final response = await apiClient.post(
        '/chat/conversations/$conversationId/messages',
        body: body,
        headers: await _getHeaders(),
      );

      return response;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // -----------------------------
  // WebSocket connections
  // -----------------------------
  Future<WebSocketChannel?> connectToConversation(String conversationId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return null;

      final wsUri = apiClient.buildWsUri('/chat/conversations/$conversationId/ws', queryParams: {'token': token});
      return WebSocketChannel.connect(wsUri);
    } catch (e) {
      print('Error connecting to conversation WebSocket: $e');
      return null;
    }
  }

  void sendTypingIndicator({
    required WebSocketChannel channel,
    required String userId,
    required String userName,
    required bool isTyping,
  }) {
    final message = {
      'type': 'typing',
      'user_id': userId,
      'user_name': userName,
      'is_typing': isTyping,
    };
    channel.sink.add(jsonEncode(message));
  }

  void sendPing(WebSocketChannel channel) {
    channel.sink.add(jsonEncode({'type': 'ping'}));
  }

  Map<String, dynamic>? parseWebSocketMessage(dynamic data) {
    try {
      if (data is String) return jsonDecode(data) as Map<String, dynamic>;
      if (data is Map<String, dynamic>) return data;
      return null;
    } catch (e) {
      print('Error parsing WebSocket message: $e');
      return null;
    }
  }
}
