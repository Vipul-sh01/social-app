import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ChatMessage.dart';
import '../models/chat_Models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new chat room
  Future<void> createChatRoom(ChatRoom chatRoom) async {
    try {
      await _firestore.collection('chatRooms').doc(chatRoom.roomId).set(chatRoom.toMap());
    } catch (e) {
      print('Error creating chat room: $e');
      throw e;
    }
  }

  // Get all chat rooms
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('chatRooms').get();
      return snapshot.docs.map((doc) => ChatRoom.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching chat rooms: $e');
      throw e;
    }
  }

  // Delete a chat room by roomId
  Future<void> deleteChatRoom(String roomId) async {
    try {
      await _firestore.collection('chatRooms').doc(roomId).delete();
    } catch (e) {
      print('Error deleting chat room: $e');
      throw e;
    }
  }
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    await _firestore
        .collection('chatRooms')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }
}
