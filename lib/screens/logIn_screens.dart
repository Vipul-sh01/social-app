import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controllers.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _maritalStatusController = TextEditingController();
  final TextEditingController _profilePictureUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _genderController,
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: _bioController,
                  decoration: InputDecoration(labelText: 'Bio'),
                ),
                TextField(
                  controller: _maritalStatusController,
                  decoration: InputDecoration(labelText: 'Marital Status'),
                ),
                // TextField(
                //   controller: _profilePictureUrlController,
                //   decoration: InputDecoration(labelText: 'Profile Picture URL'),
                // ),
                SizedBox(height: 20),
                userController.isLoading.value
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    userController.registerUser(
                      _fullNameController.text,
                      _emailController.text,
                      _passwordController.text,
                      // profilePictureUrl: _profilePictureUrlController.text,
                      age: int.tryParse(_ageController.text),
                      gender: _genderController.text,
                      bio: _bioController.text,
                      maritalStatus: _maritalStatusController.text,
                    );
                  },
                  child: Text('Register'),
                ),
                if (userController.errorMessage.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      userController.errorMessage.value,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
