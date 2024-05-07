// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:html';
// import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:retro/pages/capsule_management/capsule_list.dart';
import 'package:uuid/uuid.dart';
import 'package:retro/components/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:retro/firebase_options.dart';

class CreateCapsule extends StatefulWidget {
  const CreateCapsule({super.key});

  @override
  State<CreateCapsule> createState() => _CreateCapsuleState();
}

class _CreateCapsuleState extends State<CreateCapsule> {
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  Uint8List? _imageBytes;
  DateTime _editBeforeDate = DateTime.now();
  DateTime _openDate = DateTime.now();
  List<Uint8List?> _imageBytesList = List<Uint8List?>.filled(10, null);
  late FirebaseFirestore firestore;
  late firebase_storage.FirebaseStorage storage;
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
// .then((_) {
//       firestore = FirebaseFirestore.instance;
//       storage = firebase_storage.FirebaseStorage.instance;
//     })

  Future<String?> getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return 'AEHcUcxLJkhE2aQmVcfMLTYp9an2';
    }
  }

  String generateUniqueId() {
    const uuid = Uuid();
    return uuid.v4(); // Generate a Version 4 (random) UUID
  }

  // Future<void> _saveData() async {
  //   // if (_formKey.currentState!.validate()) {
  //     const userId = 'AEHcUcxLJkhE2aQmVcfMLTYp9an2';
  //     // if (userId == null) {
  //     //   // Handle case where user ID is not available
  //     //   print ('User ID is not available');
  //     //   return;
  //     // }

  //     final docRef = await firestore.collection('capsules').add({
  //       'title': _titleController.text,
  //       'message': _messageController.text,
  //       'editBeforeDate': _editBeforeDate,
  //       'openDate': _openDate,
  //     });

  //     if (_imageBytes != null) {
  //       final coverPhotoRef = storage.ref().child('capsule_covers/${docRef.id}');
  //       await coverPhotoRef.putData(_imageBytes!);
  //       final coverPhotoUrl = await coverPhotoRef.getDownloadURL();
  //       await docRef.update({'coverPhotoUrl': coverPhotoUrl});
  //     }

  //     for (int i = 0; i < _imageBytesList.length; i++) {
  //       final photoBytes = _imageBytesList[i];
  //       if (photoBytes != null) {
  //         final photoRef = storage.ref().child('capsule_photos/${docRef.id}/photo_$i');
  //         await photoRef.putData(photoBytes);
  //         final photoUrl = await photoRef.getDownloadURL();
  //         await docRef.collection('photos').add({'url': photoUrl});
  //       }
  //     }
  //   // }
  // }
  Future<void> _selectFile() async {
    final input = InputElement(type: 'file');
    input.onChange.listen((_) async {
      final file = input.files!.first;
      final reader = FileReader();
      reader.onError.listen((_) {
        print('Error reading file');
      });
      reader.onLoad.listen((_) {
        setState(() {
          for (int i = 0; i < 10; i++) {
            if (_imageBytesList[i] == null) {
              _imageBytesList[i] = reader.result as Uint8List;
              break;
            }
          }
        });
      });
      reader.readAsArrayBuffer(file);
    });
    input.click();
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
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16.0), // add padding here
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: Icon(Icons.edit,
                                    size: 15, color: AppColors.textColor),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 8, 0),
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
                              controller: _titleController,
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
                            style: TextStyle(color: AppColors.textColor),
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
                                        onBackground: AppColors.textColor,
                                        brightness: Brightness.light,
                                        onPrimary: AppColors.white,
                                        onSecondary: AppColors.textColor,
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Date cannot be later than 30 days from now'),
                                        backgroundColor: AppColors.errorRed,
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
                              DateFormat.yMMMd().format(_editBeforeDate),
                              style:
                                  const TextStyle(color: AppColors.textColor),
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
                            style: TextStyle(color: AppColors.textColor),
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
                                        onBackground: AppColors.textColor,
                                        brightness: Brightness.light,
                                        onPrimary: AppColors.white,
                                        onSecondary: AppColors.textColor,
                                        onError: AppColors.errorRed,
                                        onSurface: AppColors.textColor,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              ).then((picked) {
                                if (picked != null) {
                                  if (picked.isBefore(_editBeforeDate)) {
                                    // Show error message for dates before _editBeforeDate
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Date cannot be before Edit Before date'),
                                        backgroundColor: AppColors.errorRed,
                                      ),
                                    );
                                  } else if (picked.isAfter(DateTime.now()
                                      .add(const Duration(days: 365)))) {
                                    // Show error message for dates after one year from now
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Date cannot be after one year from now'),
                                        backgroundColor: AppColors.errorRed,
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
                              style:
                                  const TextStyle(color: AppColors.textColor),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '**Edid before date cannot be changed in the future',
                  style: TextStyle(color: AppColors.errorRed, fontSize: 13),
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
                    controller: _messageController,
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
                Row(
                  children: [
                    const Text(
                      'Upload Capsule Cover Photo',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    //Image Picker for native Platform
                    // IconButton(
                    //   icon: const Icon(Icons.image),
                    //   onPressed: () async {
                    //     final ImagePicker picker = ImagePicker();
                    //     final XFile? image =
                    //         await picker.pickImage(source: ImageSource.gallery);
                    //     setState(() {
                    //       if (image != null) {
                    //         _image = File(image.path);
                    //       } else {
                    //         _image = null;
                    //       }
                    //     });
                    //   },
                    // ),

                    //Image Picker for Web Platform
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        onTap: () {
                          html.InputElement uploadInput =
                              html.InputElement(type: 'file');
                          uploadInput.click();
                          uploadInput.onChange.listen((_) {
                            final file = uploadInput.files!.first;
                            final reader = html.FileReader();
                            reader.readAsArrayBuffer(file);
                            reader.onLoadEnd.listen((_) {
                              setState(() {
                                _imageBytes = reader.result as Uint8List;
                              });
                            });
                          });
                        },
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
                    )
                  ],
                ),
                if (_imageBytes != null)
                  Row(
                    children: [
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
                                    borderRadius: BorderRadius.circular(7),
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
                // Row(
                //   children: [
                //     const Text('Upload up to 10 Photos'),
                //     const SizedBox(width: 10),
                //     IconButton(
                //       icon: const Icon(Icons.camera),
                //       onPressed: () {
                //         // Implement photo upload logic
                //       },
                //     ),
                //   ],
                // ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Upload up to 10 photos',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        onTap: _selectFile,
                        child: Row(
                          children: [
                            Transform.rotate(
                              angle: 45 * pi / 180, // 45 degrees in radians
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
                    ),
                  ],
                ),
                Wrap(
                  direction: Axis.horizontal,
                  children: _imageBytesList
                      .map(
                        (imageBytes) => imageBytes != null
                            ? SizedBox(
                                width: 140,
                                height: 140,
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
                                            image: MemoryImage(imageBytes),
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
                                              _imageBytesList[_imageBytesList
                                                  .indexOf(imageBytes)] = null;
                                            });
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
                ),
                // const SizedBox(height: 20),
                // const Row(
                //   children: [
                //     Text('Share Your Capsule with'),
                //     SizedBox(width: 10),
                //     Text('Sara'),
                //   ],
                // ),
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
                          'Cancel',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                        onPressed: () {
                          // Implement cancel logic
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: AppColors.white),
                        ),
                        onPressed: () async {
                          // _saveData();
                          // final user = FirebaseAuth.instance.currentUser;
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          // final userRef = FirebaseFirestore.instance.collection('user').doc(userId);
                          final QuerySnapshot userRef = await FirebaseFirestore
                              .instance
                              .collection('user')
                              .where('userId', isEqualTo: userId)
                              .get();
                          final userReference = FirebaseFirestore.instance
                              .collection('user')
                              .doc(userRef.docs.first.id);
                          final capsuleId = generateUniqueId();
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              final docRef = await FirebaseFirestore.instance
                                  .collection('capsules')
                                  .add({
                                'userRef': userReference,
                                'userId':userId,
                                'capsuleId': capsuleId,
                                'title': _titleController.text,
                                'message': _messageController.text,
                                'editBeforeDate': _editBeforeDate,
                                'openDate': _openDate,
                              });
                              if (_imageBytes != null) {
                                final coverPhotoRef = FirebaseStorage.instance
                                    .ref()
                                    .child('capsule_covers/$capsuleId');
                                await coverPhotoRef.putData(_imageBytes!);
                                final coverPhotoUrl =
                                    await coverPhotoRef.getDownloadURL();
                                await docRef
                                    .update({'coverPhotoUrl': coverPhotoUrl});
                              }

                              for (int i = 0; i < _imageBytesList.length; i++) {
                                final photoBytes = _imageBytesList[i];
                                if (photoBytes != null) {
                                  final photoRef = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          'capsule_photos/$capsuleId/photo_$i');
                                  await photoRef.putData(photoBytes);
                                  final photoUrl =
                                      await photoRef.getDownloadURL();
                                  await docRef
                                      .update({'capsule_photourl$i': photoUrl});
                                }
                              }
                              setState(() {
                                _titleController.clear();
                                _messageController.clear();
                                _editBeforeDate = DateTime.now();
                                _openDate = DateTime.now();
                              });
                              setState(() {
                                _imageBytes = null;
                                _imageBytesList =
                                    List<Uint8List?>.filled(10, null);
                              });
                              setState(() {});
                              // Clear the image bytes list
                            } on FirebaseException catch (e) {
                              setState(() {
                                print(e.message);
                                errorMessage = e.message!;
                              });
                            }
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
