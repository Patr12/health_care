import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/utils/messaging_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getInt('userId') ?? 0;

      // Get recent conversations
      final conversations = await _dbHelper.getRecentConversations(
        _currentUserId,
      );

      // Get all doctors for doctors to message each other
      if (prefs.getString('userRole') == DatabaseHelper.ROLE_DOCTOR) {
        final doctors = await _dbHelper.getVerifiedDoctors();
        _contacts = [...conversations, ...doctors];
      } else {
        _contacts = conversations;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading contacts: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadContacts),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _contacts.isEmpty
              ? const Center(child: Text('No conversations yet'))
              : ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(contact['full_name']),
                    subtitle:
                        contact.containsKey('last_message')
                            ? Text(contact['last_message'])
                            : null,
                    trailing:
                        contact.containsKey('unread_count') &&
                                contact['unread_count'] > 0
                            ? CircleAvatar(
                              radius: 12,
                              child: Text(contact['unread_count'].toString()),
                            )
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MessagingScreen(
                                recipientId: int.parse(
                                  contact['id'].toString(),
                                ),
                                recipientName: contact['full_name'],
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
