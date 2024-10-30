import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../constants/constants.dart';
import '../models/ChatMessage.dart';
import '../models/chat_Models.dart';  

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createChatroom({
    required String currentUserId,
    required String userId,
  }) async {
    try {
      CollectionReference chatrooms = _firestore.collection(
        FirebaseCollectionNames.chatrooms,
      );

      final sortedMembers = [currentUserId, userId]..sort((a, b) => a.compareTo(b));

      QuerySnapshot existingChatrooms = await chatrooms
          .where('participants', isEqualTo: sortedMembers)
          .get();

      if (existingChatrooms.docs.isNotEmpty) {
        return existingChatrooms.docs.first.id;
      } else {
        final roomId = Uuid().v1();
        final now = DateTime.now();

        ChatRoom chatroom = ChatRoom(
          roomId: roomId,
          participants: sortedMembers,
          createdAt: Timestamp.fromDate(now),
          lastMessage: '',
          // lastMessageTs: Timestamp.fromDate(now),
        );

        await _firestore
            .collection(FirebaseCollectionNames.chatrooms)
            .doc(roomId)
            .set(chatroom.toMap());

        return roomId;
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Get all chat rooms
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(FirebaseCollectionNames.chatrooms).get();
      return snapshot.docs
          .map((doc) => ChatRoom.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching chat rooms: $e');
      throw e;
    }
  }

  // Delete a chat room by roomId
  Future<void> deleteChatRoom(String roomId) async {
    try {
      await _firestore.collection(FirebaseCollectionNames.chatrooms).doc(roomId).delete();
    } catch (e) {
      print('Error deleting chat room: $e');
      throw e;
    }
  }

  // Get messages stream for a chat room
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection(FirebaseCollectionNames.chatrooms)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message to a specific chat room
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    try {
      await _firestore
          .collection(FirebaseCollectionNames.chatrooms)
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Update last message and timestamp in the chat room document
      await _firestore.collection(FirebaseCollectionNames.chatrooms).doc(chatId).update({
        'lastMessage': message.message,
        'lastMessageTs': message.timestamp,
      });
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }
}
