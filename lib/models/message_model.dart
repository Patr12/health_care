// models/message.dart
import 'dart:convert';

class Message {
  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final String status;
  final bool isRead;
  final String? urgency;
  final String? medicalContext;
  final Map<String, dynamic>? patientInfo;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.status = 'sent',
    this.isRead = false,
    this.urgency,
    this.medicalContext,
    this.patientInfo,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      senderId: map['sender_id'].toString(),
      receiverId: map['receiver_id'].toString(),
      content: map['content'].toString(),
      timestamp: DateTime.parse(map['timestamp'].toString()),
      status: map['status']?.toString() ?? 'sent',
      isRead: map['is_read'] == 1,
      urgency: map['urgency'],
      medicalContext: map['medical_context'],
      patientInfo: map['patient_info'] != null 
          ? jsonDecode(map['patient_info'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'is_read': isRead ? 1 : 0,
      'urgency': urgency,
      'medical_context': medicalContext,
      'patient_info': patientInfo != null ? jsonEncode(patientInfo) : null,
    };
  }
}