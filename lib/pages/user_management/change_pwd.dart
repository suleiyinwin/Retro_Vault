import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/firebase_options.dart';

class ChgPwd extends StatefulWidget {
  const ChgPwd({super.key});

  @override
  State <ChgPwd> createState() =>  ChgPwdState();
}

class  ChgPwdState extends State <ChgPwd> {
  // late Stream<String> _passwordStream;
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool passwordVisibleOne = false;
  bool passwordVisibleTwo = false;
  bool passwordVisibleThree = false;
  final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$");
  String? _userId;
  String? _password;
  @override
  void initState() {
    super.initState();
    passwordVisibleOne = true;
    passwordVisibleTwo = true;
    passwordVisibleThree = true;
    _userId = FirebaseAuth.instance.currentUser!.uid;
    print('User ID: $_userId');
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) {
      _initUserStream();
      printCurrentUser();
    });
  }

  void printCurrentUser() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print('User ID: ${user.uid}');
    print('Email: ${user.email}');
    // Add more user information as needed
  } else {
    print('No user signed in');
  }
}
   void _initUserStream() {
    FirebaseFirestore.instance
       .collection('user')
       .doc(FirebaseAuth.instance.currentUser!.uid)
       .get()
       .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _password = documentSnapshot.get('password');
        });
      } else {
        print('Document does not exist');
      }
    });
  }

  @override
  void dispose(){
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
// Update the password in Firestore
  Future<void> _updatePasswordInFirestore(String newPassword) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(_userId)
        .update({'password': newPassword});
  }

  // Update the password in Firebase Authentication
  Future<void> _updatePasswordInAuthentication(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    await user!.updatePassword(newPassword);
  }

//   Stream<String> _getPasswordStream(String userId) async* {
//   Map<String, String> simpleCache = <String, String>{};

//   while (true) {
//     if (simpleCache.containsKey(userId)) {
//       yield simpleCache[userId]!;
//     } else {
//       var snapshot = await FirebaseFirestore.instance
//           .collection('user')
//           .where('userId', isEqualTo: userId) // Accessing user document directly using userId
//           .get();

//       var password = await snapshot.docs[0].get('password'); // Get the password field from the document data
//       simpleCache[userId] = password; // Store password in cache
//       yield password; 
//     }
   
    
//   }
// }

Future<void> _updatePassword(String newPassword) async {
    try {
      // Verify new password and confirm password match
      if (newPassword!= _newPasswordController.text) {
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

      // If current password is correct, update the password
      if (authResult.user!= null) {
        // Update password in Firebase Authentication
        await _updatePasswordInAuthentication(newPassword);

        // Update password in Firestore
        await _updatePasswordInFirestore(newPassword);

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
      } else {
        setState(() {
          errorMessage = 'Invalid current password';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error updating password';
      });
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 15.0, top: 10.0),
            child: Text(
              'Current Password',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
              ),
            ),
                ),
                 
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        
                        Padding( padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                        child: TextFormField(
                          obscureText: passwordVisibleOne,
                          controller: _currentPasswordController,
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please Enter your password';
                            }
                            else if(errorMessage.isNotEmpty){
                              return errorMessage;
                            }
                            else if (!passwordRegex.hasMatch(value)){
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
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 15.0) ,
                                child: IconButton(
                                  icon: Icon(
                                    passwordVisibleOne
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                    color: AppColors.primaryColor,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      passwordVisibleOne = !passwordVisibleOne;
                                    });
                                  },),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red
                                  ),
                                ),
                                // floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 15.0, top: 10.0),
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
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 15.0),
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
            // floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text(
              'Password must contain \n'
                    '• At least 8 characters\n'
                    '• At least one numeric character (0-9)\n'
                    '• At least one special character',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 12,
                    ),
            ),
                ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 15.0, top: 10.0),
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
              return 'Password does Not Match';
            }
            return null;
                },
                decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: Icon(
                  passwordVisibleThree
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
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
            // floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: 160.0,
                height: 50.0,
                child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.primaryColor, width: 1.0),
              ),
              onPressed:() {
  if (_formKey.currentState!.validate()) {
    _updatePassword(_newPasswordController.text);
  }
},
              child: const Text(
                'Update',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0
                ),
              ),
            ),
                ),
            ),
            
                      ],),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
      );
  }
}