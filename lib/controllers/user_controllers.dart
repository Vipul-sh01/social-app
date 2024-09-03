import 'package:app/utility/ApiError.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_models.dart';
import '../utility/ApiResponce.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  final UserModel _userModel = UserModel();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<ApiResponse> registerUser(
      String fullName,
      String email,
      String password, {
        String? profilePictureUrl,
        int? age,
        String? gender,
        String? bio,
        String? maritalStatus,
      }) async {
    isLoading.value = true;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final userRef = firestore.collection('users').doc(email);

    try {
      if ([fullName, email, password].any((field) => field.trim().isEmpty)) {
        throw ApiError(statusCode: 400, message: "All fields are required");
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userData = {
        'fullName': fullName,
        'email': email,
        'profilePictureUrl': profilePictureUrl,
        'age': age,
        'gender': gender,
        'bio': bio,
        'maritalStatus': maritalStatus,
      };
      print(userData);
      await userRef.set(userData);

      return ApiResponse(
        statusCode: 201,
        message: 'User registered successfully',
        data: userCredential.user,
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
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Logout failed: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
