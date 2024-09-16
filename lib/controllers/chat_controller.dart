import 'package:firebase_auth/firebase_auth.dart'; // Added FirebaseAuth import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ChatMessage.dart';
import '../models/chat_Models.dart';  // Assuming you have ChatRoom and ChatMessage models here
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  // Observable list of chat rooms
  var chatRooms = <ChatRoom>[].obs;

  // Observable list of messages for the selected chat room
  var messages = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChatRooms(); // Fetch chat rooms on initialization
  }

  // Fetch chat rooms from Firestore and update the observable list
  Future<void> fetchChatRooms() async {
    try {
      List<ChatRoom> rooms = await _chatService.getChatRooms();
      chatRooms.value = rooms;
    } catch (e) {
      print('Error fetching chat rooms: $e');
    }
  }

  // Add a new chat room
  Future<void> addChatRoom(ChatRoom chatRoom) async {
    try {
      await _chatService.createChatRoom(chatRoom);
      fetchChatRooms(); // Refresh chat rooms after adding
    } catch (e) {
      print('Error adding chat room: $e');
    }
  }

  // Delete a chat room
  Future<void> deleteChatRoom(String roomId) async {
    try {
      await _chatService.deleteChatRoom(roomId);
      fetchChatRooms(); // Refresh chat rooms after deleting
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  // Listen to messages in a specific chat room
  void listenToMessages(String chatId) {
    _chatService.getMessages(chatId).listen((snapshot) {
      var newMessages = snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      messages.value = newMessages; // Update the observable list of messages
    });
  }

  // Send a message to the chat room
  Future<void> sendMessage(String chatId, String messageContent, TextEditingController messageController) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        ChatMessage message = ChatMessage(
          sender: currentUser.email ?? 'Unknown',
          senderName: currentUser.displayName ?? 'Unknown', // Pass the user's display name
          content: messageContent,
          timestamp: DateTime.now(),
        );
        await _chatService.sendMessage(chatId, message);
        messageController.clear(); // Clear the text field after sending the message
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
