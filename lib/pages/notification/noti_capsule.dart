import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:retro/components/colors.dart';
// import 'package:retro/pages/capsule_management/capsule_list.dart';
import 'package:retro/pages/capsule_management/capsule_widget_shared_by_others.dart';

class NotiCapsule extends StatefulWidget {
  final String capsuleId;
  final String title;
  final Future<String> author;
  final String imageUrl;
  final Timestamp openDate;
  final Timestamp editBeforeDate;
  
  const NotiCapsule({
    super.key,
    required this.capsuleId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.openDate,
    required this.editBeforeDate,});

  @override
  State<NotiCapsule> createState() => _NotiCapsuleState();
}

class _NotiCapsuleState extends State<NotiCapsule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SharedByOthersCapsuleWidget(
                capsuleId: widget.capsuleId,
                title: widget.title,
                author: widget.author,
                imageUrl: widget.imageUrl,
                openDate: widget.openDate,
                editBeforeDate: widget.editBeforeDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}