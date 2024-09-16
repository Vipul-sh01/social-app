import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Register user with email and password
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

  // Pick an image from the gallery
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

  // Upload profile image to Firebase Storage
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

  // Save user data to Firestore
  Future<void> saveUserData(UserModel userModel, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set(userModel.toJson());
      print('User data successfully written to Firestore');
    } catch (e) {
      print('Failed to write user data: ${e.toString()}');
      throw Exception('Error writing user data');
    }
  }

  // Login user with email and password
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

  // Send a friend request
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    try {
      DocumentReference targetUserRef = _firestore.collection('users').doc(targetUserId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot targetUserSnapshot = await transaction.get(targetUserRef);
        if (targetUserSnapshot.exists) {
          List<dynamic> friendRequests = List.from(targetUserSnapshot['friendRequests'] ?? []);
          if (!friendRequests.contains(currentUserId)) {
            friendRequests.add(currentUserId);
            transaction.update(targetUserRef, {'friendRequests': friendRequests});
          }
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to send friend request: $e");
    }
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(String currentUserId, String targetUserId) async {
    try {
      DocumentReference currentUserRef = _firestore.collection('users').doc(currentUserId);
      DocumentReference targetUserRef = _firestore.collection('users').doc(targetUserId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot = await transaction.get(currentUserRef);
        DocumentSnapshot targetUserSnapshot = await transaction.get(targetUserRef);

        if (currentUserSnapshot.exists && targetUserSnapshot.exists) {
          List<dynamic> currentUserRequests = List.from(currentUserSnapshot['friendRequests'] ?? []);
          List<dynamic> currentUserFriends = List.from(currentUserSnapshot['friends'] ?? []);
          List<dynamic> targetUserFriends = List.from(targetUserSnapshot['friends'] ?? []);

          if (currentUserRequests.contains(targetUserId)) {
            // Add to friends lists and remove from friendRequests
            currentUserFriends.add(targetUserId);
            transaction.update(currentUserRef, {
              'friends': currentUserFriends,
              'friendRequests': FieldValue.arrayRemove([targetUserId]),
            });

            targetUserFriends.add(currentUserId);
            transaction.update(targetUserRef, {'friends': targetUserFriends});
          }
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to accept friend request: $e");
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout failed: ${e.toString()}');
      throw Exception('Logout failed');
    }
  }
}
