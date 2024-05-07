import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retro/firebase_options.dart';
import '../../components/colors.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final FirebaseAuth auth = FirebaseAuth.instance;
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
  Future passwordReset() async {
      try {
        await auth.sendPasswordResetEmail(email: _emailController.text);
        print(_emailController.text);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
          print(e);
        }
        print(e);
      }
    }
  void _handleSendEmail() {
    // Simulate sending email with OTP code (replace with actual logic)
    setState(() {
      showEmailField = false;
      passwordReset();
    });
    

  }

  void _handleVerifyOtp() {
    // Simulate OTP verification (replace with actual logic)
    setState(() {
      showResetFields = true;
    });
  }

  void _handleResetPassword() {
    // Simulate password reset logic (replace with actual logic)
    Navigator.pop(context); // Close the modal after successful reset
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
        margin: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel, color: AppColors.systemGreayLight),
              ),
            ),
            Text(
              showEmailField
                  ? 'Forgot Password'
                  : (showResetFields
                      ? 'Reset Password'
                      : 'Forgot Password'), // Change title dynamically based on state
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
                    'We will send 4-digit code to your email for verification process.',
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
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Email address is not valid';
                        } else if (errorMessage.isNotEmpty) {
                          return errorMessage;
                        }
                        return null;
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
                              color: Colors.red), // Custom border color for validation error
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
                      onPressed:() async{
                        if (_formKey.currentState!.validate()) {
                          _handleSendEmail();
                        }
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
            Visibility(
              visible: !showEmailField &&
                  !showResetFields, // Show OTP section if flag is false
              child: Column(
                children: [
                  const Text(
                    'Enter the 4-digit code that you received on your email',
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
                        'OTP Code',
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
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                            color: AppColors.primaryColor.withOpacity(0.5)),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        //labelText: 'OTP Code', // Set label for OTP field
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      onPressed: _handleVerifyOtp, // Call function to verify OTP
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
            Visibility(
              visible:
                  showResetFields, // Show password reset fields if flag is true
              child: Column(
                children: [
                  const Text(
                    'Set the new password', // Change text after OTP verification
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    child: TextFormField(
                      obscureText: passwordVisibleOne, // Password field
                      controller: _passwordController,
                      validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter a password';
                            } else if (!passwordRegex.hasMatch(value)) {
                              return 'Password must contain at least 6 characters, including:\n'
                                  '• Uppercase\n'
                                  '• Lowercase\n'
                                  '• Numbers and special characters';
                            }
                            return null;
                     },
                      decoration: InputDecoration(
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
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    child: TextFormField(
                      obscureText: passwordVisibleTwo, // Confirm password field
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter a password';
                        } else if (value != _passwordController.text) {
                          return 'Password does not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
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
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  color: Colors
                                      .red), // Custom border color for validation error
                            ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Confirm Password',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _handleResetPassword, // Call function to reset password
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
