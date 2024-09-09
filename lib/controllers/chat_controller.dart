import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_models.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  var messages = Rx<List<QueryDocumentSnapshot>>([]);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserModel currentUser;

  @override
  void onInit() {
    super.onInit();
    final User? user = _auth.currentUser;
    if (user != null) {
      currentUser = UserModel(
        email: user.email ?? '',
        fullName: user.displayName ?? '',
      );
    } else {
      Get.snackbar('Error', 'No user is currently logged in');
    }
  }

  void sendMessage(String chatId, String message) {
    if (currentUser.email != null) {
      _chatService.sendMessage(chatId, message, currentUser);
    } else {
      Get.snackbar('Error', 'User is not authenticated');
    }
  }

  void listenToMessages(String chatId) {
    _chatService.getMessages(chatId).listen((snapshot) {
      messages.value = snapshot.docs;
    }, onError: (error) {
      Get.snackbar('Error', 'Failed to load messages: $error');
    });
  }
}
