import 'dart:async'; //needed to use Timer to set default time for loading screen
import 'package:flutter/material.dart';
import 'package:retro/pages/capsule_management/capsule_list.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/colors.dart'; // Assuming this file defines your app colors
import 'package:firebase_core/firebase_core.dart';
import 'package:retro/firebase_options.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
        Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    Timer(const Duration(seconds: 1), () => navigateToLogin(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Handle potential image loading errors
            Image.asset(
              'image/splashlogo.png',
              errorBuilder: (context, error, stackTrace) {
                return const Text('Error loading splash image'); // Placeholder
              },
            ),
            const SizedBox(
                height: 20.0), // Add space between image and loading indicator
            const SizedBox(
              width:
                  30.0, // overall width and height for circular loading indicator
              height: 30.0,
              child: CircularProgressIndicator(
                strokeWidth: 1.0, //line thickness
                color: AppColors.systemGreay04Light,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FirebaseAuth.instance.currentUser != null ? const HomeScreen() : const LoginPage()),
    );
  }
}
