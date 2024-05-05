import 'package:flutter/material.dart';
import '../../components/colors.dart';

class OtpVerify extends StatefulWidget {
  const OtpVerify({super.key});

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Makes the popup full screen
      body: Stack( // Stack for positioning close button on top
        children: [
          Center(
            child: Container(
              // Expand to bottom with full width
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: SingleChildScrollView( // Allow scrolling if content overflows
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Prevents content overflow within column
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel),
                      ),
                    ), // Prevents content overflow
                    const SizedBox(
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      child: Text('Enter 4-digit code that you received in your email.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text('OTP Code', 
                          style: TextStyle(                  
                            fontSize: 15,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'OTP Code',
                          labelStyle: TextStyle(
                            color: AppColors.primaryColor.withOpacity(0.5)),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 160,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.backgroundColor,
                        ),
                        onPressed: () {},
                        child: const Text('Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}