import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/pages/capsule_management/create_capsule.dart';
import 'package:retro/pages/capsule_management/fab.dart';
import '../../components/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:retro/firebase_options.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> data =
                snapshot.data!.docs[index].data()! as Map<String, dynamic>;

            return CapsuleWidget(
                title: data['title'],
                author: getUserName(FirebaseAuth.instance.currentUser!.uid),
                imageUrl: data['coverPhotoUrl'] ?? '',
                openDate: data['openDate']);
          },
          separatorBuilder: (context, index) => const Divider(
            color: Colors.transparent,
          ),
        );
      },
    );
  }
}

//UserInformationState
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

//Timestamp
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
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateCapsule()),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
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

                  //Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 32, right: 16, top: 48),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        //Author
                        Padding(
                          padding: const EdgeInsets.only(left: 32, right: 16),
                          child: Text(
                              'Shared by ${snapshot.connectionState == ConnectionState.waiting ? '…' : snapshot.data}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryColor,
                              )),
                        ),

                        //Open Date
                        Timestamp.now().seconds - openDate.seconds <= 0
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 32, right: 8),
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
                Center(
                    child: Image.asset(
                        Timestamp.now().seconds - openDate.seconds <= 0
                            ? 'image/locked.png'
                            : 'image/unlocked.png',
                        width: 150,
                        height: 150)),
              ]),
            ),
          );
        });
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                indicatorColor: AppColors.primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor),
                tabs: <Widget>[Tab(text: 'By Me'), Tab(text: 'By Others')],
              ),
            ),
            floatingActionButton: const FAB(),
            body: const TabBarView(
              children: <Widget>[
                UserInformation(),
                Column(
                  children: [],
                ),
              ],
            )),
      ),
    );
  }
}
