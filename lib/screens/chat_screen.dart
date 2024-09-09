import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/getdata_controller.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen(this.chatId);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _chatController;
  late final GetDataController userController;
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve controllers
    _chatController = Get.find<ChatController>();
    userController = Get.find<GetDataController>();

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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        }),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_image.png'), // Change to your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Chat content on top of the background image
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  var messages = _chatController.messages.value;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      bool isSentByMe = message['senderId'] == _chatController.currentUser;

                      return Align(
                        alignment: isSentByMe ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.white70 : Colors.blueAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['senderName'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                message['message'] ?? '',
                                style: TextStyle(
                                  color: isSentByMe ? Colors.blueAccent : Colors.white,
                                  fontWeight: isSentByMe ? FontWeight.bold : FontWeight.normal,
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
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          _chatController.sendMessage(widget.chatId, messageController.text);
                          messageController.clear();
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
