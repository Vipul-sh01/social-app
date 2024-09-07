import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../models/user_models.dart';
import '../services/user_service.dart';
import '../utility/ApiResponce.dart';
import '../utility/ApiError.dart';

class UserController extends GetxController {
  final FirebaseService _firebaseService;

  UserController(this._firebaseService);

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedImage = Rx<File?>(null);

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
    required String? profilePictureUrl,
  }) async {
    isLoading.value = true;
    try {
      // Validate inputs
      if ([fullName, email, password].any((field) => field.trim().isEmpty)) {
        throw ApiError(statusCode: 400, message: "All fields are required");
      }

      // Register user with FirebaseAuth
      String userId = await _firebaseService.registerWithEmail(email, password);

      // Upload profile image if selected
      String? profilePictureUrl;
      if (selectedImage.value != null) {
        profilePictureUrl = await _firebaseService.uploadProfileImage(selectedImage.value!, userId);
      }

      // Create a user model and save data to Firestore
      UserModel userModel = UserModel(
        fullName: fullName,
        email: email,
        profilePictureUrl: profilePictureUrl,
        age: age,
        gender: gender,
        bio: bio,
        maritalStatus: maritalStatus,
      );
      await _firebaseService.saveUserData(userModel, userId);
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
