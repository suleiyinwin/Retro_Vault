import 'dart:math';

import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:retro/components/bottomNavigation.dart';
import 'package:retro/components/colors.dart';
import 'package:retro/pages/capsule_management/capsule_list.dart';
import 'package:retro/pages/capsule_management/utilities.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'images.dart';

class EditCapsule extends StatefulWidget {
  final String id;
  final DateTime ebd;
  final DateTime od;

  const EditCapsule(
      {super.key, required this.id, required this.ebd, required this.od});

  @override
  _CapsuleState createState() => _CapsuleState();
}

class _CapsuleState extends State<EditCapsule> {
  late Stream<QuerySnapshot> _capsuleStream;
  late final Logger log;

  @override
  void initState() {
    _capsuleStream = FirebaseFirestore.instance
        .collection('capsules')
        .where('capsuleId', isEqualTo: widget.id)
        .snapshots();
    log = Logger('CreateCapsule');
  }

  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  Uint8List? _imageBytes;
  late DateTime _editBeforeDate = widget.ebd;
  late DateTime _openDate = widget.od;

  late FirebaseFirestore firestore;
  late FirebaseStorage storage;

  bool coverDismissed = false;

  String generateUniqueId() {
    const uuid = Uuid();
    return uuid.v4(); // Generate a Version 4 (random) UUID
  }
  // Gemini

void _showDeleteCapsuleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: AppColors.backgroundColor,
          content: const Text(
            "Are you sure you want to delete your capsule?",
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Cancel",
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
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
try {
  final capsuleReference = await FirebaseFirestore.instance
      .collection('capsules')
      .where('capsuleId', isEqualTo: widget.id)
      .get();

  if (capsuleReference.docs.isNotEmpty) {
    final capsuleDocId = capsuleReference.docs.first.id;

    // Delete the capsule document
    await FirebaseFirestore.instance.collection('capsules').doc(capsuleDocId).delete();

    // Navigate to the home page after successful deletion
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
        (Route<dynamic> route) => false,
      );
  } else {
    print('capsule document not found');
  }
} catch (error) {
  print('Error deleting capsule: $error');
}

                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: AppColors.white,
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
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Gemini*

