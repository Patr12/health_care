import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagingScreen extends StatefulWidget {
  final dynamic recipientId;
  final String recipientName;

  const MessagingScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  late int _currentUserId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('userId') ?? 0;
    });
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final messages = await _dbHelper.getConversation(
        _currentUserId,
        widget.recipientId as int,
      );

      // Create a new mutable list from the returned messages
      final mutableMessages = List<Map<String, dynamic>>.from(messages);

      if (!mounted) return;
      setState(() {
        _messages = mutableMessages;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

      // Mark messages as read
      await _dbHelper.markMessagesAsRead(
        widget.recipientId,
        _currentUserId as String,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading messages: ${e.toString()}")),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_isSending) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    // Create a temporary message with pending status
    final tempMessage = {
      'sender_id': _currentUserId,
      'receiver_id': widget.recipientId,
      'message_text': messageText,
      'sent_at': DateTime.now().toIso8601String(),
      'is_read': 1,
      'status': 'pending',
    };

    setState(() {
      _messages = [..._messages, tempMessage];
    });

    try {
      // Scroll to bottom after adding new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      // Send message to database
      final messageId = await _dbHelper.sendMessage({
        'sender_id': _currentUserId,
        'receiver_id': widget.recipientId,
        'message_text': messageText,
      });

      // Update the message with the actual ID from database
      final updatedMessages =
          _messages.map((msg) {
            if (msg['status'] == 'pending' &&
                msg['message_text'] == messageText) {
              return {...msg, 'id': messageId, 'status': 'delivered'};
            }
            return msg;
          }).toList();

      if (!mounted) return;
      setState(() {
        _messages = updatedMessages;
        _isSending = false;
      });

      // Optionally reload messages to get exact timestamps from server
      await _loadMessages();
    } catch (e) {
      // Update message status to failed
      final updatedMessages =
          _messages.map((msg) {
            if (msg['status'] == 'pending' &&
                msg['message_text'] == messageText) {
              return {...msg, 'status': 'failed'};
            }
            return msg;
          }).toList();

      if (!mounted) return;
      setState(() {
        _messages = updatedMessages;
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message['sender_id'] == _currentUserId;
        final isFailed = message['status'] == 'failed';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 20),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isMe
                            ? (isFailed ? Colors.red[100] : Colors.blue[100])
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['message_text'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat(
                              'hh:mm a',
                            ).format(DateTime.parse(message['sent_at'])),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (isMe && isFailed)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.error,
                                size: 14,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe && isFailed)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => _retryFailedMessage(message),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon:
                _isSending
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send),
            color: Colors.blue,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _retryFailedMessage(Map<String, dynamic> message) async {
    setState(() {
      _messages =
          _messages.map((msg) {
            if (msg == message) {
              return {...msg, 'status': 'pending'};
            }
            return msg;
          }).toList();
    });

    await _sendMessage();
  }
}
