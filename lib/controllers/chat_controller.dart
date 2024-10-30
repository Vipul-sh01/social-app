import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../constants/constants.dart';
import '../constants/firebase_field_names.dart';
import '../models/ChatMessage.dart';
import '../models/chat_Models.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var chatRooms = <ChatRoom>[].obs;
  var messages = <ChatMessage>[].obs;
  RxString currentUserId = ''.obs;
  RxString friendId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChatRooms();
    setCurrentUserId();
  }

  void setCurrentUserId() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      currentUserId.value = currentUser.uid;
    }
  }

  Future<void> fetchChatRooms() async {
    try {
      List<ChatRoom> rooms = await _chatService.getChatRooms();
      chatRooms.value = rooms;
    } catch (e) {
      print('Error fetching chat rooms: $e');
    }
  }

  Future<void> addChatRoom(String friendUserId) async {
    try {
      if (currentUserId.isNotEmpty) {
        await _chatService.createChatroom(
          currentUserId: currentUserId.value,
          userId: friendUserId,
        );
        fetchChatRooms();
      } else {
        print('Current user ID is not set');
      }
    } catch (e) {
      print('Error adding chat room: $e');
    }
  }

  Future<void> deleteChatRoom(String roomId) async {
    try {
      await _chatService.deleteChatRoom(roomId);
      fetchChatRooms();
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  Future<String?> sendMessage({
    required String message,
    required String chatroomId,
    required String receiverId,
  }) async {
    try {
      final messageId = const Uuid().v1();
      final now = DateTime.now();

      ChatMessage newMessage = ChatMessage(
        message: message,
        messageId: messageId,
        senderId: currentUserId.value,
        receiverId: receiverId,
        timestamp: now,
        seen: false,
        messageType: 'text',
      );

      DocumentReference myChatroomRef = FirebaseFirestore.instance
          .collection(FirebaseCollectionNames.chatrooms)
          .doc(chatroomId);

      await myChatroomRef
          .collection(FirebaseCollectionNames.message)
          .doc(messageId)
          .set(newMessage.toMap());

      await myChatroomRef.update({
        FirebaseFieldNames.lastMessage: message,
        FirebaseFieldNames.lastMessageTs: Timestamp.fromDate(now).millisecondsSinceEpoch,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendFileMessage({
    required File file,
    required String chatroomId,
    required String receiverId,
    required String messageType,
  }) async {
    try {
      final messageId = const Uuid().v1();
      final now = DateTime.now();  // Use DateTime.now()

      Reference ref = _storage.ref(messageType).child(messageId);
      TaskSnapshot snapshot = await ref.putFile(file);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      ChatMessage newMessage = ChatMessage(
        message: downloadUrl,
        messageId: messageId,
        senderId: currentUserId.value,
        receiverId: receiverId,
        timestamp: now,
        seen: false,
        messageType: messageType,
      );

      DocumentReference myChatroomRef = FirebaseFirestore.instance
          .collection(FirebaseCollectionNames.chatrooms)
          .doc(chatroomId);

      await myChatroomRef
          .collection(FirebaseCollectionNames.message)
          .doc(messageId)
          .set(newMessage.toMap());

      await myChatroomRef.update({
        FirebaseFieldNames.lastMessage: 'Sent a $messageType',
        FirebaseFieldNames.lastMessageTs: Timestamp.fromDate(now).millisecondsSinceEpoch,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> seenMessage({
    required String chatroomId,
    required String messageId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionNames.chatrooms)
          .doc(chatroomId)
          .collection(FirebaseCollectionNames.message)
          .doc(messageId)
          .update({
        FirebaseFieldNames.seen: true,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
