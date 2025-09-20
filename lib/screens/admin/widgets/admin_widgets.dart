// lib/screens/admin/widgets/admin_widgets.dart

import 'package:flutter/material.dart';
import '../model/admin_models.dart';

// -------------------------
// METRICS CARDS
// -------------------------
class MetricsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const MetricsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MetricsDashboard extends StatelessWidget {
  final SystemMetrics metrics;

  const MetricsDashboard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.2, // Increased from 1.8 for even more height
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            MetricsCard(
              title: 'Total Users',
              value: '${metrics.users.total}',
              subtitle: '${metrics.users.active} active',
              icon: Icons.people,
              color: Colors.blue,
            ),
            MetricsCard(
              title: 'Admins',
              value: '${metrics.users.admins}',
              subtitle: '${metrics.users.banned} banned',
              icon: Icons.admin_panel_settings,
              color: Colors.orange,
            ),
            MetricsCard(
              title: 'Conversations',
              value: '${metrics.content.totalConversations}',
              subtitle: '${metrics.content.activeConversations} active',
              icon: Icons.chat,
              color: Colors.green,
            ),
            MetricsCard(
              title: 'Messages',
              value: '${metrics.content.totalMessages}',
              subtitle: '${metrics.content.activeMessages} active',
              icon: Icons.message,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
}

// -------------------------
// USER LIST WIDGETS
// -------------------------
class UserListItem extends StatelessWidget {
  final AdminUser user;
  final VoidCallback? onBan;
  final VoidCallback? onUnban;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final VoidCallback? onForceLogout;

  const UserListItem({
    super.key,
    required this.user,
    this.onBan,
    this.onUnban,
    this.onPromote,
    this.onDemote,
    this.onForceLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: user.isActive ? Colors.green : Colors.red,
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.fullName.isNotEmpty ? user.fullName : 'Unknown User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (user.isAdmin) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ADMIN',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Status: ${user.status}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: user.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (user.isActive && onBan != null)
                  ActionButton(
                    label: 'Ban',
                    icon: Icons.block,
                    color: Colors.red,
                    onPressed: onBan,
                  ),
                if (!user.isActive && onUnban != null)
                  ActionButton(
                    label: 'Unban',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onPressed: onUnban,
                  ),
                if (!user.isAdmin && user.isActive && onPromote != null)
                  ActionButton(
                    label: 'Promote',
                    icon: Icons.arrow_upward,
                    color: Colors.blue,
                    onPressed: onPromote,
                  ),
                if (user.isAdmin && onDemote != null)
                  ActionButton(
                    label: 'Demote',
                    icon: Icons.arrow_downward,
                    color: Colors.orange,
                    onPressed: onDemote,
                  ),
                if (user.isActive && onForceLogout != null)
                  ActionButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    color: Colors.grey,
                    onPressed: onForceLogout,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// -------------------------
// LOADING AND ERROR WIDGETS
// -------------------------
class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -------------------------
// PAGINATION WIDGET
// -------------------------
class PaginationControls extends StatelessWidget {
  final PaginationInfo pagination;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.pagination,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${pagination.currentPage} of ${pagination.totalPages}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            IconButton(
              onPressed: pagination.hasPreviousPage
                  ? () => onPageChanged(pagination.currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: pagination.hasNextPage
                  ? () => onPageChanged(pagination.currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}