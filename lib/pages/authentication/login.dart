import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:retro/firebase_options.dart';
import 'package:retro/pages/authentication/forgot_pwd.dart';
import 'package:retro/pages/authentication/signup.dart';
import 'package:retro/pages/capsule_management/capsule_list.dart';

import '../../components/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");
  String errorMessage = '';
  String errorEmail = '';
  bool passwordVisible = false;
  List<Map<String, dynamic>> userDataList = [];
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void dispode() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Login';
    // final screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          // leading: const IconButton(
          //   icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          //   tooltip: 'Navigation menu',
          //   onPressed: null,
          // ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Image(image: AssetImage('image/logo.png')),
              ),
              const SizedBox(
                child: Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              // LoginForm widget definition within the same file
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          } else if (errorEmail.isNotEmpty) {
                            return errorEmail;
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: AppColors.primaryColor.withOpacity(0.5)),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.only(left: 35.0, right: 15.0),
                            child: Icon(Icons.email_outlined,
                                color: AppColors.primaryColor.withOpacity(0.5)),

                            //AppColors.primaryColor.withOpacity(0.5)),
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
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 10.0),
                      child: TextFormField(
                        obscureText: passwordVisible,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is requried';
                          } else if (errorMessage.isNotEmpty) {
                            return errorMessage;
                          } else if (!passwordRegex.hasMatch(value)) {
                            return 'Password must contain at least 6 characters, including:\n'
                                '• Uppercase\n'
                                '• Lowercase\n'
                                '• Numbers and special characters';
                          }
                          errorMessage = '';
                          return null;
                        },
                        onChanged: (value) => setState(() {
                          errorMessage = '';
                        }),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: AppColors.primaryColor.withOpacity(0.5)),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.only(left: 35.0, right: 15.0),
                            child: Icon(Icons.lock_outline,
                                color: AppColors.primaryColor.withOpacity(0.5)),
                            // AppColors.primaryColor.withOpacity(0.5)),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: IconButton(
                                icon: Icon(
                                  passwordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
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
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Colors.transparent;
                                  }
                                  if (states.contains(MaterialState.focused) ||
                                      states.contains(MaterialState.pressed)) {
                                    return Colors.transparent;
                                  }
                                  return null; // Defer to the widget's default.
                                },
                              ),
                            ),
                            onPressed: () {
                              // Handle forgot password logic
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  child: const ForgotPasswordModal(),
                                ),
                              );

                              print('Forgot password button pressed');
                            },
                            child: const Text('Forgot password?',
                                style:
                                    TextStyle(color: AppColors.primaryColor)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: 160.0,
                      height: 50.0,
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primaryColor, width: 1.0),
                          ),
                          onPressed: () async {
                            // Validate the form
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Sign in with email and password
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                                Fluttertoast.showToast(
                                    msg: "Account Login Successfully",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    webPosition: "center",
                                    webBgColor: '#D1D1D6',
                                    textColor: AppColors.primaryColor,
                                    fontSize: 16.0);
                                setState(() {
                                  errorMessage = '';
                                });
                                // If sign-in is successful, navigate to the home screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              } on FirebaseAuthException catch (e) {
                                // Handle specific errors
                                if (e.code == 'user-not-found') {
                                    errorMessage = 'User not found';
                                } else if (e.code == 'wrong-password') {
                                    errorMessage = 'Incorrect password';
                                 
                                } else {
                                    errorMessage = 'Error: ${e.message}';
                                }
                              } catch (e) {
                                // Handle generic errors
                                  errorMessage = 'Error: $e';
                              }
                            }
                            _formKey.currentState!.validate();
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          )),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text('Don\'t have an account?'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.transparent;
                                }
                                if (states.contains(MaterialState.focused) ||
                                    states.contains(MaterialState.pressed)) {
                                  return Colors.transparent;
                                }
                                return null; // Defer to the widget's default.
                              },
                            ),
                          ),
                          onPressed: () {
                            // Navigate to sign up page
                            //Navigator.pushNamed(context, '/signup');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Signup()),
                            );
                            // Handle sign up logic
                            print('Sign up button pressed');
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
