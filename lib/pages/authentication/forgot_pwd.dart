import 'package:flutter/material.dart';
import 'package:retro/pages/authentication/otp_pwd.dart';

import '../../components/colors.dart';

class ForgotPwd extends StatefulWidget {
  const ForgotPwd({super.key});

  @override
  State<ForgotPwd> createState() => _ForgotPwdState();
}

class _ForgotPwdState extends State<ForgotPwd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Makes the popup full screen
      body: Container(
              height: MediaQuery.of(context).size.height, // Set height to half of screen
              // // Expand to bottom with full width
              // constraints: BoxConstraints(
              //   maxWidth: MediaQuery.of(context).size.width,
              //   maxHeight: MediaQuery.of(context).size.height,
              // ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(15.0),
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
                      child: Text('We will send 4-digit code to your email for verification process.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Email', 
                          style: TextStyle(                  
                            fontSize: 15,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
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
                        onPressed: () {
                          showDialog(
                                context: context,
                                builder: (context) => const OtpVerify(),
                              );
                        },
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
            // ),
          ),
    );  
  }
}