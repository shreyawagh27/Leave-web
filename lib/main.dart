import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/view/home_page.dart';
import 'package:flutter_application_1/view/leave_request.dart';


import 'view/home_page.dart';
import 'view/login_page.dart';
import 'view/registration_page.dart';
import 'view/submit_request.dart'; 
import 'view/leave_request.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyBqa-Et-jw09v0Q-WxvEseY5yC0F0YSwyU", appId: "1:180004725321:android:fface69b363e00c46a9598", messagingSenderId: "180004725321", projectId:"leaveapp-ec9c7")); 
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, 

      home: MyWidget (),
      

    );
  }
}

