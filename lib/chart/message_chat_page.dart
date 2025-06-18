import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/models/message_model.dart';
import 'package:health/models/user_model.dart';

class PatientDoctorChatPage extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String userRole;
  final String? selectedPatientId;
  final String? selectedPatientName;

  const PatientDoctorChatPage({
    required this.currentUserId,
    required this.currentUserName,
    required this.userRole,
    this.selectedPatientId,
    this.selectedPatientName,
    super.key,
  });

  @override
  State<PatientDoctorChatPage> createState() => _PatientDoctorChatPageState();
}

class _PatientDoctorChatPageState extends State<PatientDoctorChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  User? _selectedDoctor;
  List<User> _availableDoctors = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _selectedUrgency;
  String? _selectedContext;

  @override
  void initState() {
    super.initState();
    if (widget.selectedPatientId != null) {
      _selectedDoctor = User(
        id: widget.selectedPatientId!,
        name: widget.selectedPatientName ?? 'patient',
        role: 'patient',
      );
      _loadMessages();
    } else {
      _loadAvailableDoctors();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableDoctors() async {
    try {
      final dbHelper = DatabaseHelper();
      List<User> doctors = [];

      if (widget.userRole == 'patient') {
        doctors = await dbHelper.getDoctorsForPatient(widget.currentUserId);
      } else if (widget.userRole == 'doctor') {
        // For doctors viewing their patients
        doctors = await dbHelper.getPatientsForDoctor(widget.currentUserId);
      }

      setState(() {
        _availableDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading doctors: $e');
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load doctors list');
    }
  }

  Future<void> _selectDoctor() async {
    final selectedDoctor = await showDialog<User>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chagua Daktari'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  _availableDoctors.isEmpty
                      ? const Center(child: Text('Hakuna madaktari waliopo'))
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _availableDoctors[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(doctor.name.substring(0, 1)),
                            ),
                            title: Text(doctor.name),
                            subtitle: FutureBuilder(
                              future: DatabaseHelper().getDoctorProfile(
                                int.parse(doctor.id),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data!['specialty'] ??
                                        'Daktari wa Jumla',
                                  );
                                }
                                return const Text('Daktari wa Jumla');
                              },
                            ),
                            onTap: () => Navigator.pop(context, doctor),
                          );
                        },
                      ),
            ),
          ),
    );

    if (selectedDoctor != null) {
      // Weka uhusiano kati ya mgonjwa na daktari
      await DatabaseHelper().linkPatientWithDoctor(
        widget.currentUserId,
        selectedDoctor.id,
      );

      setState(() => _selectedDoctor = selectedDoctor);
      await _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_selectedDoctor == null) return;

    setState(() => _isLoading = true);

    try {
      final messages = await DatabaseHelper().getMessagesBetweenUsers(
        widget.currentUserId,
        _selectedDoctor!.id,
      );

      // Mark messages as read if this is the recipient
      if ((widget.userRole == 'doctor' &&
              messages.any((m) => m.senderId != widget.currentUserId)) ||
          (widget.userRole == 'patient' &&
              messages.any((m) => m.senderId != widget.currentUserId))) {
        await DatabaseHelper().markMessagesAsRead(
          widget.currentUserId,
          _selectedDoctor!.id,
        );
      }

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
    if (_messageController.text.trim().isEmpty || _selectedDoctor == null)
      return;
    if (_isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();
    setState(() => _isSending = true);

    // Get patient info if sender is a patient
    Map<String, dynamic>? patientInfo;
    if (widget.userRole == 'patient') {
      patientInfo = await DatabaseHelper().getPatientBasicInfo(
        widget.currentUserId,
      );
    }

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: widget.currentUserId,
      receiverId: _selectedDoctor!.id,
      content: content,
      timestamp: DateTime.now(),
      status: 'sent', // Changed from 'pending' to 'sent'
      urgency: _selectedUrgency,
      medicalContext: _selectedContext,
      patientInfo: patientInfo,
    );

    setState(() => _messages = [..._messages, newMessage]);
    _scrollToBottom();

    try {
      final messageId = await DatabaseHelper().insertMessage(newMessage);

      // Update the message with the ID from database
      setState(() {
        _messages =
            _messages.map((msg) {
              return msg.id == newMessage.id
                  ? msg.copyWith(id: messageId)
                  : msg;
            }).toList();
      });

      // Reload messages to ensure sync
      await _loadMessages();
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() {
        _messages =
            _messages.map((msg) {
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

  Widget _buildMedicalMessageBubble(Message message) {
    final isFromMe = message.senderId == widget.currentUserId;
    final showPatientInfo =
        message.patientInfo != null && !isFromMe && widget.userRole == 'doctor';

    return Column(
      crossAxisAlignment:
          isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showPatientInfo) _buildPatientInfoCard(message.patientInfo!),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment:
                isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isFromMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    _selectedDoctor!.name.substring(0, 1),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFromMe ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isFromMe ? 12 : 0),
                      bottomRight: Radius.circular(isFromMe ? 0 : 12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isFromMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      if (!isFromMe)
                        Text(
                          _selectedDoctor!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      Text(message.content),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('hh:mm a').format(message.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (isFromMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.status == 'read'
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 14,
                              color:
                                  message.status == 'read'
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfoCard(Map<String, dynamic> patientInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PATIENT MEDICAL INFORMATION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Name', patientInfo['name'] ?? 'N/A'),
          _buildInfoRow('Age', patientInfo['age']?.toString() ?? 'N/A'),
          _buildInfoRow('Blood Type', patientInfo['bloodType'] ?? 'N/A'),
          _buildInfoRow('Last Visit', patientInfo['lastCheckup'] ?? 'N/A'),
          if (patientInfo['allergies'] != null)
            _buildInfoRow('Allergies', patientInfo['allergies']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildMedicalMessageInput() {
    return Column(
      children: [
        if (widget.userRole == 'patient') ...[
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Urgency Level',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  value: _selectedUrgency,
                  items: [
                    DropdownMenuItem(
                      value: 'low',
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Low Priority'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Medium Priority'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('High Priority - Emergency'),
                        ],
                      ),
                    ),
                  ],
                  onChanged:
                      (value) => setState(() => _selectedUrgency = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Message Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  value: _selectedContext,
                  items: const [
                    DropdownMenuItem(
                      value: 'general',
                      child: Text('General Question'),
                    ),
                    DropdownMenuItem(
                      value: 'symptoms',
                      child: Text('Symptoms Report'),
                    ),
                    DropdownMenuItem(
                      value: 'prescription',
                      child: Text('Prescription Query'),
                    ),
                    DropdownMenuItem(
                      value: 'appointment',
                      child: Text('Appointment Request'),
                    ),
                  ],
                  onChanged:
                      (value) => setState(() => _selectedContext = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText:
                      widget.userRole == 'patient'
                          ? 'Describe your medical concern...'
                          : 'Type your response...',
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
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.send, size: 24),
              color: Colors.blue,
              onPressed: _sendMessage,
            ),
          ],
        ),
      ],
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _retryMessage(Message message) async {
    setState(() {
      _messages =
          _messages.map((msg) {
            return msg.id == message.id ? msg.copyWith(status: 'pending') : msg;
          }).toList();
    });

    await _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _selectedDoctor == null
                ? Text(
                  widget.userRole == 'patient'
                      ? 'Select Doctor'
                      : 'Select Patient',
                )
                : Text(
                  widget.userRole == 'patient'
                      ? 'Dr. ${_selectedDoctor!.name}'
                      : 'Patient: ${_selectedDoctor!.name}',
                ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _selectDoctor,
            tooltip: 'Select doctor',
          ),
          if (_selectedDoctor != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMessages,
              tooltip: 'Refresh messages',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading && _messages.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_selectedDoctor == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.userRole == 'patient'
                          ? Icons.medical_services
                          : Icons.person,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.userRole == 'patient'
                          ? 'No doctor selected'
                          : 'No patient selected',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _selectDoctor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        widget.userRole == 'patient'
                            ? 'Select a doctor to consult'
                            : 'Select a patient',
                      ),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: _buildMedicalMessageBubble(_messages[index]),
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildMedicalMessageInput(),
          ),
        ],
      ),
    );
  }
}
