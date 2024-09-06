class UserModel {
  final String fullName;
  final String email;
  final String? profilePictureUrl;
  final int? age;
  final String? gender;
  final String? bio;
  final String? maritalStatus;

  UserModel({
    required this.fullName,
    required this.email,
    this.profilePictureUrl,
    this.age,
    this.gender,
    this.bio,
    this.maritalStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'age': age,
      'gender': gender,
      'bio': bio,
      'maritalStatus': maritalStatus,
    };
  }
}
