import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/pages/notification/noti_capsule.dart';

class NotiPage extends StatefulWidget {
  const NotiPage({super.key});

  @override
  State<NotiPage> createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  List<Map<String, dynamic>> _notifications = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadInitialNotifications();
    _startDelayedPolling();
  }

  Future<void> _loadInitialNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();
        if(snapshot.docs.isNotEmpty){

          final List<Map<String, dynamic>> notifications = [];
          for (var doc in snapshot.docs) {
            final sharedUserRef = doc['shareduser'] as DocumentReference;
            final sharedUserSnapshot = await sharedUserRef.get();
            if(sharedUserSnapshot.exists){
              final sharedUserData = sharedUserSnapshot.data() as Map<String, dynamic>; 

              notifications.add({
                'capsuleId': doc['capsuleId'],
                'message': doc['message'],
                'username': sharedUserData['username'],
                'profilePic': sharedUserData['profile_photo_url'] ?? '',
              });
            }

            setState(() {
              _notifications = notifications;
            });
          }
        }
      } catch (error) {
        print('Error fetching: $error');
      }
    }
  }

  void _startDelayedPolling() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _startPolling();
      }
    });
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();
          if(snapshot.docs.isNotEmpty){
            final List<Map<String, dynamic>> notifications = [];
            for (var doc in snapshot.docs) {
              final sharedUserRef = doc['shareduser'] as DocumentReference;
              final sharedUserSnapshot = await sharedUserRef.get();
              if(sharedUserSnapshot.exists){
                final sharedUserData = sharedUserSnapshot.data() as Map<String, dynamic>;

                notifications.add({
                  'capsuleId': doc['capsuleId'],
                  'message': doc['message'],
                  'username': sharedUserData['username'],
                  'profilePic': sharedUserData['profile_photo_url'] ?? '',
                });
              }

              setState(() {
                _notifications = notifications;
              });
            }
          }
        } catch (error) {
          print('Error fetching: $error');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: LayoutBuilder(builder: (context, constraints) {
        return ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            return NotiCard(
              capsuleId: _notifications[index]['capsuleId'],
              username: _notifications[index]['username'],
              profilePic: _notifications[index]['profilePic'],
              message: _notifications[index]['message'],
              constraints: constraints);
          },
        );
      }),
    );
  }
}

class NotiCard extends StatelessWidget {
  final String username;
  final String profilePic;
  final String message;
  final String capsuleId;
  final BoxConstraints constraints;

  const NotiCard({
    super.key,
    required this.username,
    required this.profilePic,
    required this.message,
    required this.capsuleId,
    required this.constraints,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
      child: GestureDetector(
        onTap: () async {
          if(capsuleId.isNotEmpty){
          try {
          final capsuleData = await FirebaseFirestore.instance
              .collection('capsules')
              .where('capsuleId', isEqualTo: capsuleId)
              .get();

          if (capsuleData.docs.isNotEmpty) {
            final data = capsuleData.docs.first.data();
            // print(data);
            final String title = data['title'];
            final String imageUrl = data['coverPhotoUrl'] ?? '';
            final Future<String> author = getAuthor(data['userId']);
            final Timestamp openDate = data['openDate'];
            final Timestamp editBeforeDate = data['editBeforeDate'];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotiCapsule(
                  capsuleId: capsuleId,
                  title: title,
                  author: author,
                  imageUrl: imageUrl,
                  openDate: openDate,
                  editBeforeDate: editBeforeDate,
                ),
              ),
            );
          }
          } catch (error) {
            print('Error fetching: $error');
          }}
        },
        child: Container(
          height: 100.0,
          child: Card(
            surfaceTintColor: AppColors.systemGreay06Light,
            // shadowColor: AppColors.systemGreay06Light,
            color: AppColors.systemGreay06Light,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10.0),
              leading: CircleAvatar(
                radius: 32, // Adjust the radius to change the size
                backgroundColor: AppColors.primaryColor,
                backgroundImage: profilePic.isNotEmpty
                    ? NetworkImage(profilePic)
                    : const AssetImage('image/splashlogo.png') as ImageProvider,
              ),
              title: Text(
                username, 
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 15.0,fontWeight: 
                  FontWeight.bold
                )
              ),
              subtitle: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 12.0,
                ),
              // Use the constraints to conditionally adjust the layout
              // trailing: constraints.maxWidth > 600 ? Icon(Icons.more_vert) : null,
              ),
            ),
          ),
        ),
      )
    );
  }
  Future<String> getAuthor(String authorId) async {
    try{
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: authorId)
        .get();
    if (userData.docs.isNotEmpty) {
      // print(userData.docs.first.data());
      return userData.docs.first.data()['username'];
    }
    } catch (error) {
      print('Error fetching: $error');
      
    }
    return 'Unknown';
  }
}