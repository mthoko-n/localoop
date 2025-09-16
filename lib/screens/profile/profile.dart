import 'package:flutter/material.dart';
import 'package:localoop/services/api_client.dart';
import 'services/profile_api_service.dart';
import 'model/user_profile_model.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_action_card.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/delete_account_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final ApiClient apiClient;

  const ProfileScreen({
    super.key,
    required this.apiClient,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileApiService _api;
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _api = ProfileApiService(api: widget.apiClient);
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _api.getUserProfile();
      setState(() => _profile = profile);
    } catch (e) {
      _showErrorSnackBar('Failed to load profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _editProfile() async {
    if (_profile == null) return;

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => EditProfileDialog(
        initialDisplayName: _profile!.displayName,
        initialLastName: _profile!.lastName,
      ),
    );

    if (result != null) {
      try {
        final message = await _api.updateProfile(
          displayName: result['displayName'],
          lastName: result['lastName'],
        );
        _showSuccessSnackBar(message);
        _fetchProfile(); // Refresh profile data
      } catch (e) {
        _showErrorSnackBar('Failed to update profile: $e');
      }
    }
  }

  Future<void> _changePassword() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );

    if (result != null) {
      try {
        final message = await _api.changePassword(
          currentPassword: result['currentPassword']!,
          newPassword: result['newPassword']!,
        );
        _showSuccessSnackBar(message);
      } catch (e) {
        _showErrorSnackBar('Failed to change password: $e');
      }
    }
  }

  Future<void> _deleteAccount() async {
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );

    if (password != null) {
      try {
        await _api.deleteAccount(password: password);
        // Navigate to login screen or handle account deletion
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        _showErrorSnackBar('Failed to delete account: $e');
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _api.logout();
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Failed to load profile'))
              : RefreshIndicator(
                  onRefresh: _fetchProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Info Card
                        ProfileInfoCard(profile: _profile!),
                        
                        const SizedBox(height: 16),
                        
                        // Account Actions
                        ProfileActionCard(
                          title: 'Edit Profile',
                          subtitle: 'Update your display name and last name',
                          icon: Icons.edit,
                          onTap: _editProfile,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        ProfileActionCard(
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          icon: Icons.lock,
                          onTap: _changePassword,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Logout Button
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.logout, color: Colors.orange),
                            title: const Text('Logout'),
                            subtitle: const Text('Sign out of your account'),
                            onTap: _logout,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Delete Account Button
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.delete_forever, color: Colors.red),
                            title: const Text(
                              'Delete Account',
                              style: TextStyle(color: Colors.red),
                            ),
                            subtitle: const Text('Permanently delete your account'),
                            onTap: _deleteAccount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}