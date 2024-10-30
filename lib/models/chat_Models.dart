import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String roomId;
  final List<String> participants;
  final Timestamp createdAt;
  final String lastMessage;   // Add this field
  // final Timestamp lastMessageTs;  // Add this field

  ChatRoom({
    required this.roomId,
    required this.participants,
    required this.createdAt,
    required this.lastMessage,   // Add this parameter
    // required this.lastMessageTs, // Add this parameter
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'participants': participants,
      'createdAt': createdAt,
      'lastMessage': lastMessage,   // Add this entry
      // 'lastMessageTs': lastMessageTs, // Add this entry
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      roomId: map['roomId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: map['createdAt'] as Timestamp,
      lastMessage: map['lastMessage'] ?? '',   // Handle missing fields
      // lastMessageTs: map['lastMessageTs'] as Timestamp, // Handle missing fields
    );
  }
}
