import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/components/colors.dart';
import 'dart:async';
// import 'dart:html' as html;
// import 'dart:html';
import 'dart:typed_data';
// import 'dart:math';
// import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retro/pages/user_management/view_profile.dart';
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
// void _selectAndUploadProfilePhoto() {
//   html.InputElement uploadInput = html.InputElement(type: 'file');
//   uploadInput.click();
//   uploadInput.onChange.listen((_) async {
//     final file = uploadInput.files!.first;
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);
//     reader.onLoadEnd.listen((_) async {
//       final Uint8List? profileImageBytes = reader.result as Uint8List?;
//       if (profileImageBytes != null) {
//         await _uploadProfilePhoto(profileImageBytes);
//       }
//     });
//   });
// }

//mobile
void _selectAndUploadProfilePhoto() async {
  final picker = ImagePicker(); // Create an instance of ImagePicker
  final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Pick an image from the gallery

  if (pickedFile != null) {
    final bytes = await pickedFile.readAsBytes(); // Read the selected image as bytes
    setState(() {
      _profileImageBytes = bytes; // Set the profile image bytes to display the preview
    });
    await _uploadProfilePhoto(bytes); // Upload the image
  }
}


// Future<void> _uploadProfilePhoto(Uint8List profileImageBytes) async {
//   User? user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     try {
//       final userId = user.uid;
//       final userRef = await FirebaseFirestore.instance
//           .collection('user')
//           .where('userId', isEqualTo: userId)
//           .get();
//       final userDocId = userRef.docs.first.id;

//       final photoRef = FirebaseStorage.instance
//           .ref()
//           .child('user_profiles/$userDocId/profile_photo');
//       await photoRef.putData(profileImageBytes);
//       final photoUrl = await photoRef.getDownloadURL();
//       // Update the profile photo URL in the user document
//       await FirebaseFirestore.instance
//           .collection('user')
//           .doc(userDocId)
//           .update({'profile_photo_url': photoUrl});
//       setState(() {
//         _profileImageBytes = profileImageBytes;
//       });
//     } catch (error) {
//       print('Error uploading profile photo: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to upload profile photo'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
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
          const SnackBar(
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
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      //  Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileView()),
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              //Profile Picture
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor,
            ),
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
            // backgroundColor: AppColors.primaryColor,
            child: _profileImageBytes != null
                ? Image.memory(
                    _profileImageBytes!,
                    width: 200,
                height: 200,
                    fit: BoxFit.cover,
                  )
                : (_profilePhotoUrl.isNotEmpty
                    ? Image.network(
                        _profilePhotoUrl,
                        fit: BoxFit.cover,
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
                        width: 200,
                height: 200,
                        fit: BoxFit.cover,
                      )),
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
              Flexible(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('First Name', 
                  style: TextStyle(                  
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
              Flexible(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Last Name', 
                  style: TextStyle(                  
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom:20.0),
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
              ),
            ]
          ),
        ),
      ),
    );
  }
}

class TextFieldWithTitle extends StatefulWidget {
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
  _TextFieldWithTitleState createState() => _TextFieldWithTitleState();
}
class _TextFieldWithTitleState extends State<TextFieldWithTitle> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title, 
            style: const TextStyle(                  
              fontSize: 16,
              color: AppColors.textColor,
            ),),
          TextField(
            controller: widget.controller,
            enabled: widget.enabled && widget.controller != null,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              errorText: _errorText,
            ),
            onChanged: (value) {
              // Check username availability here
              _checkUsernameAvailability(value);
            },
          ),
        ],
      ),
    );
  }
  void _checkUsernameAvailability(String username) async {
    if (username.isNotEmpty) {
      try {
        final userQuery = await FirebaseFirestore.instance
            .collection('user')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          setState(() {
            _errorText = 'Unavailable username. Try again.';
          });
        } else {
          setState(() {
            _errorText = null;
          });
        }
      } catch (error) {
        print('Error checking username availability: $error');
        // Handle error
      }
    }
  }
}

