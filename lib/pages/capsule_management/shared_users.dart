import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class SharedUsers extends ChangeNotifier {
  String capsuleDocId;
  List<dynamic> users = [];

  SharedUsers({required this.capsuleDocId}) {
    fetch();
  }

  void fetch() async {
    final capsule = await FirebaseFirestore.instance.collection('capsules').doc(capsuleDocId).get();
    if (capsule.exists) {
      final sharedUserRefs = capsule.get('sharedWith');

      for (final sharedUser in sharedUserRefs) {
        final user = await sharedUser.get();
        users.add(user);
      }
    }

    notifyListeners();
  }

  Future<bool> add(String email) async {
    if (_userAlreadyShared(email)) {
      throw Exception('User is already added');
    }

    final QuerySnapshot sharedUserRef = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    if (sharedUserRef.docs.isEmpty) {
      throw Exception('User not found');
    } else {
      users.add(sharedUserRef.docs.first);

      notifyListeners();
    }

    return true;
  }

  void remove(dynamic user) {
    users.remove(user);

    notifyListeners();
  }

  static bool isUserAuthedUser(String email) {
    return email == FirebaseAuth.instance.currentUser?.email;
  }

  bool _userAlreadyShared(String email) {
    List<String> emails = users.map<String>((user) => user.get('email')).toList();
    return emails.contains(email);
  }
}