import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/components/colors.dart';

class OpenedCapsule extends StatefulWidget {
  const OpenedCapsule({Key? key, required this.capsuleId}) : super(key: key);
  final String capsuleId;

  @override
  State<OpenedCapsule> createState() => _OpenedCapsuleState();
}

class _OpenedCapsuleState extends State<OpenedCapsule> {
  PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // void _previousImage() {
  //    _currentPageIndex = (_currentPageIndex - 1) % 10;
  // _pageController.animateToPage(
  //   _currentPageIndex,
  //   duration: const Duration(milliseconds: 300),
  //   curve: Curves.ease,
  //     );
  //   // } else {
  //   //   _pageController.jumpToPage(9);
  //   // }
  // }

  // void _nextImage() {
  //   _currentPageIndex = (_currentPageIndex + 1) % 10;
  // _pageController.animateToPage(
  //   _currentPageIndex,
  //   duration: const Duration(milliseconds: 300),
  //   curve: Curves.ease,
  //     );
  //   // } else {
  //   //   _pageController.jumpToPage(0);
  //   // }
  // }
  void _previousImage() {
    setState(() {
      _currentPageIndex = (_currentPageIndex - 1) % 10;
      if (_currentPageIndex < 0) {
        _currentPageIndex += 10;
      }
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  void _nextImage() {
    setState(() {
      _currentPageIndex = (_currentPageIndex + 1) % 10;
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  Widget _buildCircleIndicator(int index) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == _currentPageIndex % 5
            ? AppColors.primaryColor
            : AppColors.secondaryColor,
      ),
    );
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('capsules')
            .doc(widget.capsuleId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Capsule not found."),
            );
          }

          final data = snapshot.data!;
          final title = data['title'] ?? "Title not found";
          final message = data['message'] ?? "Message not found";
          final Map<String, dynamic>? capsuleData =
              data.data() as Map<String, dynamic>?;
          final List<String?> photoUrls = List.generate(10, (index) {
            final key = 'capsule_photourl$index';
            return capsuleData != null && capsuleData.containsKey(key)
                ? capsuleData[key]
                : null;
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _previousImage,
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.primaryColor,
                                size: 40,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 240,
                                height: 320,
                                color: Colors
                                    .grey, // Placeholder color for the rectangle
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: photoUrls.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    // You can replace this with your image widget
                                    if (photoUrls[index] != null) {
                                      // You can replace this with your image widget
                                      return Image.network(
                                        photoUrls[index]!,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      // Placeholder widget or empty container
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _nextImage,
                              icon: const Icon(
                                Icons.chevron_right,
                                color: AppColors.primaryColor,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => _buildCircleIndicator(index),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.backgroundColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textColor,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(
                    width: 160,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.primaryColor, width: 1.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
