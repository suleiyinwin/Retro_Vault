import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/pages/authentication/login.dart';
import 'package:retro/pages/user_management/edit_profile.dart';
import 'package:retro/pages/user_management/change_pwd.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Stream<String> _usernameStream;
  String _profilePhotoUrl = '';
  

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
    _usernameStream =
        _getUserNameStream(FirebaseAuth.instance.currentUser!.uid);
  }

// Function to load profile photo URL
   void _loadProfilePhoto() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userId = currentUser.uid;
        final userRef = await FirebaseFirestore.instance
            .collection('user')
            .where('userId', isEqualTo: userId)
            .get();
        if (userRef.docs.isNotEmpty) {
          final userData = userRef.docs.first.data();
          final profilePhotoUrl = userData['profile_photo_url'];
          setState(() {
            _profilePhotoUrl = profilePhotoUrl ?? ''; // Set profile photo URL
          });
        }
      } catch (error) {
        print('Error fetching profile photo: $error');
      }
    }
  }
  Stream<String> _getUserNameStream(String userId) async* {
    Map<String, String> simpleCache = <String, String>{};

    while (true) {
      if (simpleCache.containsKey(userId)) {
        yield simpleCache[userId]!;
      } else {
        var snapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('userId', isEqualTo: userId)
            .get();

        var username = await snapshot.docs[0].get('username');
        simpleCache[userId] = username;
        yield username;
      }
      await Future.delayed(
          const Duration(milliseconds: 5)); // Adjust delay as needed
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void navigateToChangePassword() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ChgPwd()));
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppColors.backgroundColor,
          content: const Text(
            "Are you sure you want to delete your account?",
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: AppColors.backgroundColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final userId = FirebaseAuth.instance.currentUser!.uid;
try {
  final userRef = await FirebaseFirestore.instance
      .collection('user')
      .where('userId', isEqualTo: userId)
      .get();

  if (userRef.docs.isNotEmpty) {
    final userDocId = userRef.docs.first.id;

    // Delete the user document
    await FirebaseFirestore.instance.collection('user').doc(userDocId).delete();

    // Delete the user account from Firebase Authentication
    await FirebaseAuth.instance.currentUser!.delete();

    // Navigate to the login page after successful deletion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  } else {
    print('User document not found');
  }
} catch (error) {
  print('Error deleting user: $error');
}

                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                        child: ClipOval(
                          // radius: 50,
                          // backgroundColor: AppColors.primaryColor,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                           child: _profilePhotoUrl.isNotEmpty
                            ? Image.network(_profilePhotoUrl,width: 100, height: 100,fit: BoxFit.cover,) // Load profile photo from URL
                            : Image.asset('image/splashlogo.png', width: 100, height: 100,fit: BoxFit.cover,), // Fallback image if URL is empty
                      ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder<String>(
                              stream: _usernameStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error: ${snapshot.error}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    snapshot.data ?? 'Username not found',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(color: AppColors.textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfile(),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: SizedBox(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Text('Change Password',
                          style: TextStyle(color: AppColors.textColor),),
                          Expanded(
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: navigateToChangePassword,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.primaryColor),
                      Row(
                        children: [
                          const Text('Delete My Account',
                          style: TextStyle(color: AppColors.textColor),),
                          Expanded(
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: _showDeleteAccountDialog,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.primaryColor),
                      Row(
                        children: [
                          const Text('Log Out',
                          style: TextStyle(color: AppColors.textColor),),
                          Expanded(
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: signOut,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
