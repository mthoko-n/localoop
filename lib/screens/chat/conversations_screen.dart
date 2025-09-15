import 'package:flutter/material.dart';
import '../home/model/place_location.dart';
import 'model/conversation_model.dart';
import 'model/chat_filter_model.dart';
import 'widgets/conversation_card.dart';
import 'widgets/chat_filter_chips.dart';
import 'services/conversation_api_service.dart'; 
import 'chat_screen.dart';
import 'utils/chat_constants.dart';

class ConversationsScreen extends StatefulWidget {
  final String locationId;
  final String locationName;
  final Coordinates locationCoordinates;

  const ConversationsScreen({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.locationCoordinates,
  });

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ConversationService _conversationService = ConversationService(); // ✅

  List<Conversation> _conversations = [];
  List<ChatFilter> _filters = ChatConstants.filters;
  String _selectedFilter = 'all';
  bool _isLoading = true;
  bool _isCreatingConversation = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    try {
      final conversations = await _conversationService.getLocationConversations(
        locationId: widget.locationId,
        category: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      setState(() {
        _conversations = conversations ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load conversations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onFilterChanged(String filterId) {
    setState(() => _selectedFilter = filterId);
    _loadConversations();
  }

  void _navigateToChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversation: conversation,
          locationName: widget.locationName,
        ),
      ),
    );
  }

  void _createNewConversation() {
    if (_isCreatingConversation) return;

    showDialog(
      context: context,
      builder: (context) => _CreateConversationDialog(
        locationId: widget.locationId,
        onConversationCreated: (conversation) {
          setState(() => _conversations.insert(0, conversation));
        },
      ),
    );
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.locationName),
            Text(
              'Community Chat',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshConversations,
          ),
        ],
      ),
      body: Column(
        children: [
          ChatFilterChips(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshConversations,
                    child: _conversations.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conversation = _conversations[index];
                              return ConversationCard(
                                conversation: conversation,
                                onTap: () => _navigateToChat(conversation),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewConversation,
        icon: const Icon(Icons.add),
        label: const Text('New Topic'),
      ),
    );
  }

  Widget _buildEmptyState() {
    final selectedFilterName = _filters
        .firstWhere((f) => f.id == _selectedFilter,
            orElse: () => ChatFilter.all())
        .name;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all'
                  ? 'No conversations yet'
                  : 'No $selectedFilterName conversations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to start a discussion!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewConversation,
              icon: const Icon(Icons.add),
              label: const Text('Start Conversation'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateConversationDialog extends StatefulWidget {
  final String locationId;
  final Function(Conversation) onConversationCreated;

  const _CreateConversationDialog({
    required this.locationId,
    required this.onConversationCreated,
  });

  @override
  State<_CreateConversationDialog> createState() =>
      _CreateConversationDialogState();
}

class _CreateConversationDialogState
    extends State<_CreateConversationDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final ConversationService _conversationService = ConversationService(); 

  String _selectedCategory = 'general';
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final conversation = await _conversationService.createConversation(
        locationId: widget.locationId,
        title: title,
        body: body,
        category: _selectedCategory,
      );

      if (conversation != null && mounted) {
        widget.onConversationCreated(conversation);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create conversation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Conversation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ChatConstants.filters
                  .where((filter) => filter.id != 'all')
                  .map((filter) => DropdownMenuItem(
                        value: filter.id,
                        child: Row(
                          children: [
                            Text(filter.icon),
                            const SizedBox(width: 8),
                            Text(filter.name),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                hintText: 'What\'s this about?',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Provide more details...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createConversation,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
