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

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      profilePictureUrl.value = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['profilePictureUrl'] as String?)
          .where((url) => url != null)
          .cast<String>()
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to retrieve images');
      errorMessage.value = 'Error retrieving images: ${e.toString()}';
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
            showError('User data not found');
          }
        } else {
          showError('User data not found');
        }
      } else {
        showError('No user signed in');
      }
    } catch (e) {
      showError('Failed to retrieve user');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentUser() async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        DocumentSnapshot docSnapshot = await _firestore.collection('users').doc(userId).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            user.value = UserModel.fromMap(data);
          } else {
            Get.toNamed('/login');
          }
        } else {
          Get.toNamed('/login');
        }
      } else {
        Get.toNamed('/login');
      }
    } catch (e) {
      errorMessage.value = "Failed to load user data: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  void showError(String message) {
    Get.snackbar('Error', message);
    errorMessage.value = message;
  }
}
