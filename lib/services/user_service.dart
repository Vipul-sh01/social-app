import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      print('Failed to register: ${e.toString()}');
      throw Exception('Registration failed');
    }
  }

  Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      print('Failed to pick image: ${e.toString()}');
      throw Exception('Image picking failed');
    }
  }

  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      final storageRef = _storage.ref().child('profile_images').child('$userId.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Failed to upload profile image: ${e.toString()}');
      throw Exception('Profile image upload failed');
    }
  }

  Future<void> saveUserData(UserModel userModel, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set(userModel.toJson());
      print('User data successfully written to Firestore');
    } catch (e) {
      print('Failed to write user data: ${e.toString()}');
      throw Exception('Error writing user data');
    }
  }

  Future<String> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      print('Login failed: ${e.toString()}');
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout failed: ${e.toString()}');
      throw Exception('Logout failed');
    }
  }
}