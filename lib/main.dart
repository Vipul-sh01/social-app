import 'package:app/screens/home_screens.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/register_screen.dart';
import 'package:app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/user_controllers.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final firebaseService = FirebaseService();
  runApp(MyApp(firebaseService: firebaseService));
}

class MyApp extends StatelessWidget {
  final FirebaseService firebaseService;
  MyApp({required this.firebaseService});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Social Media',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialBinding: BindingsBuilder(() {
        Get.put(UserController(firebaseService));
      }),
      getPages: [
        GetPage(name: '/', page: () =>LoginScreen()),
        GetPage(name: '/register', page: () =>RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }
}

