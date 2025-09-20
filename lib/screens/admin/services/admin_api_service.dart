// lib/screens/admin/services/admin_api_service.dart

import '../../../services/api_client.dart';
import '../model/admin_models.dart';

class AdminApiService {
  final ApiClient api;

  AdminApiService({required this.api});

  // -------------------------
  // SYSTEM METRICS
  // -------------------------
  Future<SystemMetrics> getSystemMetrics() async {
    final data = await api.get('/admin/metrics');
    return SystemMetrics.fromJson(data['metrics']);
  }

  // -------------------------
  // USER MANAGEMENT
  // -------------------------
  Future<UsersListResponse> getUsers({int page = 1, int limit = 50}) async {
    final data = await api.get('/admin/users', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return UsersListResponse.fromJson(data);
  }

  Future<String> banUser(String userId, {String? reason}) async {
    final data = await api.post('/admin/ban-user', body: {
      'user_id': userId,
      if (reason != null) 'reason': reason,
    });
    return data['message'] as String;
  }

  Future<String> unbanUser(String userId) async {
    final data = await api.post('/admin/unban-user', body: {
      'user_id': userId,
    });
    return data['message'] as String;
  }

  Future<String> promoteUser(String userId) async {
    final data = await api.post('/admin/promote-user', body: {
      'user_id': userId,
    });
    return data['message'] as String;
  }

  Future<String> demoteUser(String userId) async {
    final data = await api.post('/admin/demote-user', body: {
      'user_id': userId,
    });
    return data['message'] as String;
  }

  Future<String> forceLogoutUser(String userId) async {
    final data = await api.post('/admin/force-logout', body: {
      'user_id': userId,
    });
    return data['message'] as String;
  }

  // -------------------------
  // SYSTEM ACTIONS
  // -------------------------
  Future<String> forceLogoutAllUsers() async {
    final data = await api.post('/admin/force-logout-all');
    return data['message'] as String;
  }

  // -------------------------
  // CONTENT MODERATION
  // -------------------------
  Future<Map<String, dynamic>> getConversationsByLocation(
    String locationId, {
    int page = 1,
    int limit = 50,
  }) async {
    return await api.get('/admin/conversations/$locationId', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<String> deleteConversation(String conversationId, {String? reason}) async {
    final data = await api.delete('/admin/conversation', body: {
      'conversation_id': conversationId,
      if (reason != null) 'reason': reason,
    });
    return data['message'] as String;
  }

  Future<String> deleteMessage(String messageId, {String? reason}) async {
    final data = await api.delete('/admin/message', body: {
      'message_id': messageId,
      if (reason != null) 'reason': reason,
    });
    return data['message'] as String;
  }

  Future<Map<String, dynamic>> getFlaggedContent() async {
    return await api.get('/admin/flagged-content');
  }

  // -------------------------
  // LOCATION MANAGEMENT
  // -------------------------
  Future<Map<String, dynamic>> getAllLocations({int page = 1, int limit = 50}) async {
    return await api.get('/admin/locations', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<Map<String, dynamic>> getLocationAnalytics(String locationId) async {
    return await api.get('/admin/location-analytics/$locationId');
  }

  Future<String> moderateLocation(
    String locationId,
    String action, {
    String? reason,
  }) async {
    final data = await api.post('/admin/moderate-location', body: {
      'location_id': locationId,
      'action': action,
      if (reason != null) 'reason': reason,
    });
    return data['message'] as String;
  }
}