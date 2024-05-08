import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/components/colors.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:html';
import 'dart:typed_data';
import 'dart:math';
import 'package:intl/intl.dart';
class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
   Uint8List? _profileImageBytes;
   late TextEditingController _emailController;
   final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _profilePhotoUrl ='';
   @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? '',
    );
    _loadUserData();
  }
  void _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      List<String>? nameParts = currentUser.displayName?.split(' ');
      if (nameParts != null && nameParts.length >= 2) {
        _firstNameController.text = nameParts[0];
        _lastNameController.text = nameParts[1];
      }
      try {
      final userId = currentUser.uid;
      final userRef = await FirebaseFirestore.instance
          .collection('user')
          .where('userId', isEqualTo: userId)
          .get();
      if (userRef.docs.isNotEmpty) {
        final userData = userRef.docs.first.data();
        final username = userData['username'];
        _usernameController.text = username ?? '';
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
    try {
        final userId = currentUser.uid;
        final userRef = await FirebaseFirestore.instance
            .collection('user')
            .where('userId', isEqualTo: userId)
            .get();
        if (userRef.docs.isNotEmpty) {
          final userData = userRef.docs.first.data();
          final username = userData['username'];
          _usernameController.text = username ?? '';
          final profilePhotoUrl = userData['profile_photo_url'];
          setState(() {
            _profilePhotoUrl = profilePhotoUrl ?? ''; // Set profile photo URL
          });
        }
      } catch (error) {
        print('Error fetching user data: $error');
      }
    
    }
  }
  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }


//   void _uploadProfilePhoto() async {
//   html.InputElement uploadInput = html.InputElement(type: 'file');
//   uploadInput.click();
//   uploadInput.onChange.listen((_) async {
//     final file = uploadInput.files!.first;
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);
//     reader.onLoadEnd.listen((_) async {
//       final Uint8List? profileImageBytes = reader.result as Uint8List?;
//       if (profileImageBytes != null) {
//         try {
//           final user = FirebaseAuth.instance.currentUser;
//           if (user != null) {
//             final userId = user.uid;
//             final userRef = await FirebaseFirestore.instance
//                 .collection('user')
//                 .where('userId', isEqualTo: userId)
//                 .get();
//             final userDocId = userRef.docs.first.id;

//             final photoRef = FirebaseStorage.instance
//                 .ref()
//                 .child('user_profiles/$userDocId/profile_photo');
//             await photoRef.putData(profileImageBytes);
//             final photoUrl = await photoRef.getDownloadURL();
//             // Update the profile photo URL in the user document
//             await FirebaseFirestore.instance
//                 .collection('user')
//                 .doc(userDocId)
//                 .update({'profile_photo_url': photoUrl});
//             setState(() {
//               _profileImageBytes = profileImageBytes;
//             });
//           }
//         } catch (error) {
//           print('Error uploading profile photo: $error');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to upload profile photo'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     });
//   });
// }






// void _updateUserProfile() async {
//     String firstName = _firstNameController.text.trim();
//     String lastName = _lastNameController.text.trim();

//     User? currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser != null) {
//       try {
//         await currentUser.updateDisplayName('$firstName $lastName');
//         await FirebaseFirestore.instance
//             .collection('user')
//             .doc(currentUser.uid) // Assuming you have the user's document ID
//             .update({
//           'firstName': firstName,
//           'lastName': lastName,
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Profile updated successfully!')),
//         );
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update profile: $error'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
void _selectAndUploadProfilePhoto() {
  html.InputElement uploadInput = html.InputElement(type: 'file');
  uploadInput.click();
  uploadInput.onChange.listen((_) async {
    final file = uploadInput.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((_) async {
      final Uint8List? profileImageBytes = reader.result as Uint8List?;
      if (profileImageBytes != null) {
        await _uploadProfilePhoto(profileImageBytes);
      }
    });
  });
}

Future<void> _uploadProfilePhoto(Uint8List profileImageBytes) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final userId = user.uid;
      final userRef = await FirebaseFirestore.instance
          .collection('user')
          .where('userId', isEqualTo: userId)
          .get();
      final userDocId = userRef.docs.first.id;

      final photoRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles/$userDocId/profile_photo');
      await photoRef.putData(profileImageBytes);
      final photoUrl = await photoRef.getDownloadURL();
      // Update the profile photo URL in the user document
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userDocId)
          .update({'profile_photo_url': photoUrl});
      setState(() {
        _profileImageBytes = profileImageBytes;
      });
    } catch (error) {
      print('Error uploading profile photo: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload profile photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _updateUserProfile() async {
  String firstName = _firstNameController.text.trim();
  String lastName = _lastNameController.text.trim();
  String username = _usernameController.text.trim();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    try {
      await currentUser.updateDisplayName('$firstName $lastName');
      final userId = currentUser.uid;
      final userRef = await FirebaseFirestore.instance
          .collection('user')
          .where('userId', isEqualTo: userId)
          .get();
      final userDocId = userRef.docs.first.id;
      await FirebaseFirestore.instance.collection('user').doc(userDocId).update({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        //displays the back button if canPop returns true, indicating there's a previous route.
        leading: ModalRoute.of(context)?.canPop == true
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          //Profile Picture
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
  backgroundColor: AppColors.primaryColor,
  child: _profilePhotoUrl.isNotEmpty
    ? Image.network(
        _profilePhotoUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $error");
          return Image.asset(
            'image/splashlogo.png', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        },
      )
    : Image.asset(
        'image/splashlogo.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
),



                Positioned(
                  right: 12,
                  bottom: 3,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: AppColors.black),
                        ),
                        backgroundColor: AppColors.systemGreay06Light,
                      ),
                      onPressed: _selectAndUploadProfilePhoto,
                      child: const Icon(Icons.photo_camera),
                    ),
                  ),
                )
              ],
            ),
          ),
           const SizedBox(height: 20),
          //First/Last Name
         Row(
  children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name', 
              style: const TextStyle(                  
                fontSize: 16,
                color: AppColors.textColor,
              ),
            ),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Name', 
              style: const TextStyle(                  
                fontSize: 16,
                color: AppColors.textColor,
              ),
            ),
            TextField(
               controller: _lastNameController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),
          // const Padding(
          //   padding: EdgeInsets.all(20.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       TextFieldWithTitle(title: 'First Name'),
          //       TextFieldWithTitle(title: 'Last Name'),
          //     ],
          //   ),
          // ),
          //Username
          TextFieldWithTitle(title: 'Username',
          controller: _usernameController,),
          //Email
          TextFieldWithTitle(title: 'Email',
          controller: _emailController,
          enabled: false,),
          const Spacer(),
          //Save Button
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 160,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primaryColor, width: 1.0),
                ),
                onPressed: _updateUserProfile,
                child: const Text('Update',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    ),
                )
              ),
            ),
          ),
        ]
      ),
    );
  }
}

class TextFieldWithTitle extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final bool enabled;

  const TextFieldWithTitle({
    required this.title,
    this.controller,
    this.enabled = true,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, 
            style: const TextStyle(                  
              fontSize: 16,
              color: AppColors.textColor,
            ),),
          TextField(
            controller: controller,
            enabled: enabled && controller != null,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}