import 'package:cloud_firestore/cloud_firestore.dart';

bool isLocked(Timestamp dateTime) {
  var current = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return current - dateTime.seconds <= 0;
}

const isEditable = isLocked;