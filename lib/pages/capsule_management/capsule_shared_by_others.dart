import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:retro/pages/capsule_management/utilities.dart';

import 'capsule_widget_shared_by_others.dart';

class SharedByOthers extends StatefulWidget {
  const SharedByOthers({super.key});

  @override
  _SharedByOthersState createState() => _SharedByOthersState();
}

class _SharedByOthersState extends State<SharedByOthers> {
  @override
  Widget build(BuildContext context) {
    Future<QuerySnapshot<Map<String, dynamic>>> _user = FirebaseFirestore
        .instance
        .collection('user')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _user,
        builder: (context, snp) {
          if (snp.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading'));
          }

          late final Stream<QuerySnapshot> _sharedByOthersStream =
              FirebaseFirestore
                  .instance
                  .collection('capsules')
                  .where('sharedWith',
                      arrayContains: snp.data!.docs.first.reference)
                  .snapshots();

          return StreamBuilder<QuerySnapshot>(
              stream: _sharedByOthersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text("Loading"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data()! as Map<String, dynamic>;

                    return SharedByOthersCapsuleWidget(
                      capsuleId: data['capsuleId'],
                      title: data['title'],
                      author: getName(data['userRef'].get()),
                          // getUserName(FirebaseAuth.instance.currentUser!.uid),
                      imageUrl: data['coverPhotoUrl'] ?? '',
                      openDate: data['openDate'],
                      editBeforeDate: data['editBeforeDate'],
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.transparent,
                  ),
                );
              });
        });
  }
}
