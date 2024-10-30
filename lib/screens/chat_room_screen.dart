import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/getdata_controller.dart';
import 'chat_screen.dart'; // Ensure this path is correct

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  ChatRoomPage({required this.roomId});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatController chatController = Get.put(ChatController());
  final GetDataController userController = Get.find<GetDataController>();

  @override
  void initState() {
    super.initState();
    chatController.fetchChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Column(
        children: [
          // List of Chat Rooms
          Expanded(
            child: Obx(() {
              if (chatController.chatRooms.isEmpty) {
                return Center(child: Text('No chat rooms available'));
              } else {
                return ListView.builder(
                  itemCount: chatController.chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatController.chatRooms[index];
                    return ListTile(
                      title: Text('Chat Room: ${chatRoom.roomId}'),
                      subtitle: Text(
                          'Participants: ${chatRoom.participants.join(", ")}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            chatController.deleteChatRoom(chatRoom.roomId),
                      ),
                      onTap: () {
                        String chatId = "ChatId"; // Replace with the actual chat ID
                        Get.to(() => ChatScreen(chatId));
                      },
                    );
                  },
                );
              }
            }),
          ),
          // List of Friends to Add Chat Room
          Expanded(
            child: Obx(() {
              if (userController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (userController.friendsList.isEmpty) {
                return Center(child: Text('No friends found.'));
              }

              return ListView.builder(
                itemCount: userController.friendsList.length,
                itemBuilder: (context, index) {
                  final friendId = userController.friendsList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(friendId[0].toUpperCase()),
                    ),
                    title: Text(friendId),
                    onTap: () async {
                      await chatController.addChatRoom(friendId);
                      Get.snackbar('Chat Room', 'Chat room created with $friendId');
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Option to add a new chat room with a friend
          if (userController.friendsList.isNotEmpty) {
            String friendId = userController.friendsList.first; // Just as an example
            chatController.addChatRoom(friendId);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
