import 'package:app/screens/register_screen.dart';
import 'package:flutter/gestures.dart';
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
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Obx(() => userController.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      userController.loginUser(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
                    child: const Text("Login"),
                  )),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  print("Forgot Password tapped");
                  // Get.to(() => ForgotPasswordScreen());
                },
                child: const Text(
                  "Forgot Password",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 17.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Sign Up',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(() => RegisterScreen());
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => userController.errorMessage.isNotEmpty
                ? Text(
                    userController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
