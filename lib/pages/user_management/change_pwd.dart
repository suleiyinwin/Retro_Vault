import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:retro/components/colors.dart';

class ChgPwd extends StatefulWidget {
  const ChgPwd({Key? key}) : super(key: key);

  @override
  State<ChgPwd> createState() => ChgPwdState();
}

class ChgPwdState extends State<ChgPwd> {
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool newPasswordError = false;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool passwordVisibleOne = false;
  bool passwordVisibleTwo = false;
  bool passwordVisibleThree = false;
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");

  @override
  void initState() {
    super.initState();
    passwordVisibleOne = true;
    passwordVisibleTwo = true;
    passwordVisibleThree = true;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword(String newPassword) async {
    setState(() {
      errorMessage = '';
    });

    try {
      // Verify new password and confirm password match
      if (newPassword != _newPasswordController.text) {
        Fluttertoast.showToast(
          msg: 'New password and confirm password do not match',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          webPosition: "center",
          webBgColor: '#D1D1D6',
          textColor: AppColors.primaryColor,
          fontSize: 16.0,
        );
        return;
      }

      // Verify current password
      final currentUser = FirebaseAuth.instance.currentUser;
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: currentUser!.email!,
        password: _currentPasswordController.text,
      );

      // If current password is incorrect, show error message
      if (authResult.user == null) {
        setState(() {
          errorMessage = 'Wrong current password. Try again.';
        });
        _formKey.currentState!.validate();
        return;
      }

      // If current password is correct, update the password
      final userId = currentUser.uid;
      final userRef = await FirebaseFirestore.instance
          .collection('user')
          .where('userId', isEqualTo: userId)
          .get();
      final userDocId = userRef.docs.first.id;

      // Update password in Firebase Authentication
      await authResult.user!.updatePassword(newPassword);

      // Update password in Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userDocId)
          .update({
        'password': newPassword,
      });

      // Show success message
      Fluttertoast.showToast(
        msg: 'Password updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        webPosition: "center",
        webBgColor: '#D1D1D6',
        textColor: AppColors.primaryColor,
        fontSize: 16.0,
      );

      // Navigate back to profile view screen
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      setState(() {
        errorMessage = 'Wrong current password. Try again.';
      });
      _formKey.currentState!.validate();
    } catch (e) {
      // Handle other errors
      setState(() {
        errorMessage = 'Error updating password';
      });
      _formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    const appTitle = "Change Password";
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          leading: ModalRoute.of(context)?.canPop == true
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 15.0, top: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Password',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                        child: TextFormField(
                          obscureText: passwordVisibleOne,
                          controller: _currentPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter your password';
                            } else if (errorMessage.isNotEmpty) {
                              return errorMessage;
                            }
                            errorMessage = '';
                            return null;
                          },
                          onChanged: (value) => setState(() {
                            errorMessage = '';
                          }),
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: IconButton(
                                icon: Icon(
                                  passwordVisibleOne ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    passwordVisibleOne = !passwordVisibleOne;
                                  });
                                },
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 15.0, top: 10.0),
                          child: Text(
                            'New Password',
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                        child: TextFormField(
                          obscureText: passwordVisibleTwo,
                          controller: _newPasswordController,
                          validator: (value) {
                            setState(() {
                              newPasswordError = false;
                            });
                            if (value == null || value.isEmpty) {
                              setState(() {
                                newPasswordError = true;
                              });
                              return 'Please Enter a password';
                            } else if (!passwordRegex.hasMatch(value)) {
                              setState(() {
                                newPasswordError = true;
                              });
                              return 'Password must contain at least 6 characters, including:\n'
                                  '• Uppercase\n'
                                  '• Lowercase\n'
                                  '• Numbers and special characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: IconButton(
                                icon: Icon(
                                  passwordVisibleTwo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    passwordVisibleTwo = !passwordVisibleTwo;
                                  });
                                },
                              ),
                            ),
                            helperText: newPasswordError
                                ? null
                                : 'Password must contain at least 6 characters, including:\n'
                                  '• Uppercase\n'
                                  '• Lowercase\n'
                                  '• Numbers and special characters',
                            helperStyle: const TextStyle(
                              color: AppColors.textColor,
                              fontSize: 12,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 15.0, top: 10.0),
                          child: Text(
                            'Confirm New Password',
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                        child: TextFormField(
                          obscureText: passwordVisibleThree,
                          controller: _confirmNewPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Your Password Again';
                            } else if (value != _newPasswordController.text) {
                              return 'Password does not Match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: IconButton(
                                icon: Icon(
                                  passwordVisibleThree ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    passwordVisibleThree = !passwordVisibleThree;
                                  });
                                },
                              ),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(
                    width: 160,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor, width: 1.0),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updatePassword(_newPasswordController.text);
                        }
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
