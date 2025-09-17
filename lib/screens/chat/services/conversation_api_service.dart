import '../model/conversation_model.dart';
import 'package:localoop/services/api_client.dart';

class ConversationService {
  final ApiClient api;

  ConversationService({required this.api});

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
      final queryParams = {
        if (category != null) 'category': category,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final data = await api.get('/chat/locations/$locationId/conversations?${Uri(queryParameters: queryParams).query}');

      final conversationsData = (data['conversations'] as List<dynamic>?) ?? [];
      return conversationsData.map((json) => Conversation.fromJson(json)).toList();
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
      final requestBody = {
        'title': title,
        'body': body,
        'category': category,
      };

      final data = await api.post('/chat/locations/$locationId/conversations', body: requestBody);

      if (data.containsKey('conversation')) {
        return Conversation.fromJson(data['conversation']);
      } else {
        throw Exception('No conversation returned in response.');
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
      final data = await api.get('/chat/conversations/$conversationId');
      return Conversation.fromJson(data);
    } catch (e) {
      print('Error loading conversation: $e');
      return null;
    }
  }

  // -----------------------------
  // Delete a conversation by ID
  // -----------------------------
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final data = await api.delete('/chat/conversations/$conversationId');
      return data != null && (data['message']?.toLowerCase().contains('success') ?? false);
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }
}
