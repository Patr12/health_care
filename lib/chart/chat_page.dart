import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/models/message_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final bool isDoctor; // Add this to identify if the other user is a doctor

  const ChatPage({
    required this.otherUserId,
    required this.otherUserName,
    required this.isDoctor,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  late int currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId().then((_) {
      _loadMessages();
      // Consider adding a timer for periodic refresh or setup real-time listeners
    });
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      throw Exception('User not logged in');
    }
    setState(() {
      currentUserId = userId;
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Message> messages = await dbHelper.getMessagesBetweenUsers(
        currentUserId.toString(),
        widget.otherUserId.toString(),
      );

      // Mark received messages as read
      for (var message in messages) {
        if (message.receiverId == currentUserId.toString() && !message.isRead) {
          await dbHelper.markMessagesAsReads(message.id);
        }
      }

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Scroll to bottom after messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error loading messages: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load messages')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = Message(
      id: 0,
      senderId: currentUserId.toString(),
      receiverId: widget.otherUserId.toString(),
      content: _messageController.text,
      timestamp: DateTime.now(),
      status: 'sent',
      isRead: false,
    );

    try {
      await dbHelper.insertMessage(message.toMap());
      _messageController.clear();
      await _loadMessages(); // Refresh the messages

      // Notify the other user if possible (push notification, etc.)
      // You would need to implement this based on your backend
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          if (widget.isDoctor)
            IconButton(
              icon: Icon(Icons.medical_services),
              onPressed: () {
                // Add doctor-specific actions if needed
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? Center(
                      child: Text('Hakuna ujumbe bado. Anza mazungumzo!'),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe =
                            message.senderId == currentUserId.toString();

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(message.content),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'HH:mm',
                                      ).format(message.timestamp),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (isMe)
                                      Icon(
                                        message.isRead
                                            ? Icons.done_all
                                            : Icons.done,
                                        size: 14,
                                        color:
                                            message.isRead
                                                ? Colors.blue
                                                : Colors.grey,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Andika ujumbe...',
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
