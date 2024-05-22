import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:retro/pages/capsule_management/utilities.dart';

import '../../components/colors.dart';
import 'capsule_image_widget.dart';
import 'capsule_list.dart';
import 'edit_capsule.dart';
import 'lock_icon_widget.dart';
import 'opened_capsule.dart';
import 'opened_capsule_text.dart';

Future<void> _dialogBuilder(BuildContext context, Timestamp openDate) async {
  showDialog(
    context: context,
    builder: (BuildContext context){
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: AppColors.backgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'image/time.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 15),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Your capsule is locked now.\nWait for ',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 18,

                    ),
                  ),
                  TextSpan(
                    text: parseRemainingTime(openDate),
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' to view',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 18,

                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150, // Set the desired width for the button
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Ok",
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: AppColors.backgroundColor,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class SharedByOthersCapsuleWidget extends StatelessWidget {
  final String capsuleId;
  final String title;
  final Future<String> author;
  final String imageUrl;
  final Timestamp openDate;
  final Timestamp editBeforeDate;

  const SharedByOthersCapsuleWidget({
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
                _dialogBuilder(context, openDate);
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
