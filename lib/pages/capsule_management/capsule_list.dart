import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/pages/capsule_management/create_capsule.dart';
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
              imageUrl: data['coverPhotoUrl'],
            );
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

class Capsule {
  final String title;
  final String author;
  final String image;
  final bool locked;

  Capsule({
    required this.title,
    required this.author,
    required this.image,
    required this.locked,
  });
}

class CapsuleWidget extends StatelessWidget {
  final String title;
  final Future<String> author;
  final String imageUrl;

  const CapsuleWidget({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: author,
        builder: (context, snapshot) {
          return Container(
            margin: const EdgeInsets.all(10),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(150),
            ),
            child: Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(150),
                      bottomLeft: Radius.circular(150)),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 10.0, top: 50.0),
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
                      padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                      child: Text(
                          'Shared by ${snapshot.connectionState == ConnectionState.waiting ? '…' : snapshot.data}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                          )),
                    ),
                  ],
                ),
              )
            ]),
          );
        });
  }
}

class style {
  const style();
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
            floatingActionButton: SizedBox(
              width: 80,
              height: 80,
              child: FloatingActionButton(
                  shape: const CircleBorder(),
                  backgroundColor: AppColors.primaryColor,
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateCapsule()),
                    );
                  },
                  child: const IconTheme(
                    data: IconThemeData(
                        color: AppColors.backgroundColor, size: 40),
                    child: Icon(Icons.add),
                  )),
            ),
            body: TabBarView(
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
