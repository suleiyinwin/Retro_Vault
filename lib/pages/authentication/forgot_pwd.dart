import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:retro/firebase_options.dart';
import '../../components/colors.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _formKey = GlobalKey<FormState>();
  bool showEmailField = true; // Flag to control email field visibility
  bool showResetFields = false; // Flag to control password reset fields
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  String errorMessage = '';
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");
  bool passwordVisibleOne = false; //for eye icon
  bool passwordVisibleTwo = false; //for eye icon
  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void initState() {
    super.initState();
    passwordVisibleOne = true;
    passwordVisibleTwo = true;
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void dispode() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendEmail() {
    print('handle send');
    // Simulate sending email with OTP code (replace with actual logic)
    setState(() {
      showEmailField = false;
      showResetFields = true;
    });
  }

  void _handleResetPassword() {
    // Simulate password reset logic (replace with actual logic)
    Navigator.pop(context); // Close the modal after successful reset
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
          margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel,
                      color: AppColors.systemGreayLight),
                ),
              ),
              Text(
                showEmailField
                    ? 'Forgot Password'
                    : 'Reset Password', // Change title dynamically based on state
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: showEmailField, // Show email section if flag is true
                child: Column(
                  children: [
                    const Text(
                      'Write your email to reset the password',
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 17,
                            color: AppColors.textColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter an email address';
                          } else if (errorMessage.isNotEmpty) {
                            return errorMessage;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            errorMessage = '';
                          });
                        },
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color: AppColors.primaryColor.withOpacity(0.5)),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                                color: Colors
                                    .red), // Custom border color for validation error
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: 160,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              final collection = FirebaseFirestore.instance
                                  .collection(
                                      'user'); // Replace with your collection name
                              final snapshot = await collection
                                  .where('email',
                                      isEqualTo: _emailController.text.trim())
                                  .get();
                              if (snapshot.docs.isEmpty) {
                                errorMessage = 'No user found for that email.';
                                _formKey.currentState!
                                    .validate(); // This might not be necessary here
                                return;
                              }
                              //when user found in collection
                              else {
                                print('user found');
                                try {
                                  print('object');
                                  var email = _emailController.text.trim();
                                  print(email);
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                          email: _emailController.text.trim());
                                        
                                  Fluttertoast.showToast(
                                      msg: "Password reset link successfully sent to $email",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      webPosition: "center",
                                      webBgColor: '#D1D1D6',
                                      textColor: AppColors.primaryColor,
                                      fontSize: 16.0);

                                } on FirebaseAuthException catch (e) {
                                   if (e.code == 'user-not-found') {
                                     errorMessage = 'No user found for that email.';
                                   } else if (e.code == 'invalid-email') {
                                     errorMessage = 'Invalid email address.';
                                   } else {
                                     print("error: $e");
                                     errorMessage = e.code; // Set error message to error code
                                     print("error1: $errorMessage");
                                     _formKey.currentState!
                                         .validate(); // This might not be necessary here
                                     
                                   }
                                }
                                _handleResetPassword();
                                // _handleSendEmail();
                              }

                              _formKey.currentState!
                                  .validate(); // This might not be necessary here

                              // _handleSendEmail();

                              _formKey.currentState!
                                  .validate(); // This might not be necessary here
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                errorMessage = 'No user found for that email.';
                              } else if (e.code == 'invalid-email') {
                                errorMessage = 'Invalid email address.';
                              } else {
                                print("error: $e");
                                errorMessage =
                                    e.code; // Set error message to error code
                                print("error1: $errorMessage");
                                _formKey.currentState!
                                    .validate(); // This might not be necessary here
                              }
                            }
                            _formKey.currentState!.validate();
                          }
                          //_resetPassword(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
