import 'package:app/screens/chat_room_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Profile_screen.dart';



class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bg3.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () async {
                try {
                  final User? user = _auth.currentUser;
                  if (user != null) {
                    Get.to(() => ProfileScreen());
                  } else {
                    print("User is not logged in");
                  }
                } catch (e) {
                  print("Error navigating to Profile: $e");
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.messenger_outline_outlined),
              onPressed: () async {
                try {
                  final User? user = _auth.currentUser;
                  if (user != null) {
                    String roomId = "roomId";
                    Get.to(()=> ChatScreenRoom(roomId: roomId));
                  } else {
                    print("User is not logged in");
                  }
                } catch (e) {
                  print("Error navigating to ChatScreen: $e");
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your floating action button action here
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
