import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controllers.dart';

class LoginScreen extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Obx(() => userController.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      userController.loginUser(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
                    child: Text("Login"),
                  )),
            Obx(() => userController.errorMessage.isNotEmpty
                ? Text(
                    userController.errorMessage.value,
                    style: TextStyle(color: Colors.red),
                  )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
