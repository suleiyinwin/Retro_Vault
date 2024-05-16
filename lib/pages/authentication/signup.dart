import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:retro/firebase_options.dart';
import 'package:retro/pages/authentication/login.dart';
import '../../components/colors.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool passwordVisibleOne = false; //for eye icon
  bool passwordVisibleTwo = false; //for eye icon
  final userNameRegx = RegExp(r'^[a-zA-Z0-9]+$');
  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");

  bool userCheckforIcon = false;
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Sign Up';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
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
                  'Create an account',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              // LoginForm widget definition within the same file
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username field
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: TextFormField(
                          //key: const Key('_usernameKey'),
                          controller: _usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter a username';
                            } else if (!userNameRegx.hasMatch(value)) {
                              userCheckforIcon = true;
                              return 'Username must contain only letters and numbers';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                                color: AppColors.primaryColor.withOpacity(0.5)),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(left: 35.0, right: 15.0),
                              child: Icon(Icons.account_circle_outlined,
                                  //color : userCheckforIcon ? Colors.red : AppColors.primaryColor.withOpacity(0.5)),
                                  color: AppColors.primaryColor.withOpacity(0.5)),
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
                      // Center(
                      //   child: Text(
                      //     errorMessage,
                      //     style: const TextStyle(color: Colors.red),
                      //   ),
                      // ),
                      const SizedBox(height: 15.0),
                      // Email field
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter an email address';
                            } else if (!emailRegex.hasMatch(value)) {
                              return 'Email address is not valid';
                            }
                            else if(errorMessage.isNotEmpty){
                              return errorMessage;
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
                      // Password field
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 10.0),
                        child: TextFormField(
                          obscureText: passwordVisibleOne,
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
                              return 'Password does Not Match';
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
                              final user = FirebaseAuth.instance.currentUser;
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                try {
                                  //creat user
                                  final credential = await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                  final user = credential.user;
                                  if (user != null) {
                                  //adding user detail
                                   try{
                                      FirebaseFirestore.instance
                                        .collection('user')
                                        .add({
                                      'firstName': '',
                                      'lastName': '',
                                      'username': _usernameController.text.trim(),
                                      'email': _emailController.text.trim(),
                                      'password': _passwordController.text.trim(),
                                      'userId': user.uid,
                                    }
                                    );
                                    setState(() {
                                      errorMessage = '';
                                    });
                
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const LoginPage()),
                                    );
                                   } 
                                   on FirebaseException catch (e) {
                                     setState(() {
                                        errorMessage = e.message!;
                                        
                                     });
                                   }                                  
                                    Fluttertoast.showToast(
                                        msg: "Account Created Successfully",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        webPosition: "center",
                                        webBgColor: '#D1D1D6',
                                        textColor: AppColors.primaryColor,
                                        fontSize: 16.0);
                                  }
                                  
                                } catch (e) {
                                  setState(() {
                                    errorMessage = e.toString();
                                  });
                                  _formKey.currentState!.validate();
                                }
                              }
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            )),
                      ),
                    ],
                  ),
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
                        child: Text('Already have an account?'),
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
                                  builder: (context) => const LoginPage()),
                            );
                            // Handle sign up logic
                          },
                          child: const Text('Login here',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor)),
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
