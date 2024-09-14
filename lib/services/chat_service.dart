import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_Models.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  Future<User?> getCurrentUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }

  // Create or get a chat room
  Future<String> createOrGetChatRoom(String userId1, String userId2) async {
    String chatRoomId = getChatRoomId(userId1, userId2);

    // Check if chat room already exists
    DocumentSnapshot chatRoomSnapshot =
    await _firestore.collection('chatRooms').doc(chatRoomId).get();

    if (!chatRoomSnapshot.exists) {
      // If chat room doesn't exist, create a new one
      ChatRoom newChatRoom = ChatRoom(
        roomId: chatRoomId,
        participants: [userId1, userId2],
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .set(newChatRoom.toMap());
    }

    return chatRoomId;
  }

  String getChatRoomId(String userId1, String userId2) {
    // Simple logic to create a unique room ID based on user IDs
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';
  }

  // Method to send a message to the Firestore collection
  Future<void> sendMessage(String chatId, String message, String sender) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'content': message,
        'sender': sender,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Stream messages from Firestore
  Stream<QuerySnapshot> messageStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
