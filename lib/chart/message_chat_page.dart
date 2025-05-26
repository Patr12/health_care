import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health/chart/user_selection_dialog.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/models/message_model.dart';

class MessageChatPage extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const MessageChatPage({
    required this.currentUserId,
    required this.currentUserName,
    Key? key,
  }) : super(key: key);

  @override
  _MessageChatPageState createState() => _MessageChatPageState();
}

class _MessageChatPageState extends State<MessageChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  String? _selectedUserId;
  String? _selectedUserName;
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final db = await DatabaseHelper().database;
      final users = await db.rawQuery('''
        SELECT id, name, 'admin' as role FROM admins
        UNION
        SELECT id, name, 'doctor' as role FROM doctors
        WHERE id != ?
      ''', [widget.currentUserId]);

      setState(() {
        _availableUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectUser() async {
    final selectedUserId = await showDialog<String>(
      context: context,
      builder: (context) => UserSelectionDialog(
        users: _availableUsers,
        currentUserId: widget.currentUserId,
      ),
    );

    if (selectedUserId != null) {
      final selectedUser = _availableUsers.firstWhere(
        (user) => user['id'] == selectedUserId,
      );
      
      setState(() {
        _selectedUserId = selectedUserId;
        _selectedUserName = selectedUser['name'];
      });
      
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_selectedUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await DatabaseHelper().getMessagesBetweenUsers(
        widget.currentUserId,
        _selectedUserId!,
      );

      // Mark messages as read
      await DatabaseHelper().markMessagesAsRead(
        int.parse(_selectedUserId!),
        int.parse(widget.currentUserId),
      );

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedUserId == null) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: widget.currentUserId,
      receiverId: _selectedUserId!,
      content: _messageController.text,
      timestamp: DateTime.now(),
      senderName: widget.currentUserName,
      receiverName: _selectedUserName,
    );

    try {
      await DatabaseHelper().insertMessage(message);
      
      setState(() {
        _messages.add(message);
        _messageController.clear();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedUserId == null
            ? const Text('Select a user')
            : Text('Chat with $_selectedUserName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _selectUser,
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
          else if (_selectedUserId == null)
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
                    TextButton(
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

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              message.senderName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          Text(message.content),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('hh:mm a').format(message.timestamp),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}