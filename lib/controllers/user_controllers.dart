import 'dart:io';
import 'package:get/get.dart';
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
    String? profilePictureUrl,
  }) async {
    isLoading.value = true;
    try {
      if ([fullName, email, password].any((field) => field.trim().isEmpty)) {
        throw ApiError(statusCode: 400, message: "All fields are required");
      }

      String userId = await _firebaseService.registerWithEmail(email, password);

      if (selectedImage.value != null) {
        profilePictureUrl = await _firebaseService.uploadProfileImage(selectedImage.value!, userId);
      }

      UserModel userModel = UserModel(
        fullName: fullName,
        email: email,
        password: password,
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
