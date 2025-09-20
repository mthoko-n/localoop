import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model/conversation_model.dart';
import 'model/message_model.dart'; 
import 'services/chat_api_service.dart';
import 'widgets/message_bubble.dart';
import 'package:localoop/services/api_client.dart';
import 'package:localoop/services/auth_service.dart';
import '../profile/services/profile_api_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final String locationName;
  final ApiClient apiClient; 
  const ChatScreen({
    super.key,
    required this.conversation,
    required this.locationName,
    required this.apiClient, 
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatService _chatService;
  late final ProfileApiService _profileService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  final Set<String> _typingUsers = <String>{};
  WebSocketChannel? _webSocketChannel;
  Timer? _typingTimer;
  String? _replyToMessageId;

  bool _isLoading = true;
  bool _isSending = false;
  bool _hasMoreMessages = true;
  int _currentPage = 1;

  String? _currentUserId;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(apiClient: widget.apiClient);
    _profileService = ProfileApiService(api: widget.apiClient);
    _loadCurrentUser();
    _loadMessages();
    _connectWebSocket();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _webSocketChannel?.sink.close();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final id = await AuthService().getCurrentUserId();
      if (id != null && mounted) {
        setState(() => _currentUserId = id);
        
        // Get user profile to fetch display name
        final profile = await _profileService.getUserProfile();
        if (mounted) {
          final displayName = profile.displayName.isNotEmpty 
              ? profile.displayName 
              : 'You';
          setState(() => _currentUserName = displayName);
        }
      }
    } catch (e) {
      print('Error loading current user: $e');
      // Fallback values
      if (mounted) {
        setState(() {
          _currentUserName = 'You';
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (!_hasMoreMessages) return;

    try {
      final response = await _chatService.getConversationMessages(
        conversationId: widget.conversation.id,
        page: _currentPage,
      );

      if (response != null && mounted) {
        final messages = response['messages'] as List? ?? [];
        final hasMore = response['has_more'] as bool? ?? false;

        setState(() {
          if (_currentPage == 1) {
            _messages = List<Map<String, dynamic>>.from(messages);
          } else {
            _messages.addAll(List<Map<String, dynamic>>.from(messages));
          }
          
          _hasMoreMessages = hasMore;
          _isLoading = false;
          _currentPage++;
        });

        if (_currentPage == 2) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load messages: $e');
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || !_hasMoreMessages) return;
    
    setState(() => _isLoading = true);
    await _loadMessages();
  }

  void _connectWebSocket() async {
    _webSocketChannel = await _chatService.connectToConversation(widget.conversation.id);
    
    if (_webSocketChannel != null) {
      _webSocketChannel!.stream.listen(
        (data) {
          final message = _chatService.parseWebSocketMessage(data);
          if (message != null) {
            _handleWebSocketMessage(message);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _reconnectWebSocket();
        },
        onDone: () {
          print('WebSocket connection closed');
          _reconnectWebSocket();
        },
      );
    }
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _connectWebSocket();
      }
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> wsMessage) {
    if (!mounted) return;

    final type = wsMessage['type'] as String?;
    
    switch (type) {
      case 'new_message':
        final message = wsMessage['message'] as Map<String, dynamic>?;
        if (message != null) {
          setState(() {
            _messages.insert(0, message);
          });
          _scrollToBottom();
        }
        break;
        
      case 'message_deleted':
        final messageId = wsMessage['message_id'] as String?;
        if (messageId != null) {
          setState(() {
            _messages.removeWhere((msg) => msg['id'] == messageId);
          });
        }
        break;
        
      case 'typing':
        final userId = wsMessage['user_id'] as String?;
        final userName = wsMessage['user_name'] as String?;
        final isTyping = wsMessage['is_typing'] as bool? ?? false;
        
        if (userId != null && userName != null && userId != _currentUserId) {
          setState(() {
            if (isTyping) {
              _typingUsers.add(userName);
            } else {
              _typingUsers.remove(userName);
            }
          });
        }
        break;
        
      case 'pong':
        // Handle pong response
        break;
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messageController.clear();
    });

    try {
      final response = await _chatService.sendMessage(
        conversationId: widget.conversation.id,
        content: content,
        replyToId: _replyToMessageId,
      );

      if (response != null && mounted) {
        // Message will be added through WebSocket
        setState(() => _replyToMessageId = null);
        _scrollToBottom();
      }
    } catch (e) {
      _showError('Failed to send message: $e');
      // Restore the message content on error
      _messageController.text = content;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      final success = await _chatService.deleteMessage(messageId);
      if (success && mounted) {
        setState(() {
          _messages.removeWhere((msg) => msg['id'] == messageId);
        });
        _showSuccess('Message deleted');
      } else {
        _showError('Failed to delete message');
      }
    } catch (e) {
      _showError('Failed to delete message: $e');
    }
  }

  void _onTypingChanged() {
    _typingTimer?.cancel();
    
    // Send typing indicator
    if (_webSocketChannel != null && _currentUserId != null && _currentUserName != null) {
      _chatService.sendTypingIndicator(
        channel: _webSocketChannel!,
        userId: _currentUserId!,
        userName: _currentUserName!,
        isTyping: true,
      );
    }

    // Stop typing after 2 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_webSocketChannel != null && _currentUserId != null && _currentUserName != null) {
        _chatService.sendTypingIndicator(
          channel: _webSocketChannel!,
          userId: _currentUserId!,
          userName: _currentUserName!,
          isTyping: false,
        );
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _replyToMessage(Map<String, dynamic> message) {
    setState(() => _replyToMessageId = message['id']);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() => _replyToMessageId = null);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Map<String, dynamic>? get _replyMessage {
    if (_replyToMessageId == null) return null;
    try {
      return _messages.firstWhere((msg) => msg['id'] == _replyToMessageId);
    } catch (e) {
      return null;
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  // Convert Map to Message object for MessageBubble
  Message _mapToMessage(Map<String, dynamic> messageData) {
    return Message(
      id: messageData['id'] ?? '',
      content: messageData['content'] ?? '',
      authorId: messageData['author_id'] ?? '',
      authorName: messageData['author_name'] ?? 'Unknown',
      timestamp: DateTime.tryParse(messageData['timestamp'] ?? '') ?? DateTime.now(),
      conversationId: widget.conversation.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversation.title),
            Text(
              '${widget.locationName} • ${widget.conversation.category}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Conversation header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.body,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Started by ${widget.conversation.authorName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_hasMoreMessages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return _isLoading
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }

                            final messageData = _messages[index];
                            final message = _mapToMessage(messageData);
                            final isFromCurrentUser = messageData['author_id'] == _currentUserId;
                            
                            return MessageBubble(
                              message: message,
                              isCurrentUser: isFromCurrentUser,
                              onReply: () => _replyToMessage(messageData),
                              onDelete: isFromCurrentUser ? () => _deleteMessage(message.id) : null,
                            );
                          },
                        ),
                      ),

                      // Typing indicator
                      if (_typingUsers.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_typingUsers.join(', ')} ${_typingUsers.length == 1 ? 'is' : 'are'} typing...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),

          // Reply preview
          if (_replyMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyMessage!['author_name']}: ${_replyMessage!['content']}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _cancelReply,
                    icon: const Icon(Icons.close, size: 16),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => _onTypingChanged(),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: _isSending ? null : _sendMessage,
                  child: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}