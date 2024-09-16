import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String sender;
  final String senderName; // Add this field
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.senderName, // Add it to the constructor
    required this.content,
    required this.timestamp,
  });

  // Convert a ChatMessage to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'senderName': senderName, // Include this in the map
      'content': content,
      'timestamp': timestamp,
    };
  }

  // Create a ChatMessage from a Firestore Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      sender: map['sender'],
      senderName: map['senderName'] ?? '', // Retrieve 'senderName' or provide a default value
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
