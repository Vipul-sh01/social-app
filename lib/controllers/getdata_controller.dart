import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_models.dart';

class GetDataController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString errorMessage = ''.obs;
  final RxList<String> profilePictureUrl = <String>[].obs;
  final RxList<String> friendsList = <String>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchImages();
    fetchFriends();
  }

  Future<void> fetchImages() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      profilePictureUrl.value = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>?)?['profilePictureUrl'] as String?)
          .where((url) => url != null)
          .cast<String>()
          .toList();
    } catch (e) {
      showError('Failed to retrieve images: ${e.toString()}');
    }
  }

  Future<void> fetchFriends() async {
    isLoading.value = true;
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          var userModel = UserModel.fromDocumentSnapshot(userDoc);
          friendsList.value = userModel.friends; // Update friends list
        } else {
          showError('User document does not exist');
        }
      } else {
        showError('No user is signed in');
      }
    } catch (e) {
      showError("Failed to load friends: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(userId).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            user.value = UserModel.fromMap(data);
          } else {
            showError('User data is empty');
          }
        } else {
          showError('User document does not exist');
        }
      } else {
        Get.toNamed('/login'); // Redirect to login if no user
      }
    } catch (e) {
      showError('Failed to retrieve user data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showError(String message) {
    Get.snackbar('Error', message);
    errorMessage.value = message;
  }
}
