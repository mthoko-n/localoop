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
            // Profile Avatar
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
            
            const SizedBox(height: 16),
            
            // Display Name
            if (profile.displayName.isNotEmpty)
              Text(
                '${profile.displayName} ${profile.lastName}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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