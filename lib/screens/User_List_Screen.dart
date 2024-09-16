import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_service.dart';

class UserListScreen extends StatelessWidget {
  final FirebaseService firebaseService = Get.put(FirebaseService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var user = snapshot.data!.docs[index];
              var userId = user.id;
              var userName = user['fullName']; // Assuming you have a name field

              return ListTile(
                title: Text(userName),
                trailing: ElevatedButton(
                  onPressed: () async {
                    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                    await firebaseService.sendFriendRequest(currentUserId, userId);
                    Get.snackbar('Success', 'Friend request sent to $userName');
                  },
                  child: Text('Add Friend'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
