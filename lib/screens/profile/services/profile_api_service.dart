import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
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
    
    // Password change logs out all devices for security
    // The user will need to log in again
    await AuthService().logout();
    
    return data['message'] as String;
  }

  // -----------------------------
  // Delete account
  // -----------------------------
  Future<String> deleteAccount({String? password}) async {
    final Map<String, dynamic> body = {};
    
    // Only add password if provided (Google users might not have password)
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    
    final data = await api.delete('/profile/delete-account', body: body);
    
    // Account deletion automatically logs out all devices
    // AuthService logout is called by the backend, but we ensure it here too
    await AuthService().logout();
    
    return data['message'] as String;
  }

  // -----------------------------
  // Logout (proper refresh token handling)
  // -----------------------------
  Future<void> logout() async {
    // Use AuthService logout which properly revokes refresh tokens
    await AuthService().logout();
  }

  // -----------------------------
  // Logout from all devices
  // -----------------------------
  Future<void> logoutAllDevices() async {
    await AuthService().logoutAllDevices();
  }
}