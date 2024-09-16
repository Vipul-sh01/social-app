import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controllers.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserController userController = Get.find<UserController>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String selectedMaritalStatus = 'Single';

  @override
  void initState() {
    super.initState();
    fullNameController.text = userController.userModel.value?.fullName ?? '';
    bioController.text = userController.userModel.value?.bio ?? '';
    selectedMaritalStatus = userController.userModel.value?.maritalStatus ?? 'Single';
  }

  @override
  void dispose() {
    fullNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedMaritalStatus,
              decoration: const InputDecoration(labelText: 'Marital Status'),
              items: ['Single', 'Married', 'Divorced', 'Widowed']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedMaritalStatus = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await userController.updateProfile(
                  fullName: fullNameController.text,
                  bio: bioController.text,
                  maritalStatus: selectedMaritalStatus,
                );
                Get.back();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
