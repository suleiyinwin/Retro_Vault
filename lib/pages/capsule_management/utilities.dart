import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool isLocked(Timestamp dateTime) {
  var current = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return current - dateTime.seconds <= 0;
}

const isEditable = isLocked;

String? getCurrentUserId() {
  final currentUser =  FirebaseAuth.instance.currentUser;

  return currentUser?.uid;
}