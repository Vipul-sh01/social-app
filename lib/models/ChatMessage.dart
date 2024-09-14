import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String content;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      content: map['content'] ?? '',
      sender: map['sender'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
