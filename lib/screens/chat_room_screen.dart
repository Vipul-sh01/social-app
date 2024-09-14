// screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chatRoom_controller.dart';
import '../controllers/getdata_controller.dart';


class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatRoomController chatController = Get.put(ChatRoomController());
    final GetDataController userController = Get.put(GetDataController());

    return Scaffold(
      appBar: AppBar(title: Text('Select User to Chat')),
      body: Obx(
            () {
          return ListView.builder(
            itemCount: chatController.users.length,
            itemBuilder: (context, index) {
              final user = chatController.users[index];
              return ListTile(
                title: Text(user.name),
                onTap: () {
                  chatController.selectUser(user);
                  Get.snackbar('Selected User', user.name, snackPosition: SnackPosition.BOTTOM);
                },
              );
            },
          );
        },
      ),
    );
  }
}
