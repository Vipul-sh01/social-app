import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String roomId;
  final List<String> participants;
  final Timestamp createdAt;

  ChatRoom({
    required this.roomId,
    required this.participants,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'participants': participants,
      'createdAt': createdAt,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      roomId: map['roomId'] ?? '',
      participants: List<String>.from(map['participants']),
      createdAt: map['createdAt'],
    );
  }
}
// TODO Implement this library.