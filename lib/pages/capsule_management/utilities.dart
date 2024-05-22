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

String parseRemainingTime(Timestamp timestamp) {
  var current = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Duration duration =
  Duration(seconds: timestamp.seconds - current);

  if (duration.inMinutes < 60) {
    return '${duration.inMinutes} more minutes';
  }

  if (duration.inHours < 24) {
    return '${duration.inHours} more hours';
  }

  return '${duration.inDays} more days';
}

Future<String> getUserName(String userId) async {
  Map<String, String> simpleCache = <String, String>{};

  if (simpleCache.containsKey(userId)) {
    return simpleCache[userId]!;
  } else {
    var snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userId)
        .get();

    var username = await snapshot.docs[0].get('username');
    simpleCache[userId] = username;

    return username;
  }
}
