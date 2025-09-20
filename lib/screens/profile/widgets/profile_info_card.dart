import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileInfoCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar with Admin Badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    _getInitials(profile.displayName, profile.lastName),
                    style: textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Admin Badge
                if (profile.isAdmin)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Display Name with Admin Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (profile.displayName.isNotEmpty)
                  Flexible(
                    child: Text(
                      '${profile.displayName} ${profile.lastName}',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (profile.isAdmin) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ADMIN',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Text(
              profile.email,
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Member Since
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Member since ${profile.memberSince}',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String displayName, String lastName) {
    String initials = '';
    
    if (displayName.isNotEmpty) {
      initials += displayName[0].toUpperCase();
    }
    
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    
    // Fallback to '?' if no names provided
    return initials.isEmpty ? '?' : initials;
  }
}