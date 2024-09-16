import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class FriendRequestScreen extends StatelessWidget {
  final FirebaseService firebaseService = Get.put(FirebaseService());

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No friend requests.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          List friendRequests = userData['friendRequests'] ?? [];

          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              String friendId = friendRequests[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> friendSnapshot) {
                  if (friendSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }
                  if (!friendSnapshot.hasData || friendSnapshot.data == null) {
                    return ListTile(title: Text('Friend data not found.'));
                  }

                  var friendData = friendSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                  String friendName = friendData['fullName'] ?? 'Unknown';

                  return ListTile(
                    title: Text(friendName),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await firebaseService.acceptFriendRequest(currentUserId, friendId);
                        Get.snackbar('Success', 'Friend request accepted from $friendName');
                      },
                      child: Text('Accept'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
