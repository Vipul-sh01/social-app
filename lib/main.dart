// lib/main.dart
import 'package:app/screens/home_screens.dart';
import 'package:app/screens/logIn_screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/user_controllers.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(UserController());
      }),
      home: RegisterScreen(),
      getPages: [
        GetPage(name: '/home', page: () => HomeScreen()),
        // Add more routes here
      ],
    );
  }
}
