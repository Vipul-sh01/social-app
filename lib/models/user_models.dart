class UserModel {
  String? fullName;
  String? email;
  String? password;
  String? profilePictureUrl;
  int? age;
  String? gender;
  String? bio;
  String? maritalStatus;

  UserModel({
    this.fullName,
    this.email,
    this.password,
    this.profilePictureUrl,
    this.age,
    this.gender,
    this.bio,
    this.maritalStatus,
  });

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'profilePictureUrl': profilePictureUrl,
      'age': age,
      'gender': gender,
      'bio': bio,
      'maritalStatus': maritalStatus,
    };
  }
}
