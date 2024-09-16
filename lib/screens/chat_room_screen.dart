import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_Models.dart'; // Make sure this path is correct

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  ChatRoomPage({required this.roomId}); // Updated the constructor name

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Obx(() {
        if (chatController.chatRooms.isEmpty) {
          return Center(child: Text('No chat rooms available'));
        } else {
          return ListView.builder(
            itemCount: chatController.chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatController.chatRooms[index];
              return ListTile(
                title: Text(chatRoom.roomId),
                subtitle: Text('Participants: ${chatRoom.participants.join(", ")}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => chatController.deleteChatRoom(chatRoom.roomId),
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new chat room logic here
          ChatRoom newChatRoom = ChatRoom(
            roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
            participants: ['user1', 'user2'],
            createdAt: Timestamp.now(),
          );
          chatController.addChatRoom(newChatRoom);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
