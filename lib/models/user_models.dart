import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? profilePictureUrl;
  String? fullName;
  int? age;
  String? gender;
  String? bio;
  String? maritalStatus;

  UserModel({
    this.profilePictureUrl,
    this.fullName,
    this.age,
    this.gender,
    this.bio,
    this.maritalStatus,
  });

  Future<User?> registerUser(String fullName, String email, String password, {
    String? profilePictureUrl,
    int? age,
    String? gender,
    String? bio,
    String? maritalStatus,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;


      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'profilePictureUrl': profilePictureUrl,
          'age': age,
          'gender': gender,
          'bio': bio,
          'maritalStatus': maritalStatus,
        });

        this.fullName = fullName;
        this.profilePictureUrl = profilePictureUrl;
        this.age = age;
        this.gender = gender;
        this.bio = bio;
        this.maritalStatus = maritalStatus;
      }

      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
