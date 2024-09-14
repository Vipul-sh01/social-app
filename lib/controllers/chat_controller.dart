import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/ChatMessage.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();

  // Observable list to hold messages (ChatMessage, not ChatRoom)
  var messages = <ChatMessage>[].obs;

  // Listen to messages for a specific chatId
  void listenToMessages(String chatId) {
    _chatService.messageStream(chatId).listen((snapshot) {
      // Map the documents to a list of ChatMessage objects
      messages.value = snapshot.docs.map((doc) {
        return ChatMessage(
          content: doc['content'],
          sender: doc['sender'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // Send a message using the chat service
  Future<void> sendMessage(String chatId, String message, TextEditingController textController) async {
    var currentUser = await _chatService.getCurrentUser();
    if (currentUser != null) {
      await _chatService.sendMessage(chatId, message, currentUser.email!);
      textController.clear();
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _chatService.signOut();
    Get.back();  // Use GetX for navigation instead of Navigator.pop(context)
  }
}
