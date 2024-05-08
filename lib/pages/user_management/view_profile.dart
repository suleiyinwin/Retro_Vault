import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/pages/authentication/login.dart';
import 'package:retro/pages/user_management/edit_profile.dart';
import 'package:retro/pages/user_management/change_pwd.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Stream<String> _usernameStream;

  @override
  void initState() {
    super.initState();
    _usernameStream = _getUserNameStream(FirebaseAuth.instance.currentUser!.uid);
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
      await Future.delayed(Duration(milliseconds: 5)); // Adjust delay as needed
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
  void navigateToChangePassword(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> const ChgPwd())
    );
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
        content: Text(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: AppColors.backgroundColor,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // Ensure there is a current user
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      try {
                        // Delete user account from Firebase
                        await currentUser.delete();

                        // Verify if the account was deleted successfully
                        final user = await FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          // Navigate to login page if deletion was successful
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        } else {
                          print("User account deletion failed.");
                        }
                      } catch (e) {
                        print("Failed to delete account: $e");
                      }
                    } else {
                      print("No current user found.");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:12),
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
                    side: BorderSide(color: AppColors.primaryColor),
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
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryColor,
                        backgroundImage: AssetImage('image/splashlogo.png'),
                      ),
                      const SizedBox(width: 16),
                      Column(
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
                          const Text(
                            'Edit Profile',
                            style: TextStyle(color: AppColors.textColor),
                          ),
                        ],
                      ),
                      const SizedBox(width: 50),
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
                          const Text('Change Password'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: navigateToChangePassword,
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.primaryColor),
                      Row(
                        children: [
                          const Text('Delete My Account'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _showDeleteAccountDialog,
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.primaryColor),
                      Row(
                        children: [
                          const Text('Log Out'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: signOut,
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
