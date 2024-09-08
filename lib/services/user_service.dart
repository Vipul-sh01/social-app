import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_models.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> registerWithEmail(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user!.uid;
  }

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String> uploadProfileImage(File image, String userId) async {
    final storageRef = _storage.ref().child('profile_images').child('$userId.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> saveUserData(UserModel user, String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.set(user.toJson());
  }

  Future<String> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
