import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health/chart/message_chat_page.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/models/message_model.dart';
import 'package:intl/intl.dart';

class PatientMessagesScreen extends StatefulWidget {
  final String doctorId;

  const PatientMessagesScreen({required this.doctorId, super.key});

  @override
  State<PatientMessagesScreen> createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  List<Message> _messages = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadPatientMessages();

    // Setup periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _loadPatientMessages(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPatientMessages() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final messages = await DatabaseHelper().getUnreadMessagesForDoctor(
        widget.doctorId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ujumbe kutoka kwa Wagonjwa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientMessages,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Hakuna ujumbe mpya'),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadPatientMessages,
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('P${index + 1}')),
                        title: Text(
                          'Mgonjwa ${message.senderId.substring(0, 6)}...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (message.urgency != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Chip(
                                  label: Text(
                                    message.urgency!.toUpperCase(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: _getUrgencyColor(
                                    message.urgency!,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          DateFormat('HH:mm').format(message.timestamp),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () async {
                          // Mark as read before opening
                          await DatabaseHelper().markMessagesAsRead(
                            message.senderId,
                            widget.doctorId,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PatientDoctorChatPage(
                                    currentUserId: widget.doctorId,
                                    currentUserName: 'Daktari',
                                    userRole: 'doctor',
                                    selectedPatientId: message.senderId,
                                  ),
                            ),
                          ).then((_) => _loadPatientMessages());
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red[100]!;
      case 'medium':
        return Colors.orange[100]!;
      case 'low':
        return Colors.green[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
