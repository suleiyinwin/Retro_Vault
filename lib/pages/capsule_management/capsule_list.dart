import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/pages/capsule_management/capsule_image_widget.dart';
import 'package:retro/pages/capsule_management/fab.dart';
import 'package:retro/pages/capsule_management/lock_icon_widget.dart';
import 'package:retro/pages/capsule_management/opened_capsule.dart';
import 'package:retro/pages/capsule_management/opened_capsule_text.dart';
import 'package:retro/pages/capsule_management/utilities.dart';
import '../../components/colors.dart';
import 'edit_capsule.dart';

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
              capsuleId: data['capsuleId'],
              title: data['title'],
              author: getUserName(FirebaseAuth.instance.currentUser!.uid),
              imageUrl: data['coverPhotoUrl'] ?? '',
              openDate: data['openDate'],
              editBeforeDate: data['editBeforeDate'],
            );
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
  var current = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Duration duration =
      Duration(seconds: timestamp.seconds - current);

  if (duration.inMinutes < 60) {
    return '${duration.inMinutes} minutes left';
  }

  if (duration.inHours < 24) {
    return '${duration.inHours} hours left';
  }

  return '${duration.inDays} days left';
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

Future<void> _dialogBuilder(BuildContext context, Timestamp openDate) {
  return showDialog<void>(context: context, builder: (BuildContext context) {
    return AlertDialog(
      content: Text('Your capsule is locked now.\nWait for ${parseRemainingTime(openDate)} to view'),
    );
  });
}

class CapsuleWidget extends StatelessWidget {
  final String capsuleId;
  final String title;
  final Future<String> author;
  final String imageUrl;
  final Timestamp openDate;
  final Timestamp editBeforeDate;

  const CapsuleWidget({
    super.key,
    required this.capsuleId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.openDate,
    required this.editBeforeDate,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: author,
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () {
              if (isLocked(openDate)) {
                if (isEditable(editBeforeDate)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditCapsule(
                              id: capsuleId,
                              od: DateTime.parse(openDate.toDate().toString())
                                  .toLocal(),
                              ebd: DateTime.parse(
                                      editBeforeDate.toDate().toString())
                                  .toLocal())));
                } else {
                  // show lock modal
                  _dialogBuilder(context, openDate);
                }
              } else {
                FirebaseFirestore.instance
                    .collection('capsules')
                    .where('capsuleId', isEqualTo: capsuleId)
                    .get()
                    .then((value) {
                  if (value.docs.isEmpty) {
                    return;
                  }

                  final String id = value.docs![0].id;
                  final data = value.docs![0].data();

                  bool hasPhotoUrls = false;

                  for (int i = 0; i < 10; ++i) {
                    final key = 'capsule_photourl$i';
                    if (data.containsKey(key) && data[key] != null) {
                      hasPhotoUrls = true;
                      break;
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => hasPhotoUrls
                          ? OpenedCapsule(capsuleId: id)
                          : OpenedCapsuleText(capsuleId: id),
                    ),
                  );
                });
              }
            },
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
                        child: CapsuleImageWidget(imageUrl: imageUrl)),
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
                            overflow: TextOverflow.ellipsis,
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
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryColor,
                              )),
                        ),

                        //Open Date
                        isLocked(openDate)
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
                Center(child: LockIconWidget(openDate: openDate)),
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
