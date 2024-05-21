import 'dart:async'; //needed to use Timer to set default time for loading screen
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'login.dart';
import '../../components/colors.dart'; // Assuming this file defines your app colors

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () => navigateToLogin(context));
  }

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: AppColors.primaryColor,
  //     body: Center(
  //       child: SingleChildScrollView(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             // Handle potential image loading errors
  //             Image.asset(
  //               'image/splashlogo.png', 
  //               errorBuilder: (context, error, stackTrace) {
  //                 return const Text('Error loading splash image'); // Placeholder
  //               },
  //             ),
  //             const SizedBox(height: 20.0), // Add space between image and loading indicator
  //             const SizedBox(
  //               width: 30.0, // overall width and height for circular loading indicator
  //               height: 30.0,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 1.0, //line thickness
  //                 color: AppColors.systemGreay04Light,
  //               ),
  //             ), 
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.primaryColor,
    body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Handle potential image loading errors
                Image.asset(
                  'image/splashlogo.png', 
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Error loading splash image'); // Placeholder
                  },
                ),
                const SizedBox(width: 10.0), // Add space between image and text
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child:  Text(
                    'Retro\nVault',
                    style: TextStyle(
                      fontSize: 24.0, // adjust font size as needed
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundColor, // adjust text color as needed
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0), // Add space between image and loading indicator
            const SizedBox(
              width: 30.0, // overall width and height for circular loading indicator
              height: 30.0,
              child: CircularProgressIndicator(
                strokeWidth: 1.0, //line thickness
                color: AppColors.systemGreay04Light,
              ),
            ), 
          ],
        ),
      ),
    ),
  );
}
  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}