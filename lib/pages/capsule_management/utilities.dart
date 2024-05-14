import 'package:cloud_firestore/cloud_firestore.dart';

bool isLocked(Timestamp dateTime) {
  return Timestamp.now().seconds - dateTime.seconds <= 0;
}
