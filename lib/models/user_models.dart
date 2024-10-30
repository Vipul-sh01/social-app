import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? fullName;
  String? email;
  String? password;
  String? profilePictureUrl;
  int? age;
  String? gender;
  String? bio;
  String? maritalStatus;
  List<String> friends;
  List<String> friendRequests;
  List<String> sentRequests;

  UserModel({
    this.fullName,
    this.email,
    this.password,
    this.profilePictureUrl,
    this.age,
    this.gender,
    this.bio,
    this.maritalStatus,
    this.friends = const [],
    this.friendRequests = const [],
    this.sentRequests = const [],
  });

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return UserModel(
      email: data?['email'] as String?,
      fullName: data?['fullName'] as String?,
      profilePictureUrl: data?['profilePictureUrl'] as String?,
      friends: List<String>.from(data?['friends'] ?? []),
      friendRequests: List<String>.from(data?['friendRequests'] ?? []),
      sentRequests: List<String>.from(data?['sentRequests'] ?? []),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map['fullName'] as String?,
      email: map['email'] as String?,
      password: map['password'] as String?,
      profilePictureUrl: map['profilePictureUrl'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      bio: map['bio'] as String?,
      maritalStatus: map['maritalStatus'] as String?,
      friends: List<String>.from(map['friends'] ?? []),
      friendRequests: List<String>.from(map['friendRequests'] ?? []),
      sentRequests: List<String>.from(map['sentRequests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password, // You should hash the password before saving
      'profilePictureUrl': profilePictureUrl,
      'age': age,
      'gender': gender,
      'bio': bio,
      'maritalStatus': maritalStatus,
      'friends': friends,
      'friendRequests': friendRequests,
      'sentRequests': sentRequests,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap(); 
  }
}
