import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/models/message_model.dart';
import 'package:health/models/user_model.dart';

class MessageChatPage extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const MessageChatPage({
    required this.currentUserId,
    required this.currentUserName,
    super.key,
  });

  @override
  _MessageChatPageState createState() => _MessageChatPageState();
}

class _MessageChatPageState extends State<MessageChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  User? _selectedUser;
  List<User> _availableUsers = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final dbHelper = DatabaseHelper();
      final users = await dbHelper.getAllUsersExcept(widget.currentUserId);
      
      setState(() {
        _availableUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load users');
    }
  }

  Future<void> _selectUser() async {
    final selectedUser = await showDialog<User>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select User'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableUsers.length,
            itemBuilder: (context, index) {
              final user = _availableUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name.substring(0, 1)),
                ),
                title: Text(user.name),
                subtitle: Text(user.role),
                onTap: () => Navigator.pop(context, user),
              );
            },
          ),
        ),
      ),
    );

    if (selectedUser != null) {
      setState(() {
        _selectedUser = selectedUser;
      });
      await _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_selectedUser == null) return;

    setState(() => _isLoading = true);

    try {
      final messages = await DatabaseHelper().getMessagesBetweenUsers(
        widget.currentUserId,
        _selectedUser!.id,
      );

      await DatabaseHelper().markMessagesAsRead(
        _selectedUser!.id,
        widget.currentUserId,
      );

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load messages');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedUser == null) return;
    if (_isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isSending = true);

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: widget.currentUserId,
      receiverId: _selectedUser!.id,
      content: content,
      timestamp: DateTime.now(),
      status: 'pending',
    );

    setState(() {
      _messages = [..._messages, newMessage];
    });

    _scrollToBottom();

    try {
      final messageId = await DatabaseHelper().insertMessage(newMessage);
      
      setState(() {
        _messages = _messages.map((msg) {
          return msg.id == newMessage.id 
              ? msg.copyWith(id: messageId, status: 'sent') 
              : msg;
        }).toList();
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() {
        _messages = _messages.map((msg) {
          return msg.id == newMessage.id 
              ? msg.copyWith(status: 'failed') 
              : msg;
        }).toList();
      });
      _showErrorSnackbar('Failed to send message');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedUser == null
            ? const Text('Select a user')
            : Text('Chat with ${_selectedUser!.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _selectUser,
          ),
          if (_selectedUser != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMessages,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading && _messages.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_selectedUser == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.message, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No user selected',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _selectUser,
                      child: const Text('Select a user to chat with'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.senderId == widget.currentUserId;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: isMe 
                          ? MainAxisAlignment.end 
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe)
                          CircleAvatar(
                            radius: 16,
                            child: Text(_selectedUser!.name.substring(0, 1)),
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe 
                                  ? (message.status == 'failed' 
                                      ? Colors.red[100] 
                                      : Colors.blue[100])
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe 
                                  ? CrossAxisAlignment.end 
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Text(
                                    _selectedUser!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                Text(message.content),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('hh:mm a').format(message.timestamp),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (isMe && message.status == 'failed')
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4.0),
                                        child: Icon(Icons.error, size: 14, color: Colors.red),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMe && message.status == 'failed')
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () => _retryMessage(message),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Padding(
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
                  icon: _isSending
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _retryMessage(Message message) async {
    setState(() {
      _messages = _messages.map((msg) {
        return msg.id == message.id 
            ? msg.copyWith(status: 'pending') 
            : msg;
      }).toList();
    });
    
    await _sendMessage();
  }
}