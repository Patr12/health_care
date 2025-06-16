// First, create a Message model class (add this to your models folder)
class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String messageText;
  final DateTime sentAt;
  final bool isRead;
  final String? urgency;
  final String? medicalContext;
  final Map<String, dynamic>? patientInfo;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.sentAt,
    this.isRead = false,
     this.urgency,
    this.medicalContext,
    this.patientInfo
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      messageText: map['message_text'],
      sentAt: DateTime.parse(map['sent_at']),
      isRead: map['is_read'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message_text': messageText,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  static List<Message> fromList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Message.fromMap(map)).toList();
  }
}
