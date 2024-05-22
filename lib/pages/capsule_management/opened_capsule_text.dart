//import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/components/bottomNavigation.dart';
import 'package:flutter/widgets.dart';



class OpenedCapsuleText extends StatefulWidget {
  OpenedCapsuleText({Key? key, required this.capsuleId})
      : super(key: key);
  final String capsuleId;

  @override
  State<OpenedCapsuleText> createState() => _OpenedCapsuleTextState();
}

class _OpenedCapsuleTextState extends State<OpenedCapsuleText> {
  late Stream<QuerySnapshot> _capsuleStream;
  late User? currentUser;

  void initState() {
      super.initState();
     currentUser = FirebaseAuth.instance.currentUser;
    _capsuleStream = FirebaseFirestore.instance
        .collection('capsules')
        .where('capsuleId', isEqualTo: widget.capsuleId)
        .snapshots();
    //log = Logger('CreateCapsule');
  }

  void _showDeleteCapsuleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppColors.backgroundColor,
          content: const Text(
            "Are you sure you want to delete this capsule?",
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
                      try {
                        // Have to access capsuleId directly
                        await FirebaseFirestore.instance
                            .collection('capsules')
                            .doc(widget.capsuleId)
                            .delete();

                        // Navigate to the home page after successful deletion
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const BottomNav()),
                          (Route<dynamic> route) => false,
                        );
                      } catch (error) {
                        print('Error deleting capsule: $error');
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
      ),
      backgroundColor: AppColors.backgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('capsules')
            .doc(widget.capsuleId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Capsule not found."),
            );
          }

          final data = snapshot.data!;
          final title = data['title'] ?? "Title not found";
          final text = data['message'] ?? "Text not found";
          final userId = data['userId'] ?? "";
          final isOwner = currentUser != null && userId == currentUser!.uid;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textColor,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                  child: Row(
                     mainAxisAlignment: isOwner ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (isOwner)
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.textColor),
                          ),
                          onPressed: _showDeleteCapsuleDialog,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primaryColor, 
                                width: 1.0),
                                backgroundColor: 
                                AppColors.primaryColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16.0),
                          ),
                        ),
                      ),
                    
                    ]
                  ),
              )
              /* Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(
                    width: 160,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primaryColor, width: 1.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      //onPressed: _showDeleteCapsuleDialog,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ), */
            ],
          );
        },
      ),
    );
  }
}
