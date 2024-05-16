import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:retro/pages/capsule_management/utilities.dart';

class LockIconWidget extends StatelessWidget {
  final Timestamp openDate;

  const LockIconWidget({super.key, required this.openDate});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'image/${isLocked(openDate) ? 'locked' : 'unlocked'}.png',
      width: 150,
      height: 150,
    );
  }
}
