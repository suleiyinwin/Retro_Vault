import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:retro/firebase_options.dart';
import 'package:retro/pages/authentication/forgot_pwd.dart';
import 'package:retro/pages/authentication/singup.dart';

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
    return GetMaterialApp(
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
                          } 
                          else if(errorEmail.isNotEmpty){
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
                                color:  AppColors.primaryColor.withOpacity(0.5)),
        
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
                          }
                          else if(errorMessage.isNotEmpty){
                            return errorMessage;
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
                                // AppColors.primaryColor.withOpacity(0.5)),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: IconButton(
                                icon: Icon(
                                  passwordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_off_outlined,
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
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => const ForgotPwd(),
                                // isScrollControlled: true,
                              );
                              // Handle forgot password logic
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
                            if(_formKey.currentState!.validate()){
                              _formKey.currentState!.save();
                              try{
                              CollectionReference users = FirebaseFirestore.instance.collection('user');
                              QuerySnapshot querySnapshot = await users.get();
                              for (final doc in querySnapshot.docs){
                              print(doc.data());
                              final userData = doc.data();
                              final email = doc['email'];
                              final password =  doc['password'];
                              print('$email, $password testing heee');
                              if (email == _emailController.text && password == _passwordController.text){
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
                                break;
                              }
                              
                              // else if(email == _emailController.text && password != _passwordController.text){
                                
                              //     errorMessage = 'Incorrect Password';
                              //   break;
                              // }
                              // else if(email != _emailController.text && password == _passwordController.text){
                              //   //setState(() {
                              //     errorMessage = 'Incorrect Email';
                              //     break;
                              //   //});
                              // }
                              else {
                                Fluttertoast.showToast(
                                msg: "Have you created an account?",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                webPosition: "center",
                                webBgColor: '#D1D1D6',
                                textColor: AppColors.primaryColor,
                                fontSize: 16.0);
                                break;
                              }
                              //print(email);
                            }
                          }
                              on FirebaseAuthException catch (e){
                               setState(() {
                                errorMessage = e.message!;
                               });
                              }
                              
                              
                            }
                            

                            // Handle sign up logic
                            print('Sign up button pressed');
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
