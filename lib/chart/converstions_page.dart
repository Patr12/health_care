import 'package:flutter/material.dart';
import 'package:health/chart/chat_page.dart';
import 'package:health/data/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationsPage extends StatefulWidget {
  final bool highlightUnread;

  const ConversationsPage({this.highlightUnread = false, Key? key})
    : super(key: key);

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late String userId;
  bool isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserId();
    if (mounted && !isLoading) {
      await _loadUnreadCount();
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    if (id == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tafadhali ingia kwanza')));
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
    setState(() {
      userId = id.toString();
      isLoading = false;
    });

    if (widget.highlightUnread) {
      await _markAllMessagesAsRead();
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await dbHelper.getUnreadMessagesCount(userId);
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  Future<void> _markAllMessagesAsRead() async {
    final db = await dbHelper.database;
    await db.update(
      'messages',
      {'is_read': 1},
      where: 'receiver_id = ? AND is_read = 0',
      whereArgs: [userId],
    );
    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Mazungumzo')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mazungumzo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _loadUnreadCount();
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ConversationsPage(highlightUnread: true),
                    ),
                  ).then((_) => _loadUnreadCount());
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$_unreadCount',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUnreadCount();
          setState(() {});
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: dbHelper.getRecentConversations(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Hakuna mazungumzo'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final conv = snapshot.data![index];
                final fullName = conv['full_name']?.toString() ?? 'Mwenyeji';
                final lastMessage = conv['last_message']?.toString() ?? '';
                final sentAt = conv['sent_at']?.toString();
                final isDoctor = conv['doctor'] == true;
                final unreadCount = conv['unread_count'] as int? ?? 0;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: unreadCount > 0 ? Colors.blue[50] : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(fullName.isNotEmpty ? fullName[0] : '?'),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(fullName)),
                        if (unreadCount > 0) ...[
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lastMessage),
                        if (sentAt != null)
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(DateTime.parse(sentAt)),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatPage(
                                otherUserId: conv['id'].toString(),
                                otherUserName: fullName,
                                isDoctor: isDoctor,
                              ),
                        ),
                      ).then((_) {
                        _loadUnreadCount();
                        if (mounted) setState(() {});
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () => _showNewChatDialog(context),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Anzisha Mazungumzo'),
            content: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.getDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Hakuna madaktari waliopo');
                }
                return SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final doctor = snapshot.data![index];
                      final fullName =
                          doctor['full_name']?.toString() ?? 'Daktari';
                      final specialty = doctor['specialty']?.toString() ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(fullName.isNotEmpty ? fullName[0] : 'D'),
                        ),
                        title: Text(fullName),
                        subtitle: Text(
                          specialty.isNotEmpty ? specialty : 'Daktari',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatPage(
                                    otherUserId: doctor['id'].toString(),
                                    otherUserName: fullName,
                                    isDoctor: true,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                child: Text('Funga'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
