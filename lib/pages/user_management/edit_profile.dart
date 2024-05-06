import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/components/colors.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
            height: 100,
            width: 100,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  backgroundImage: AssetImage('image/splashlogo.png'),
                ),
                Positioned(
                  right: -12,
                  bottom: 0,
                  child: SizedBox(
                    height: 46,
                    width: 46,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: AppColors.textColor),
                        ),
                        backgroundColor: AppColors.systemGreay06Light,
                      ),
                      onPressed: null,
                      child: const Icon(Icons.photo_camera),
                    ),
                  ),
                )
              ],
            ),
          ),
          //First/Last Name
          const SizedBox(height: 20,),
          const TextFieldWithTitle(title: 'First Name'),
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
          const TextFieldWithTitle(title: 'Username'),
          //Email
          const TextFieldWithTitle(title: 'Email'),
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
                onPressed: null,
                child: const Text('Next',
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

  const TextFieldWithTitle({
    required this.title,
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
              fontSize: 15,
              color: AppColors.primaryColor,
            ),),
          TextField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}