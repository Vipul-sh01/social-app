import 'package:app/screens/home_screens.dart';
import 'package:app/screens/logIn_screens.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialBinding: BindingsBuilder(() {
        Get.put(UserController(firebaseService));
      }),
      // Define named routes
      getPages: [
        GetPage(name: '/', page: () =>RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }
}

