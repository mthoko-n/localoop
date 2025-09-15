import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localoop/services/network_helper.dart';

class ChatService {
  final _storage = const FlutterSecureStorage();

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
  // Get messages for a conversation with pagination
  // -----------------------------
  Future<Map<String, dynamic>?> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    String? before, // Message ID for cursor-based pagination
  }) async {
    try {
      final uri = NetworkHelper.buildUri('/chat/conversations/$conversationId/messages').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (before != null) 'before': before,
        },
      );

      final response = await http.get(uri, headers: await _getHeaders());

      Map<String, dynamic> data;
      try {
        data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } catch (_) {
        throw Exception('Failed to decode response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception('Failed to load messages: ${data['detail'] ?? response.body}');
      }
    } catch (e) {
      print('Error loading messages: $e');
      return null;
    }
  }

  // -----------------------------
  // Send a message to a conversation
  // -----------------------------
  Future<Map<String, dynamic>?> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
    try {
      final uri = NetworkHelper.buildUri('/chat/conversations/$conversationId/messages');
      final requestBody = {
        'content': content,
        if (replyToId != null) 'reply_to_id': replyToId,
      };

      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      Map<String, dynamic> data;
      try {
        data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } catch (_) {
        throw Exception('Failed to decode response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception('Failed to send message: ${data['detail'] ?? response.body}');
      }
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
      if (token == null) {
        print('No auth token found for WebSocket connection');
        return null;
      }
      
      final wsUri = NetworkHelper.buildUri('/chat/conversations/$conversationId/ws')
          .replace(scheme: 'ws')
          .replace(queryParameters: {'token': token});
      
      return WebSocketChannel.connect(wsUri);
    } catch (e) {
      print('Error connecting to conversation WebSocket: $e');
      return null;
    }
  }

  Future<WebSocketChannel?> connectToLocation(String locationId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        print('No auth token found for WebSocket connection');
        return null;
      }
      
      final wsUri = NetworkHelper.buildUri('/chat/locations/$locationId/ws')
          .replace(scheme: 'ws')
          .replace(queryParameters: {'token': token});
      
      return WebSocketChannel.connect(wsUri);
    } catch (e) {
      print('Error connecting to location WebSocket: $e');
      return null;
    }
  }

  // -----------------------------
  // WebSocket utilities
  // -----------------------------
  void sendTypingIndicator({
    required WebSocketChannel channel,
    required String userId,
    required String userName,
    required bool isTyping,
  }) {
    try {
      final message = {
        'type': 'typing',
        'user_id': userId,
        'user_name': userName,
        'is_typing': isTyping,
      };
      
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  void sendPing(WebSocketChannel channel) {
    try {
      final message = {'type': 'ping'};
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending ping: $e');
    }
  }

  Map<String, dynamic>? parseWebSocketMessage(dynamic data) {
    try {
      if (data is String) {
        return jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
      print('Error parsing WebSocket message: $e');
      return null;
    }
  }
}