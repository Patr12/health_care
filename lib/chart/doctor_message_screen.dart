import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:health/chart/chat_page.dart'; // Import the chat page

class DoctorMessagesScreen extends StatefulWidget {
  final String doctorId;

  const DoctorMessagesScreen({required this.doctorId, Key? key})
    : super(key: key);

  @override
  _DoctorMessagesScreenState createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await dbHelper.getDoctorMessages(widget.doctorId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      await _markMessagesAsRead();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hitilafu ya kupakua ujumbe')));
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await dbHelper.markDoctorMessagesAsRead(widget.doctorId);
      setState(() {});
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _sendReply(String senderId, String senderName) async {
    if (_replyController.text.isEmpty) return;

    try {
      // Create new message
      final message = {
        'sender_id': widget.doctorId,
        'receiver_id': senderId,
        'content': _replyController.text,
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': 0,
      };

      // Save to database
      await dbHelper.insertMessage(message);

      // Clear reply field
      _replyController.clear();

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ujumbe umepelekwa kikamilifu')));

      // Refresh messages
      await _loadMessages();

      // Alternatively, navigate to chat page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatPage(
                otherUserId: senderId,
                otherUserName: senderName,
                isDoctor: false,
              ),
        ),
      );
    } catch (e) {
      print('Error sending reply: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hitilafu ya kutuma ujumbe: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ujumbe Wote'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadMessages),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? Center(child: Text('Hakuna ujumbe uliopokelewa'))
                    : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final senderId = message['sender_id'].toString();
                        final senderName = message['sender_name'] ?? 'Mtumiaji';
                        final content = message['content'] ?? '';
                        final timestamp = message['timestamp']?.toString();
                        final isRead = message['is_read'] == 1;

                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          color: isRead ? null : Colors.blue[50],
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    senderName.isNotEmpty ? senderName[0] : '?',
                                  ),
                                ),
                                title: Text(senderName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(content),
                                    if (timestamp != null)
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy HH:mm',
                                        ).format(DateTime.parse(timestamp)),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing:
                                    !isRead
                                        ? Icon(
                                          Icons.brightness_1,
                                          size: 12,
                                          color: Colors.blue,
                                        )
                                        : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _replyController,
                                        decoration: InputDecoration(
                                          hintText: 'Andika jibu...',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed:
                                          () =>
                                              _sendReply(senderId, senderName),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
