import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class DoctorMessagesScreen extends StatefulWidget {
  final String doctorId;

  const DoctorMessagesScreen({required this.doctorId, Key? key}) : super(key: key);

  @override
  _DoctorMessagesScreenState createState() => _DoctorMessagesScreenState();
}

class _DoctorMessagesScreenState extends State<DoctorMessagesScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

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
      
      // Mark messages as read after loading
      await _markMessagesAsRead();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu ya kupakua ujumbe')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ujumbe Wote'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? Center(child: Text('Hakuna ujumbe uliopokelewa'))
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final senderName = message['sender_name'] ?? 'Mtumiaji';
                    final content = message['content'] ?? '';
                    final timestamp = message['timestamp']?.toString();
                    final isRead = message['is_read'] == 1;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      color: isRead ? null : Colors.blue[50],
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(senderName.isNotEmpty ? senderName[0] : '?'),
                        ),
                        title: Text(senderName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(content),
                            if (timestamp != null)
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(timestamp)),
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                        trailing: !isRead
                            ? Icon(Icons.brightness_1, size: 12, color: Colors.blue)
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}