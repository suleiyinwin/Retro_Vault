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
      await Future.delayed(Duration(seconds: 1)); // Adjust delay as needed
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
                      const Row(
                        children: [
                          Text('Delete My Account'),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: null,
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
