import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model/conversation_model.dart';
import 'model/message_model.dart'; 
import 'services/chat_api_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final String locationName;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.locationName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  Set<String> _typingUsers = <String>{};
  WebSocketChannel? _webSocketChannel;
  Timer? _typingTimer;
  String? _replyToMessageId;
  
  bool _isLoading = true;
  bool _isSending = false;
  bool _hasMoreMessages = true;
  int _currentPage = 1;

  // Mock current user - replace with actual user management
  final String _currentUserId = 'current-user-id';
  final String _currentUserName = 'Current User';

  @override
  void initState() {
    super.initState();
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

  void _onTypingChanged() {
    _typingTimer?.cancel();
    
    // Send typing indicator
    if (_webSocketChannel != null) {
      _chatService.sendTypingIndicator(
        channel: _webSocketChannel!,
        userId: _currentUserId,
        userName: _currentUserName,
        isTyping: true,
      );
    }

    // Stop typing after 2 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_webSocketChannel != null) {
        _chatService.sendTypingIndicator(
          channel: _webSocketChannel!,
          userId: _currentUserId,
          userName: _currentUserName,
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
              color: theme.colorScheme.surfaceVariant,
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

                            final message = _messages[index];
                            final isFromCurrentUser = message['author_id'] == _currentUserId;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: isFromCurrentUser 
                                    ? MainAxisAlignment.end 
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isFromCurrentUser)
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(
                                        (message['author_name'] as String? ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  if (!isFromCurrentUser) const SizedBox(width: 8),
                                  
                                  Flexible(
                                    child: GestureDetector(
                                      onLongPress: () => _replyToMessage(message),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isFromCurrentUser
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.surfaceVariant,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (!isFromCurrentUser)
                                              Text(
                                                message['author_name'] ?? 'Unknown',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (!isFromCurrentUser) const SizedBox(height: 4),
                                            
                                            Text(
                                              message['content'] ?? '',
                                              style: TextStyle(
                                                color: isFromCurrentUser
                                                    ? theme.colorScheme.onPrimary
                                                    : theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTime(message['timestamp'] ?? ''),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isFromCurrentUser
                                                    ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                                    : theme.colorScheme.onSurface.withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  if (isFromCurrentUser) const SizedBox(width: 8),
                                  if (isFromCurrentUser)
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(
                                        _currentUserName[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
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
                color: theme.colorScheme.surfaceVariant,
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