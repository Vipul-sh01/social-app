import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/getdata_controller.dart';
import 'editProfile_sceen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GetDataController userController = Get.find<GetDataController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    userController.fetchUserData();
    userController.fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (userController.errorMessage.isNotEmpty) {
          return Center(child: Text(userController.errorMessage.value));
        }

        if (userController.user.value != null) {
          var userData = userController.user.value!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: userController.selectedImage.value != null
                          ? FileImage(userController.selectedImage.value!)
                          : userController.profilePictureUrl.isNotEmpty
                          ? NetworkImage(userController.profilePictureUrl.first)
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name: ${userData.fullName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${userData.email}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Age: ${userData.age ?? 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bio: ${userData.bio ?? 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Marital status: ${userData.maritalStatus ?? 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final User? user = _auth.currentUser;
                        if (user != null) {
                          Get.to(() => EditProfileScreen());
                        } else {
                          Get.snackbar('Error', 'User is not logged in');
                        }
                      },
                      child: Text('Edit Profile'),
                    ),
                  ),
                  SizedBox(height: 20),
                  const Text(
                    'Images:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Obx(() {
                    if (userController.profilePictureUrl.isEmpty) {
                      return Text('No images available.');
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: userController.profilePictureUrl.length,
                      itemBuilder: (context, index) {
                        return Image.network(userController.profilePictureUrl[index]);
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        }

        return Center(child: Text('No user data available.'));
      }),
    );
  }
}
