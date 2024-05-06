import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/pages/user_management/edit_profile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(             //profile picture and username section
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryColor,
                        backgroundImage: AssetImage('image/splashlogo.png'),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username',
                          style: TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor),),
                          Text('Edit Profile',
                          style: TextStyle(color: AppColors.textColor),),
                        ]
                      ),
                      SizedBox(width: 50),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: () {
                          Navigator.push(
                            context, // Pass the current context to the Navigator
                            MaterialPageRoute(builder: (context) => const EditProfile()),
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
              child: SizedBox(  //settings section
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text('Change Password'),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: null,
                          ),
                        ],
                      ),
                      Divider(color: AppColors.primaryColor),
                      Row(
                        children: [
                          Text('Delete My Account'),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: null,
                          ),
                        ],
                      ),
                      Divider(color: AppColors.primaryColor),
                      Row(
                        children: [
                          Text('Log Out'),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: null,
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