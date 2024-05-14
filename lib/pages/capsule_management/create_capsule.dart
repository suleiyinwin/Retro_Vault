// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _sharedWithController = TextEditingController();
  Uint8List? _imageBytes;
  DateTime _editBeforeDate = DateTime.now();
  DateTime _openDate = DateTime.now();
  List<Uint8List?> _imageBytesList = List<Uint8List?>.filled(10, null);
  List<QueryDocumentSnapshot> _selectedUsers = [];
  late FirebaseFirestore firestore;
  late firebase_storage.FirebaseStorage storage;
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  String generateUniqueId() {
    const uuid = Uuid();
    return uuid.v4(); // Generate a Version 4 (random) UUID
  }

  Future<void> _selectFile() async {
    // Mobile platform
    final ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        for (int i = 0; i < 10; i++) {
          if (_imageBytesList[i] == null) {
            _imageBytesList[i] = bytes.buffer.asUint8List();
            break;
          }
        }
      });
    }
  }

  Future<void> _selectCoverPhoto() async {
    // Mobile platform
    final ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes.buffer.asUint8List();
      });
    }
  }

  Future<void> _getSharedUser() async {
    final input = _sharedWithController.text.trim();
    if (input.isNotEmpty) {
      final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      if (input == currentUserEmail) {
        // Show a message if the input email is the same as the logged-in user's email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot share with yourself'),
            backgroundColor: Colors.orange,
          ),
        );
        return; // Exit the function early
      }

      // Search for the user in Firebase Firestore
      final QuerySnapshot sharedUserRef = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: input)
          .get();
      if (sharedUserRef.docs.isNotEmpty) {
        final userDoc = sharedUserRef.docs.first;

        // Check if the user is already in the list
        if (!_selectedUsers.any((user) => user.id == userDoc.id)) {
          // Add the userDoc snapshot to the selected users list
          setState(() {
            _selectedUsers.add(userDoc);
            _sharedWithController.clear();
          });
        } else {
          // Show a message if the user is already in the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User is already added'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Show an error message if the user is not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSelectedUsers() {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      children: _selectedUsers.map((user) {
        // Fetch the user data safely
        final Map<String, dynamic>? userData =
            user.data() as Map<String, dynamic>?;
        final String? profilePhotoUrl =
            (userData != null && userData.containsKey('profile_photo_url'))
                ? user.get('profile_photo_url')
                : null;

        return Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 15, 15),
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2), // Border width
                decoration: const BoxDecoration(
                  color: AppColors.textColor, // Border color
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: profilePhotoUrl != null
                      ? NetworkImage(profilePhotoUrl) as ImageProvider
                      : const AssetImage('image/logo.png') as ImageProvider,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                user.get('username'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.systemGreay06Light,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, size: 16, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _selectedUsers.remove(user);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _capsuleCreateButton() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final QuerySnapshot userRef = await FirebaseFirestore.instance
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
        final docRef =
            await FirebaseFirestore.instance.collection('capsules').add({
          'userRef': userReference,
          'userId': userId,
          'capsuleId': capsuleId,
          'title': _titleController.text,
          'message': _messageController.text,
          'editBeforeDate': _editBeforeDate,
          'openDate': _openDate,
        });
        if (_imageBytes != null) {
          final coverPhotoRef =
              FirebaseStorage.instance.ref().child('capsule_covers/$capsuleId');
          await coverPhotoRef.putData(_imageBytes!);
          final coverPhotoUrl = await coverPhotoRef.getDownloadURL();
          await docRef.update({'coverPhotoUrl': coverPhotoUrl});
        }

        for (int i = 0; i < _imageBytesList.length; i++) {
          final photoBytes = _imageBytesList[i];
          if (photoBytes != null) {
            final photoRef = FirebaseStorage.instance
                .ref()
                .child('capsule_photos/$capsuleId/photo_$i');
            await photoRef.putData(photoBytes);
            final photoUrl = await photoRef.getDownloadURL();
            await docRef.update({'capsule_photourl$i': photoUrl});
          }
        }
        if (_selectedUsers.isNotEmpty) {
          for (int i = 0; i < _selectedUsers.length; i++) {
            final user = _selectedUsers[i];
            final userRef =
                FirebaseFirestore.instance.collection('user').doc(user.id);
            await docRef.update({'sharedWith$i': userRef});
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
          _imageBytesList = List<Uint8List?>.filled(10, null);
        });
        setState(() {});
        // Clear the image bytes list
      } on FirebaseException catch (e) {
        setState(() {
          // print(e.message);
          errorMessage = e.message!;
        });
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //Capsule Title, Edit Before, Open Date
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
                //Error Message for edit before
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '**Edit before date cannot be changed in the future',
                      style: TextStyle(color: AppColors.errorRed, fontSize: 13),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                //Capsule Message Title
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
                //Capsule Message
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
                //Upload Capsule Cover Photo

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
                //Capsule Cover Photo Preview
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
                const SizedBox(height: 15),
                //Upload Capsule Photos

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

                //Capsule Photos Preview
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
                const SizedBox(height: 20),
                //Share Section
                Row(
                  children: [
                    const Text(
                      'Share with',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: _sharedWithController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(40), // Border radius
                                borderSide: BorderSide
                                    .none, // Remove the default border
                              ),
                              filled: true,
                              fillColor: AppColors.white),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor),
                          onEditingComplete: () => _getSharedUser(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                    alignment: AlignmentDirectional.centerStart,
                    child: _buildSelectedUsers()),
                const SizedBox(height: 20),

                //Create Capsule implement with firebase
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (Route<dynamic> route) => false,
                          );
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
                        onPressed: _capsuleCreateButton,
                        child: const Text(
                          'Save',
                          style: TextStyle(color: AppColors.white),
                        ),
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
