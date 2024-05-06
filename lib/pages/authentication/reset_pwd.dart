import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retro/pages/authentication/login.dart';

import '../../components/colors.dart';

class ResetPwd extends StatefulWidget {
  const ResetPwd({super.key});

  @override
  State<ResetPwd> createState() => _ResetPwdState();
}

class _ResetPwdState extends State<ResetPwd> {

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool passwordVisibleOne = false; //for eye icon
  bool passwordVisibleTwo = false; //for eye icon
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Makes the popup full screen
      body: Container(
        height: MediaQuery.of(context).size.height,
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
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(
                child: Text('Set the new password for your account.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                child: TextFormField(
                  obscureText: passwordVisibleOne,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter a password';
                    } else if (!passwordRegex.hasMatch(value)) {
                      return 'Password should contain at least 1 uppercase, 1 lowercase, 1 number and 1 special character and total length should be 6 characters.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: AppColors.primaryColor.withOpacity(0.5)),
                    prefixIcon: Padding(
                      padding:
                          const EdgeInsets.only(left: 35.0, right: 15.0),
                      child: Icon(Icons.lock_outline,
                          color: AppColors.primaryColor.withOpacity(0.5)),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: IconButton(
                          icon: Icon(
                            passwordVisibleOne
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisibleOne = !passwordVisibleOne;
                            });
                          }),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                          color: Colors
                              .red), // Custom border color for validation error
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .never, // Hide label when focused
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              // Confirm Password field
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 10.0),
                child: TextFormField(
                  obscureText: passwordVisibleTwo,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Your Passowrd Again';
                    } else if (value != _passwordController.text) {
                      return 'Password Do Not Match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(
                        color: AppColors.primaryColor.withOpacity(0.5)),
                    prefixIcon: Padding(
                      padding:
                          const EdgeInsets.only(left: 35.0, right: 15.0),
                      child: Icon(Icons.lock_outline,
                          color: AppColors.primaryColor.withOpacity(0.5)),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: IconButton(
                          icon: Icon(
                            passwordVisibleTwo
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisibleTwo = !passwordVisibleTwo;
                            });
                          }),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                          color: Colors
                              .red), // Custom border color for validation error
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior
                        .never, // Hide label when focused
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 160,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.backgroundColor,
                  ),
                  onPressed: () {},
                  child: const Text('Reset',
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
    );
  }
}