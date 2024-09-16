import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_models.dart';
import '../services/user_service.dart';
import '../utility/ApiResponce.dart';
import '../utility/ApiError.dart';

class UserController extends GetxController {
  final FirebaseService _firebaseService;

  // Reactive variables
  var selectedImage = Rx<File?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var userModel = Rx<UserModel?>(null);  // Assuming you're using this to track the user model

  // Constructor
  UserController(this._firebaseService);

  Future<void> pickImage() async {
    try {
      selectedImage.value = await _firebaseService.pickImage();
    } catch (e) {
      errorMessage.value = "Image selection failed: ${e.toString()}";
    }
  }

  Future<ApiResponse> registerUser({
    required String fullName,
    required String email,
    required String password,
    String? gender,
    int? age,
    String? bio,
    String? maritalStatus,
    String? profilePictureUrl,
  }) async {
    isLoading.value = true;
    try {
      // Validate required fields
      if ([fullName, email, password].any((field) => field.trim().isEmpty)) {
        throw ApiError(statusCode: 400, message: "All fields are required");
      }

      // Register user with email and password
      String userId = await _firebaseService.registerWithEmail(email, password);

      // Upload profile picture if selected
      if (selectedImage.value != null) {
        profilePictureUrl = await _firebaseService.uploadProfileImage(selectedImage.value!, userId);
      }

      // Create user model
      UserModel userModel = UserModel(
        fullName: fullName,
        email: email,
        password: password,  // Consider hashing the password before saving
        profilePictureUrl: profilePictureUrl,
        age: age,
        gender: gender,
        bio: bio,
        maritalStatus: maritalStatus,
      );

      // Save user data to Firestore under 'users' collection
      await _firebaseService.saveUserData(userModel, userId);

      // Navigate to home screen after successful registration
      Get.toNamed('/home');

      return ApiResponse(
        statusCode: 201,
        message: 'User registered successfully',
        data: null,
      );
    } catch (e) {
      final apiError = e is ApiError
          ? e
          : ApiError(statusCode: 500, message: e.toString());
      errorMessage.value = apiError.message;
      return ApiResponse(
        statusCode: apiError.statusCode,
        message: apiError.message,
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse> loginUser({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw ApiError(statusCode: 400, message: "Email and password are required");
      }

      String userId = await _firebaseService.loginWithEmail(email, password);
      Get.toNamed('/home');
      return ApiResponse(
        statusCode: 200,
        message: 'Login successful',
        data: userId,
      );
    } catch (e) {
      final apiError = e is ApiError
          ? e
          : ApiError(statusCode: 500, message: e.toString());
      errorMessage.value = apiError.message;
      return ApiResponse(
        statusCode: apiError.statusCode,
        message: apiError.message,
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserProfile() async {
    isLoading.value = true;
    try {
      var user = await _firebaseService.getCurrentUser();  // Get the current user from FirebaseService
      if (user != null) {
        DocumentSnapshot userDoc = await _firebaseService.getUserData(user.uid);
        userModel.value = UserModel.fromDocumentSnapshot(userDoc);
      }
    } catch (e) {
      errorMessage.value = "Failed to load user profile: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse> updateProfile({
    required String fullName,
    String? bio,
    String? gender,
    String? maritalStatus,
    File? profileImageFile, // Optional profile image file
  }) async {
    isLoading.value = true;
    try {
      var user = await _firebaseService.getCurrentUser();
      if (user == null) throw ApiError(statusCode: 401, message: "User not logged in");

      String? profilePictureUrl = userModel.value?.profilePictureUrl;

      // Handle profile picture upload if a new image is selected
      if (profileImageFile != null) {
        profilePictureUrl = await _firebaseService.uploadProfileImage(profileImageFile, user.uid);
      }

      // Update the user model
      userModel.value = UserModel(
        fullName: fullName,
        email: userModel.value?.email ?? '',  // Email remains unchanged here
        bio: bio ?? userModel.value?.bio,
        gender: gender ?? userModel.value?.gender,
        maritalStatus: maritalStatus ?? userModel.value?.maritalStatus,
        profilePictureUrl: profilePictureUrl,
      );

      // Update Firestore with the new user details
      await _firebaseService.updateUserData(user.uid, userModel.value!.toMap());

      // Return a success response
      return ApiResponse(
        statusCode: 200,
        message: 'Profile updated successfully',
        data: null,
      );
    } catch (e) {
      final apiError = e is ApiError
          ? e
          : ApiError(statusCode: 500, message: e.toString());
      errorMessage.value = apiError.message;
      return ApiResponse(
        statusCode: apiError.statusCode,
        message: apiError.message,
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutUser() async {
    isLoading.value = true;
    try {
      await _firebaseService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Logout failed: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
