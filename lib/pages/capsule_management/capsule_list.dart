import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/pages/capsule_management/fab.dart';
import '../../components/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:retro/firebase_options.dart';

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('capsules')
      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return Column(children: [
          ...snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            return CapsuleWidget(
                title: data['title'],
                author: getUserName(FirebaseAuth.instance.currentUser!.uid),
                imageUrl: data['coverPhotoUrl'] ?? '',
                openDate: data['openDate']);
          }),
        ]);
      },
    );
  }
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

String parseDate(Timestamp timestamp) {
  Duration duration =
      Duration(seconds: timestamp.seconds - Timestamp.now().seconds);

  if (duration.inMinutes < 60) {
    return '${duration.inMinutes} minutes left';
  }

  if (duration.inHours < 24) {
    return '${duration.inHours} hours left';
  }

  return '${duration.inDays} days left';
}

class CapsuleWidget extends StatelessWidget {
  final String title;
  final Future<String> author;
  final String imageUrl;
  final Timestamp openDate;

  const CapsuleWidget({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.openDate,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: author,
        builder: (context, snapshot) {
          return Container(
            margin: const EdgeInsets.all(8),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(150),
            ),
            child: Stack(children: [
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(150),
                        bottomLeft: Radius.circular(150)),
                    child: imageUrl == ''
                        ? Image.asset('image/defaultcapsult.png',
                            fit: BoxFit.cover)
                        : Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 8, top: 48),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Text(
                            'Shared by ${snapshot.connectionState == ConnectionState.waiting ? '…' : snapshot.data}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                            )),
                      ),
                      Timestamp.now().seconds - openDate.seconds <= 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 8),
                              child: Text(parseDate(openDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryColor,
                                  )),
                            )
                          : Container(),
                    ],
                  ),
                )
              ]),
              Center(child: Image.asset(Timestamp.now().seconds - openDate.seconds <= 0 ? 'image/locked.png' : 'image/unlocked.png', width: 150, height: 150)),
            ]),
          );
        });
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              shape: const Border(
                  bottom: BorderSide(color: AppColors.primaryColor)),
              backgroundColor: AppColors.backgroundColor,
              bottom: const TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                tabs: <Widget>[
                  Tab(text: 'By Me'),
                  Tab(
                    text: 'By Others',
                  )
                ],
              ),
            ),
            floatingActionButton: const FAB(),
            body: TabBarView(
              children: <Widget>[
                UserInformation(),
                const Column(
                  children: [],
                ),
              ],
            )),
      ),
    );
  }
}
