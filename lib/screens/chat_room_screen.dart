import 'package:app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/getdata_controller.dart';

class ChatScreenRoom extends StatefulWidget {
  final String roomId;
  ChatScreenRoom({required this.roomId});

  @override
  State<ChatScreenRoom> createState() => _ChatScreenRoomState();
}

class _ChatScreenRoomState extends State<ChatScreenRoom> {
  final GetDataController userController = Get.put(GetDataController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Room"),
      ),
      body: Obx(() {
        // Show loading indicator if data is still being fetched or not available
        if (userController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (userController.errorMessage.isNotEmpty) {
          return Center(child: Text(userController.errorMessage.value));
        }

        if (userController.user.value != null) {
          var user = userController.user.value!;

          return ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: userController.selectedImage.value != null
                      ? FileImage(userController.selectedImage.value!)
                      : userController.profilePictureUrl.isNotEmpty
                      ? NetworkImage(userController.profilePictureUrl.first)
                      : AssetImage('assets/default_profile.png')
                  as ImageProvider,
                ),
                title: Text(
                  'Name: ${user.fullName}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  // Handle user tap (open chat, etc.)
                  try {
                    final User? currentUser = _auth.currentUser;
                    if (currentUser != null) {
                      // Navigate to the ChatScreen passing the actual chatId
                      String chatId = "chatId";
                      Get.to(() => ChatScreen(chatId));
                    } else {
                      print("User is not logged in");
                    }
                  } catch (e) {
                    print("Error navigating to ChatScreen: $e");
                  }
                },
              ),
            ],
          );
        }

        // Return an empty container or placeholder if no user data
        return Center(child: Text("No user data available"));
      }),
    );
  }
}
