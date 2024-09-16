import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../controllers/user_controllers.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final UserController userController = Get.find<UserController>();
  File? _selectedImage;
  String _selectedMaritalStatus = 'Single';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_emailController.text}.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
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
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedMaritalStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedMaritalStatus = value ?? 'Single';
                    });
                  },
                  items: ['Single', 'Married', 'Divorced', 'Widowed']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Marital Status'),
                ),
                SizedBox(height: 20),
                userController.isLoading.value
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              _fullNameController.text.isEmpty) {
                            Get.snackbar(
                                'Error', 'Please fill all required fields');
                            return;
                          }
                          String? profilePictureUrl;
                          if (_selectedImage != null) {
                            profilePictureUrl =
                                await _uploadImage(_selectedImage!);
                          }
                          userController.registerUser(
                            fullName: _fullNameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            profilePictureUrl: profilePictureUrl ?? '',
                            age: int.tryParse(_ageController.text) ?? 0,
                            gender: _genderController.text,
                            bio: _bioController.text,
                            maritalStatus: _selectedMaritalStatus,
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
