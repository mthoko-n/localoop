import '../../../services/api_client.dart';
import '../model/user_profile_model.dart';

class ProfileApiService {
  final ApiClient api;

  ProfileApiService({required this.api});

  // -----------------------------
  // Get user profile
  // -----------------------------
  Future<UserProfile> getUserProfile() async {
    final data = await api.get('/profile/me');
    return UserProfile.fromJson(data);
  }

  // -----------------------------
  // Update profile
  // -----------------------------
  Future<String> updateProfile({
    String? displayName,
    String? lastName,
  }) async {
    final Map<String, dynamic> body = {};
    
    if (displayName != null) body['display_name'] = displayName;
    if (lastName != null) body['last_name'] = lastName;

    if (body.isEmpty) {
      throw Exception('No fields to update');
    }

    final data = await api.put('/profile/update', body: body);
    return data['message'] as String;
  }

  // -----------------------------
  // Change password
  // -----------------------------
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final data = await api.put('/profile/change-password', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    return data['message'] as String;
  }

  // -----------------------------
  // Delete account
  // -----------------------------
  Future<String> deleteAccount({required String password}) async {
    final data = await api.delete('/profile/delete-account', body: {
      'password': password,
    });
    return data['message'] as String;
  }

  // -----------------------------
  // Logout (clear token)
  // -----------------------------
  Future<void> logout() async {
    await api.storage.delete(key: 'auth_token');
  }
}