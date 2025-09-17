import 'package:flutter/material.dart';
import '../model/conversation_model.dart';
import '../utils/chat_constants.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onDelete,
    this.currentUserId,
  });

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Conversation Options',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Only Delete Option
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Conversation',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('This action cannot be undone'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call(); // Call the parent's delete method directly
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryFilter = ChatConstants.filters.firstWhere(
      (f) => f.id == conversation.category,
      orElse: () => ChatConstants.filters.first,
    );

    final isAuthor = currentUserId == conversation.authorId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category + created time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(categoryFilter.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          categoryFilter.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    ChatConstants.getRelativeTime(conversation.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                conversation.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                conversation.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.secondary,
                    child: Text(
                      conversation.authorName.isNotEmpty
                          ? conversation.authorName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.authorName.isNotEmpty
                              ? conversation.authorName
                              : 'Anonymous',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Last activity: ${_formatTimeAgo(conversation.lastActivity)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAuthor && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showOptionsBottomSheet(context),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(
                        '${conversation.messageCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}