import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/getdata_controller.dart';
import '../models/ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen(this.chatId);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final ChatController _chatController;
  late final GetDataController userController;
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve controllers
    _chatController = Get.find<ChatController>();
    userController = Get.find<GetDataController>();

    // Start listening to messages and user data
    _chatController.listenToMessages(widget.chatId);
    userController.fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          var userData = userController.user.value;
          return Text(
            userData?.fullName ?? 'Loading...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        }),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  var messages = _chatController.messages.value;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      ChatMessage message = messages[index];
                      bool isSentByMe = message.sender == _auth.currentUser?.email; // Compare sender with current user's email

                      return Align(
                        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.blueAccent : Colors.white70,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.sender,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSentByMe ? Colors.white : Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isSentByMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Format timestamp for readability
                                "${message.timestamp.hour}:${message.timestamp.minute}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSentByMe ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Enter message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_auth.currentUser != null && messageController.text.isNotEmpty) {
                          _chatController.sendMessage(widget.chatId, messageController.text, messageController);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
