import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class ChatRoomController extends GetxController {
  var users = <User>[].obs; // Assuming 'User' is a model class you have defined

  @override
  void onInit() {
    super.onInit();
    // fetchUsers();

  }

  // void fetchUsers() async {
  //   // Simulate network delay
  //   await Future.delayed(Duration(seconds: 2));
  //
  //   // Update the users list
  //   users.value = fetchedUsers;
  // }

  // Method to add a user
  void addUser(User user) {
    users.add(user);
  }

  // Method to remove a user
  void removeUser(User user) {
    users.remove(user);
  }

// Add other methods to manage users if needed
}


