import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_models.dart';

class ChatService {
  final CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  Future<void> sendMessage(String chatId, String message, UserModel user) async {
    await chats.doc(chatId).collection('messages').add({
      'message': message,
      'senderId': user.email,
      'senderName': user.fullName,
      'senderProfilePicture': user.profilePictureUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return chats.doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots();
  }
}
