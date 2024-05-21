import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:retro/components/colors.dart';

class NotiPage extends StatefulWidget {
  const NotiPage({super.key});

  @override
  State<NotiPage> createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  List<Map<String, dynamic>> _notifications = [];

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
      _startPolling();
    });
  }

  void _startPolling() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
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
  final BoxConstraints constraints;

  const NotiCard({
    super.key,
    required this.username,
    required this.profilePic,
    required this.message,
    required this.constraints,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
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
                  : AssetImage('image/splashlogo.png') as ImageProvider,
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
      )
    );
  }
}