  Future<void> _selectCoverPhoto() async {
    if (kIsWeb) {
    } else {
      // Mobile platform
      final ImagePicker imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes.buffer.asUint8List();
          coverDismissed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.backArrow,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder(
            stream: _capsuleStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              var data = snapshot.data!.docs[0].data() as Map<String, dynamic>;
              String? coverPhotoUrl = data.containsKey('coverPhotoUrl')
                  ? data['coverPhotoUrl']
                  : null;

              final images =
                  List.generate(10, (index) => 'capsule_photourl$index')
                      .map<String>((key) => data[key] ?? '');

              return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (BuildContext context) =>
                            CapsuleImages(images: [...images])),
                    ChangeNotifierProvider(
                        create: (BuildContext context) => StagedImages())
                  ],
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          // add padding here
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 0, 0, 0),
                                        child: Icon(Icons.edit,
                                            size: 15,
                                            color: AppColors.textColor),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 8, 0),
                                        child: Text(
                                          'Capsule Title',
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _titleController
                                        ..text =
                                            snapshot.data!.docs[0].get('title'),
                                      decoration: const InputDecoration(
                                        // border: OutlineInputBorder(),
                                        border: InputBorder.none,
                                        // hintText: 'Enter your capsule title',
                                      ),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColor),
                                      textAlign: TextAlign.right,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter a title';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(3, 3, 0, 0),
                                child: Container(
                                  height: 1,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.textColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Edit Before',
                                    style:
                                        TextStyle(color: AppColors.textColor),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: _editBeforeDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 30),
                                        ),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData(
                                              colorScheme: const ColorScheme(
                                                primary: AppColors.textColor,
                                                secondary: AppColors.textColor,
                                                surface: AppColors.white,
                                                background: AppColors.white,
                                                error: AppColors.errorRed,
                                                onBackground:
                                                    AppColors.textColor,
                                                brightness: Brightness.light,
                                                onPrimary: AppColors.white,
                                                onSecondary:
                                                    AppColors.textColor,
                                                onError: AppColors.errorRed,
                                                onSurface: AppColors.textColor,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      ).then((picked) {
                                        if (picked != null) {
                                          if (picked.isAfter(DateTime.now()
                                              .add(const Duration(days: 30)))) {
                                            // Show error message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Date cannot be later than 30 days from now'),
                                                backgroundColor:
                                                    AppColors.errorRed,
                                              ),
                                            );
                                          } else {
                                            setState(() {
                                              _editBeforeDate = picked;
                                            });
                                          }
                                        }
                                      });
                                    },
                                    child: Text(
                                      DateFormat.yMMMd()
                                          .format(_editBeforeDate),
                                      style: const TextStyle(
                                          color: AppColors.textColor),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(3, 13, 0, 0),
                                child: Container(
                                  height: 1,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.textColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Open Date',
                                    style:
                                        TextStyle(color: AppColors.textColor),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: _openDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData(
                                              colorScheme: const ColorScheme(
                                                primary: AppColors.textColor,
                                                secondary: AppColors.textColor,
                                                surface: AppColors.white,
                                                background: AppColors.white,
                                                error: AppColors.errorRed,
                                                onBackground:
                                                    AppColors.textColor,
                                                brightness: Brightness.light,
                                                onPrimary: AppColors.white,
                                                onSecondary:
                                                    AppColors.textColor,
                                                onError: AppColors.errorRed,
                                                onSurface: AppColors.textColor,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      ).then((picked) {
                                        if (picked != null) {
                                          if (picked
                                              .isBefore(_editBeforeDate)) {
                                            // Show error message for dates before _editBeforeDate
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Date cannot be before Edit Before date'),
                                                backgroundColor:
                                                    AppColors.errorRed,
                                              ),
                                            );
                                          } else if (picked.isAfter(
                                              DateTime.now().add(
                                                  const Duration(days: 365)))) {
                                            // Show error message for dates after one year from now
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Date cannot be after one year from now'),
                                                backgroundColor:
                                                    AppColors.errorRed,
                                              ),
                                            );
                                          } else {
                                            setState(() {
                                              _openDate = picked;
                                            });
                                            setState(() {
                                              _openDate = picked;
                                            });
                                          }
                                        }
                                      });
                                    },
                                    child: Text(
                                      DateFormat.yMMMd().format(_openDate),
                                      style: const TextStyle(
                                          color: AppColors.textColor),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '**Edit before date cannot be changed in the future',
                              style: TextStyle(
                                  color: AppColors.errorRed, fontSize: 13),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
                              child: Text(
                                'Type Your Message',
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _messageController
                              ..text = snapshot.data!.docs[0].get('message'),
                            maxLines: 3,
                            decoration: const InputDecoration(
                              // labelText: 'Type Your Message',
                              // border: OutlineInputBorder(),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a message';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              'Upload Capsule Cover Photo',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer()
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: _selectCoverPhoto,
                                child: Row(
                                  children: [
                                    Transform.rotate(
                                      angle: 45 * pi / 180, // 45 degrees in radians
                                      child: const IconButton(
                                        icon: Icon(Icons.attach_file,
                                            color: AppColors.white),
                                        onPressed:
                                        null, // Remove the onPressed callback
                                      ),
                                    ),
                                    const Text(
                                      "Attach Photo",
                                      style: TextStyle(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // if (_imageBytes != null)
                        Row(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: !coverDismissed && coverPhotoUrl != null
                                    ? FutureBuilder<http.Response>(
                                        future:
                                            http.get(Uri.parse(coverPhotoUrl)),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<http.Response>
                                                snapshot) {
                                          return Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Stack(children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Container(
                                                      width: 100,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                coverPhotoUrl),
                                                            fit: BoxFit.cover,
                                                          )),
                                                    )),
                                                Positioned(
                                                  top: 5,
                                                  right: 15,
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors
                                                          .systemGreay06Light,
                                                    ),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: const Icon(
                                                          Icons.close,
                                                          size: 16,
                                                          color: Colors.black),
                                                      onPressed: () {
                                                        setState(() {
                                                          coverDismissed = true;
                                                          _imageBytes = null;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ]));
                                        })
                                    : Container()),
                            if (_imageBytes != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Container(
                                          width: 100,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            image: DecorationImage(
                                              image: MemoryImage(_imageBytes!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 15,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.systemGreay06Light,
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.close,
                                                size: 16, color: Colors.black),
                                            onPressed: () {
                                              setState(() {
                                                coverDismissed = true;
                                                _imageBytes = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Add your other widgets here
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Upload up to 10 photos',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Consumer2<CapsuleImages, StagedImages>(
                                builder: (context, capsuleImages, stagedImages,
                                    child) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (capsuleImages.freeCount() +
                                              stagedImages.freeCount() >
                                              0) {
                                            final ImagePicker imagePicker =
                                            ImagePicker();
                                            imagePicker
                                                .pickImage(
                                                source: ImageSource.gallery)
                                                .then((value) async {
                                              if (value != null) {
                                                final bytes =
                                                await value.readAsBytes();
                                                stagedImages.fill(bytes);
                                              }
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Transform.rotate(
                                              angle: 45 * pi / 180,
                                              // 45 degrees in radians
                                              child: const IconButton(
                                                icon: Icon(Icons.attach_file,
                                                    color: Colors.white),
                                                onPressed:
                                                null, // Remove the onPressed callback
                                              ),
                                            ),
                                            const Text(
                                              "Attach Photo",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                        ),
                                      ),
                                    )),
                          ]
                        ),
                        Consumer<CapsuleImages>(
                          builder: (context, capsuleImages, child) => Wrap(
                            direction: Axis.horizontal,
                            children: [
                              ...capsuleImages.images.map((image) => image
                                      .isNotEmpty
                                  ? SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: Stack(children: [
                                        Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Container(
                                                width: 100,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    image: DecorationImage(
                                                      image:
                                                          NetworkImage(image),
                                                      fit: BoxFit.cover,
                                                    )))),
                                        Positioned(
                                            top: 5,
                                            right: 15,
                                            child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors
                                                      .systemGreay06Light,
                                                ),
                                                child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: const Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.black),
                                                    onPressed: () {
                                                      capsuleImages
                                                          .removeByUrl(image);
                                                    }))),
                                      ]))
                                  : Container())
                            ],
                          ),
                        ),
                        Consumer<StagedImages>(
                            builder: (context, stagedImages, child) => Wrap(
                                  direction: Axis.horizontal,
                                  children: stagedImages.images
                                      .map(
                                        (imageBytes) => imageBytes != null
                                            ? SizedBox(
                                                width: 140,
                                                height: 140,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Container(
                                                        width: 100,
                                                        height: 120,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                          image:
                                                              DecorationImage(
                                                            image: MemoryImage(
                                                                imageBytes),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 5,
                                                      right: 15,
                                                      child: Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: AppColors
                                                              .systemGreay06Light,
                                                        ),
                                                        child: IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          icon: const Icon(
                                                              Icons.close,
                                                              size: 16,
                                                              color:
                                                                  Colors.black),
                                                          onPressed: () {
                                                            stagedImages
                                                                .removeByContent(
                                                                    imageBytes);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(), // or some other widget to display when imageBytes is null
                                      )
                                      .toList(),
                                )),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 50,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.textColor),
                                ),
                                onPressed: _showDeleteCapsuleDialog, /* () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                } */
                              ),
                            ),
                            const SizedBox(width: 10),
                            Consumer2<CapsuleImages, StagedImages>(
                                builder: (context, capsuleImages, stagedImages,
                                        child) =>
                                    SizedBox(
                                      width: 120,
                                      height: 50,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1,
                                          ),
                                          backgroundColor:
                                              AppColors.primaryColor,
                                        ),
                                        child: const Text(
                                          'Update',
                                          style:
                                              TextStyle(color: AppColors.white),
                                        ),
                                        onPressed: () async {
                                          final userId = getCurrentUserId();
                                          DocumentReference capsuleReference =
                                              snapshot.data!.docs[0].reference;
                                          String capsuleId = snapshot
                                              .data!.docs[0]
                                              .get('capsuleId');
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();

                                            Map<String, dynamic> updates = {
                                              "title": _titleController.text,
                                              'message':
                                                  _messageController.text,
                                              'editBeforeDate': _editBeforeDate,
                                              'openDate': _openDate,
                                            };

                                            try {
                                              await capsuleReference
                                                  .update(updates);

                                              if (_imageBytes != null &&
                                                  coverDismissed) {
                                                final coverPhotoRef =
                                                    FirebaseStorage.instance
                                                        .ref()
                                                        .child(
                                                            'capsule_covers/$capsuleId');
                                                await coverPhotoRef
                                                    .putData(_imageBytes!);
                                                final coverPhotoUrl =
                                                    await coverPhotoRef
                                                        .getDownloadURL();
                                                await capsuleReference.update({
                                                  'coverPhotoUrl': coverPhotoUrl
                                                });
                                              } else if (coverDismissed) {
                                                await capsuleReference.update({
                                                  'coverPhotoUrl':
                                                      FieldValue.delete(),
                                                });
                                              }

                                              Iterator<int> freeIndexIterator =
                                                  capsuleImages
                                                      .freeIndices()
                                                      .iterator;
                                              final imageRef = FirebaseStorage
                                                  .instance
                                                  .ref();
                                              List<Uint8List?> clonedImages =
                                                  List<Uint8List?>.from(
                                                      stagedImages.images);
                                              for (final image
                                                  in clonedImages) {
                                                if (image != null) {
                                                  if (freeIndexIterator
                                                      .moveNext()) {
                                                    int currentIndex =
                                                        freeIndexIterator
                                                            .current;
                                                    final currentImageRef =
                                                        imageRef.child(
                                                            'capsule_photos/$capsuleId/photo_$currentIndex');
                                                    await currentImageRef
                                                        .putData(image);
                                                    final url =
                                                        await currentImageRef
                                                            .getDownloadURL();
                                                    capsuleImages.replaceAt(
                                                        currentIndex, url);
                                                    stagedImages
                                                        .removeByContent(image);
                                                  }
                                                } else {
                                                  break;
                                                }
                                              }

                                              Map<String, dynamic> newImages =
                                                  {};

                                              for (int i = 0; i <= 9; ++i) {
                                                if (capsuleImages
                                                    .images[i].isNotEmpty) {
                                                  newImages[
                                                          'capsule_photourl$i'] =
                                                      capsuleImages.images[i];
                                                } else {
                                                  newImages[
                                                          'capsule_photourl$i'] =
                                                      FieldValue.delete();
                                                }
                                              }

                                              await capsuleReference
                                                  .update(newImages);

                                              setState(() {
                                                _titleController.clear();
                                                _messageController.clear();
                                                _editBeforeDate =
                                                    DateTime.now();
                                                _openDate = DateTime.now();
                                              });
                                              setState(() {
                                                _imageBytes = null;
                                                stagedImages.clear();
                                              });
                                              setState(() {});

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HomeScreen()),
                                                (Route<dynamic> route) => false,
                                              );
                                            } on FirebaseException catch (e) {
                                              log.severe(e.message);
                                              setState(() {
                                                errorMessage = e.message!;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    )),
                          ],
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }
}
