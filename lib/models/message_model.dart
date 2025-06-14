class Message {
  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final String status;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.status = 'sent',
    this.isRead = false,
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
    };
  }

  Message copyWith({
    int? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    String? status,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
    );
  }
}
