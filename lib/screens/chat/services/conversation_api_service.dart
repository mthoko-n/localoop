import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/conversation_model.dart';
import 'package:localoop/services/network_helper.dart';

class ConversationService {
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
  // Get conversations for a specific location
  // -----------------------------
  Future<List<Conversation>?> getLocationConversations({
    required String locationId,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = NetworkHelper.buildUri('/chat/locations/$locationId/conversations').replace(
        queryParameters: {
          if (category != null) 'category': category,
          'page': page.toString(),
          'limit': limit.toString(),
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
        final conversationsData = (data['conversations'] as List<dynamic>?) ?? [];
        return conversationsData
            .map((json) => Conversation.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load conversations: ${data['detail'] ?? response.body}');
      }
    } catch (e) {
      print('Error loading conversations: $e');
      return null;
    }
  }

  // -----------------------------
  // Create a new conversation
  // -----------------------------
  Future<Conversation?> createConversation({
    required String locationId,
    required String title,
    required String body,
    required String category,
  }) async {
    try {
      final uri = NetworkHelper.buildUri('/chat/locations/$locationId/conversations');
      final requestBody = {
        'title': title,
        'body': body,
        'category': category,
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
        if (data.containsKey('conversation')) {
          return Conversation.fromJson(data['conversation']);
        } else {
          throw Exception('No conversation returned in response.');
        }
      } else {
        throw Exception('Failed to create conversation: ${data['detail'] ?? response.body}');
      }
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }

  // -----------------------------
  // Get a single conversation by ID
  // -----------------------------
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final uri = NetworkHelper.buildUri('/chat/conversations/$conversationId');
      final response = await http.get(uri, headers: await _getHeaders());

      Map<String, dynamic> data;
      try {
        data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } catch (_) {
        throw Exception('Failed to decode response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return Conversation.fromJson(data);
      } else {
        throw Exception('Failed to get conversation: ${data['detail'] ?? response.body}');
      }
    } catch (e) {
      print('Error loading conversation: $e');
      return null;
    }
  }
}